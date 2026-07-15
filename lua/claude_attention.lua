-- claude_attention.lua
-- 複数 Claude Code セッションの「応答待ち」を可視化し、待ちペインへ素早く飛ぶ。
--
-- 仕組み:
--   * 各セッションの Claude が Stop/Notification hook(claude-attention-hook)で
--     「待ち」を claude-tasks の attention スタック(~/.cache/claude-tasks/attention/)に積む。
--   * nvim はそのディレクトリを fs_event で監視し、待ちを M.queue にキャッシュ。
--   * lualine コンポーネント(plugins/ui.lua)が b.claude_task を見て、その dir が
--     待ちなら下バーに 🔔 を出す(inactive ペインでも光る=別ペイン作業中に気づける)。
--   * <Leader>n=多画面: 画面上の待ちペインのうち最優先へカーソル移動(画面外は開かない/
--     画面上に待ちが無ければメッセージのみ)。<Leader>N=1画面: 次の待ち(グローバル優先度→
--     FIFO)へ確実に移る(表示中は移動・隠れ/無しは現ウィンドウに出す/作る)。
--
-- ★ 待ちの実体(積む/消す/並べる)は claude-tasks に集約(fish の ccpick とも共有)。
--   このファイルは監視・表示・ジャンプという nvim 固有部分だけを持つ。

local M = {}

-- claude-tasks 解決(claude_tasks.lua と同じ理由で絶対パスフォールバック)
local ct_cmd = vim.fn.exepath("claude-tasks")
if ct_cmd == "" then
  local fallback = vim.fn.expand("~/.claude_plugin/scripts/claude-tasks")
  ct_cmd = vim.fn.executable(fallback) == 1 and fallback or "claude-tasks"
end

local ATT_DIR = vim.fn.expand("~/.cache/claude-tasks/attention")

-- 待ち(あなたの番)の kind。working(考え中)はここに含めない=キュー外・表示専用。
local WAITING = { ask = true, permission = true, stop = true, idle = true }

-- どの待ち kind を注目対象にするか(:ClaudeAttn で実行時トグル)。
M.enabled = { ask = true, permission = true, stop = true, idle = false }

-- 全状態キャッシュ: norm(dir) -> kind(working 含む。lualine 表示用)
M.states = {}
-- ジャンプ待ち行列: { {dir=, kind=}, ... }(優先度→FIFO順。working は入らない)
M.queue = {}

-- dir 正規化(claude_tasks と揃える。b.claude_task もこの形)
local function norm(dir)
  if not dir or dir == "" then
    return ""
  end
  return (vim.fn.fnamemodify(dir, ":p"):gsub("/$", ""))
end

-- いま自分が見ているペインの claude セッション dir(なければ nil)
local function current_task_dir()
  return vim.b.claude_task
end

-- 状態を読み直して M.states / M.queue を更新。
-- 見ているペイン(現バッファ)の「待ち」は即クリア(考え中=working は残す)。
function M.refresh()
  local out = vim.fn.systemlist({ ct_cmd, "attention-list" })
  local cur = current_task_dir()
  cur = cur and norm(cur) or nil

  local states, q = {}, {}
  for _, line in ipairs(out) do
    local kind, dir = line:match("^(%S+)\t(.+)$")
    if dir then
      local ndir = norm(dir)
      if cur and ndir == cur and WAITING[kind] then
        -- 今このペインを見ている待ち → 消費済み扱いで消す
        vim.fn.jobstart({ ct_cmd, "attention-clear", dir })
      else
        states[ndir] = kind
        if WAITING[kind] and M.enabled[kind] then
          table.insert(q, { dir = dir, kind = kind }) -- out は既に優先度→FIFO順
        end
      end
    end
  end
  M.states = states
  M.queue = q

  -- lualine を再描画(状態の点灯/消灯を反映)
  pcall(function()
    require("lualine").refresh()
  end)
end

-- lualine コンポーネント用: この dir の現在状態 {kind=} を返す(working 含む)
function M.status_for(dir)
  dir = norm(dir)
  if dir == "" then
    return nil
  end
  local kind = M.states[dir]
  if not kind then
    return nil
  end
  return { kind = kind }
end

-- スタック先頭(飛ぶべき待ち)を pop。dir を返す。無ければ nil。
local function pop_top()
  local e = M.queue[1]
  if not e then
    vim.notify("待ちセッションはありません", vim.log.levels.INFO)
    return nil
  end
  vim.fn.jobstart({ ct_cmd, "attention-clear", e.dir })
  table.remove(M.queue, 1)
  return e.dir
end

-- 多画面運用: 変換+m と同じ巡回順(jump-order = 未対応待ち優先→LRU)で、
-- 「いま画面に出ているペイン」の最初の候補へカーソルを移すだけ。画面外は開かない
-- (レイアウトを壊さない)。画面内に候補が無ければ通知のみ。
function M.next_focus()
  -- 画面に出ている claude ペインを norm(dir) -> win で集める
  local win_by_dir = {}
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local d = vim.b[vim.api.nvim_win_get_buf(w)].claude_task
    if d then
      win_by_dir[norm(d)] = w
    end
  end
  -- claude-tasks の巡回順(変換+m と同一)を上から見て、画面内の最初の1つへ。
  for _, dir in ipairs(vim.fn.systemlist({ ct_cmd, "jump-order" })) do
    local w = win_by_dir[norm(dir)]
    if w then
      vim.api.nvim_set_current_win(w) -- WinEnter autocmd が待ちをクリア
      vim.fn.jobstart({ ct_cmd, "visit-mark", dir }) -- LRU 更新(連打で巡回)
      return
    end
  end
  vim.notify("画面内に巡回対象のセッションはありません", vim.log.levels.INFO)
end

-- 1画面運用: 次の待ち(グローバル優先度→FIFO の先頭)へ確実に移る。
-- 表示中ならそのウィンドウへ、隠れていれば現ウィンドウに、無ければ作って attach。
function M.next_switch()
  -- 飛び先は claude-tasks に集約(母集団=live非working / 未対応待ち優先→last_visit古い順LRU)。
  local out = vim.fn.systemlist({ ct_cmd, "next-jump" })
  local dir = out and out[1]
  if not dir or dir == "" then
    vim.notify("巡回対象のセッションはありません", vim.log.levels.INFO)
    return
  end
  require("claude_tasks").open(dir) -- mode=current(既定): 表示中は移動/無ければ現ウィンドウに出す
  vim.fn.jobstart({ ct_cmd, "visit-mark", dir }) -- last_visit=now(WinEnterでも更新されるが確実に)
  M.refresh()
end

-- 実行時トグル(:ClaudeAttn stop|permission|idle)
function M.toggle_event(kind)
  if M.enabled[kind] == nil then
    vim.notify("kind は stop|permission|idle のいずれか: " .. tostring(kind), vim.log.levels.WARN)
    return
  end
  M.enabled[kind] = not M.enabled[kind]
  vim.notify(("claude attention: %s = %s"):format(kind, M.enabled[kind] and "on" or "off"))
  M.refresh()
end

-- attention ディレクトリを監視(変化で refresh)。バースト吸収に軽いデバウンス。
local watcher, debounce, poll_timer
local function start_watch()
  vim.fn.mkdir(ATT_DIR, "p")
  watcher = vim.uv.new_fs_event()
  if not watcher then
    return
  end
  watcher:start(
    ATT_DIR,
    {},
    vim.schedule_wrap(function()
      if debounce then
        debounce:stop()
      end
      debounce = vim.defer_fn(function()
        M.refresh()
      end, 50)
    end)
  )
end

function M.setup()
  start_watch()

  -- 定期 refresh: 固着した working は attention ファイルが変わらず fs_event が来ないので、
  -- タイマーで claude-tasks の自己修復(reconcile)を回して表示を実状態に追従させる。
  poll_timer = vim.uv.new_timer()
  if poll_timer then
    poll_timer:start(
      15000,
      15000,
      vim.schedule_wrap(function()
        M.refresh()
      end)
    )
  end

  -- claude ペインに入ったら(BufEnter/WinEnter/TermEnter/FocusGained)その待ちを消す。
  -- 考え中(working)は消さない(離れたら ⏳ を出し続けたいので)。
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TermEnter", "FocusGained" }, {
    callback = function(ev)
      local dir = vim.b[ev.buf].claude_task
      if dir then
        vim.fn.jobstart({ ct_cmd, "visit-mark", dir }) -- LRU巡回用: 最終訪問時刻を更新
        local kind = M.states[norm(dir)]
        if kind and WAITING[kind] then
          vim.fn.jobstart({ ct_cmd, "attention-clear", dir })
        end
      end
    end,
    desc = "claude ペインに入ったら応答待ちを消す(考え中は残す)",
  })

  vim.api.nvim_create_user_command("ClaudeAttnFocus", function()
    M.next_focus()
  end, { desc = "画面上の待ちペイン最優先へカーソル移動(多画面)" })

  vim.api.nvim_create_user_command("ClaudeAttnSwitch", function()
    M.next_switch()
  end, { desc = "次の待ちへ確実に移る(1画面/無ければ作る)" })

  vim.api.nvim_create_user_command("ClaudeAttn", function(o)
    M.toggle_event(o.args)
  end, {
    nargs = 1,
    complete = function()
      return { "ask", "permission", "stop", "idle" }
    end,
    desc = "attention 対象イベントをトグル(ask|permission|stop|idle)",
  })

  -- 初回同期
  M.refresh()
end

return M
