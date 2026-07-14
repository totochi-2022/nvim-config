-- claude_attention.lua
-- 複数 Claude Code セッションの「応答待ち」を可視化し、待ちペインへ素早く飛ぶ。
--
-- 仕組み:
--   * 各セッションの Claude が Stop/Notification hook(claude-attention-hook)で
--     「待ち」を claude-tasks の attention スタック(~/.cache/claude-tasks/attention/)に積む。
--   * nvim はそのディレクトリを fs_event で監視し、待ちを M.queue にキャッシュ。
--   * lualine コンポーネント(plugins/ui.lua)が b.claude_task を見て、その dir が
--     待ちなら下バーに 🔔 を出す(inactive ペインでも光る=別ペイン作業中に気づける)。
--   * 消費: <Leader>n=フォーカス移す(多画面) / <Leader>N=切り替えて飛ぶ(1画面)。
--     どちらもスタック先頭(permission 優先→FIFO)を pop する。
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

-- どの kind を「注目」として扱うか(:ClaudeAttn で実行時トグル)。
-- 3 イベント全部を hook は積むが、ここで表示/ジャンプ対象を絞る。
M.enabled = { stop = true, permission = true, idle = false }

-- 待ち行列キャッシュ: { {dir=, kind=}, ... }(claude-tasks 側で既に優先度→FIFO順)
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

-- 待ち一覧を読み直して M.queue を更新。表示中(=見ているペイン)の待ちは即クリア。
function M.refresh()
  local out = vim.fn.systemlist({ ct_cmd, "attention-list" })
  local cur = current_task_dir()
  cur = cur and norm(cur) or nil

  local q = {}
  for _, line in ipairs(out) do
    local kind, dir = line:match("^(%S+)\t(.+)$")
    if dir and M.enabled[kind] then
      if cur and norm(dir) == cur then
        -- 今このペインを見ている → 待ちにしない(消費済み扱い)
        vim.fn.jobstart({ ct_cmd, "attention-clear", dir })
      else
        table.insert(q, { dir = dir, kind = kind })
      end
    end
  end
  M.queue = q

  -- lualine を再描画(待ちの点灯/消灯を反映)
  pcall(function()
    require("lualine").refresh()
  end)
end

-- lualine コンポーネント用: この dir が待ちなら {kind=} を返す
function M.status_for(dir)
  dir = norm(dir)
  if dir == "" then
    return nil
  end
  for _, e in ipairs(M.queue) do
    if norm(e.dir) == dir then
      return e
    end
  end
  return nil
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

-- 多画面運用: 既に開いているペインへフォーカスを移す(無ければ開く)
function M.next_focus()
  local dir = pop_top()
  if not dir then
    return
  end
  local claude = require("claude_tasks")
  if not claude.focus(dir) then
    claude.open(dir)
  end
  M.refresh()
end

-- 1画面運用: 今のウィンドウにそのセッションを出す(表示を切り替える)
function M.next_switch()
  local dir = pop_top()
  if not dir then
    return
  end
  require("claude_tasks").open(dir) -- mode=current(既定): 現ウィンドウに出す
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
local watcher, debounce
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

  -- claude ペインに入ったら(BufEnter/WinEnter/TermEnter/FocusGained)その待ちを消す
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TermEnter", "FocusGained" }, {
    callback = function(ev)
      local dir = vim.b[ev.buf].claude_task
      if dir then
        vim.fn.jobstart({ ct_cmd, "attention-clear", dir })
      end
    end,
    desc = "claude ペインに入ったら応答待ちを消す",
  })

  vim.api.nvim_create_user_command("ClaudeAttnFocus", function()
    M.next_focus()
  end, { desc = "待ちセッション先頭へフォーカス(多画面)" })

  vim.api.nvim_create_user_command("ClaudeAttnSwitch", function()
    M.next_switch()
  end, { desc = "待ちセッション先頭を現ウィンドウに出す(1画面)" })

  vim.api.nvim_create_user_command("ClaudeAttn", function(o)
    M.toggle_event(o.args)
  end, {
    nargs = 1,
    complete = function()
      return { "stop", "permission", "idle" }
    end,
    desc = "attention 対象イベントをトグル(stop|permission|idle)",
  })

  -- 初回同期
  M.refresh()
end

return M
