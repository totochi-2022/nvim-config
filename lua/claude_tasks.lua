-- claude_tasks.lua
-- 複数の Claude Code セッションを「プロジェクト(ディレクトリ)」単位のタスクとして
-- 管理し、Telescope で選んで開く。
--
-- 考え方:
--   * タスク = ディレクトリ（claude-code はプロジェクト dir で動かすものなので）
--   * 過去に開いた dir は履歴に残る（プロセスが無くても一覧に出る）
--   * 選択時: プロセス生存 → attach / 停止中 → その dir を cwd にして起動
--
-- ★ 一覧/稼働判定/preview/exit/kill/履歴などの「Claude 固有ロジック」は
--   claude-plugin-system の `claude-tasks`(PATH, ~/.claude_plugin/scripts) に集約した。
--   このファイルは Telescope/ターミナルの UI と「端末で開く/attach」だけを持つ。
--   fish の ccpick も同じ claude-tasks を叩くので、Claude の仕様変更時は
--   claude-tasks 1 箇所を直せば nvim/fish 両方が追従する。
--
-- 永続化は dtach。Neovim は attach するだけなので :q / 再起動 / nvim-server 再起動
-- でも Claude プロセスは生き残る（dtach デーモンの子であって nvim の子ではない）。
-- dtach はデタッチキー(既定 C-\)以外を横取りしないのでキーバインドが衝突しない。

local M = {}

-- claude は絶対パスで解決（spawn 元によって PATH が異なる場合に備える）
local claude_cmd = vim.fn.exepath("claude")
if claude_cmd == "" then
  claude_cmd = "claude"
end

-- ===== claude-tasks 委譲ヘルパ =====
-- 出力(行配列)を返す
local function ct(args)
  return vim.fn.systemlist(vim.list_extend({ "claude-tasks" }, args))
end
-- 単一行の出力を返す
local function ct1(args)
  local out = ct(args)
  return out[1] or ""
end
-- 終了コード 0 なら true（is-live / needs-continue 用）
local function ct_ok(args)
  vim.fn.system(vim.list_extend({ "claude-tasks" }, args))
  return vim.v.shell_error == 0
end

-- dir 正規化（絶対パス・末尾スラッシュ除去。claude-tasks と同じ前提に揃える）
local function norm(dir)
  dir = vim.fn.fnamemodify(dir, ":p"):gsub("/$", "")
  return dir
end

local function sock_for(dir)
  return ct1({ "sock", dir })
end
local function is_live(dir)
  return ct_ok({ "is-live", dir })
end
local function has_history(dir)
  return ct_ok({ "needs-continue", dir })
end
local function add_history(dir)
  vim.fn.system({ "claude-tasks", "add-history", dir })
end

-- 編集中ファイルの git ルート（無ければファイルのdir、無ければ cwd）
local function default_dir()
  local root = vim.fs.root(0, { ".git", ".hg", ".svn" })
  if root then
    return root
  end
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= "" then
    return vim.fn.fnamemodify(name, ":p:h")
  end
  return vim.fn.getcwd()
end

-- 既にこの dir の attach バッファ/ウィンドウがあればそこへ移動
local function focus_existing(dir)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.b[b].claude_task == dir then
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(w) == b then
          vim.api.nvim_set_current_win(w)
          return true
        end
      end
      vim.api.nvim_set_current_buf(b)
      return true
    end
  end
  return false
end

-- dtach 起動コマンドを組み立てる。
-- dtach -A: 生存なら attach、無ければ cwd=dir で作成して attach。
-- 新規作成時、過去ログがあれば --continue で前回会話を引き継ぐ
-- (生存時は dtach がコマンド引数を無視するので付けても無害)。
local function build_cmd(dir)
  local cmd = { "dtach", "-A", sock_for(dir), claude_cmd }
  if has_history(dir) then
    table.insert(cmd, "--continue")
  end
  return cmd
end

-- attach 用バッファの共通セットアップ（タスク識別子 + <Esc> 素通し）。
local function setup_term_buf(buf, dir)
  vim.b[buf].claude_task = dir
  -- このターミナルでは <Esc> を端末(claude)へ素通しさせる。
  -- グローバルの t:<Esc>=ノーマルモード(21_keymap.lua) をバッファローカルで上書き。
  -- ノーマルモードへ抜けたいときは組み込みの <C-\><C-n> を使う。
  vim.keymap.set("t", "<Esc>", "<Esc>", {
    buffer = buf,
    desc = "claude へ ESC を送る",
  })
end

-- stale ソケット掃除
local function clean_stale_sock(dir)
  if not is_live(dir) then
    local sock = sock_for(dir)
    if sock ~= "" and vim.uv.fs_stat(sock) then
      os.remove(sock)
    end
  end
end

-- toggleterm(float) に開く。dir ごとに Terminal インスタンスをキャッシュして
-- 再オープン時は同じフロートを使い回す（dtach -A なので中身は同一セッション）。
local tt_terms = {}
local function open_toggleterm(dir)
  local ok, tt = pcall(require, "toggleterm.terminal")
  if not ok then
    vim.notify("toggleterm が利用できません", vim.log.levels.WARN)
    return
  end
  clean_stale_sock(dir)
  add_history(dir)
  local term = tt_terms[dir]
  if not term then
    -- cmd は文字列で渡す必要があるので各要素を shellescape
    local parts = {}
    for _, a in ipairs(build_cmd(dir)) do
      table.insert(parts, vim.fn.shellescape(a))
    end
    term = tt.Terminal:new({
      cmd = table.concat(parts, " "),
      dir = dir,
      direction = "float",
      close_on_exit = true,
      on_open = function(t)
        setup_term_buf(t.bufnr, dir)
        vim.cmd("startinsert")
      end,
      on_exit = function()
        tt_terms[dir] = nil -- claude 終了でインスタンスを破棄
      end,
    })
    tt_terms[dir] = term
  end
  term:open()
  vim.cmd("startinsert")
end

-- タスクを開く: 生存なら attach、停止中なら dir を cwd にして起動。
-- opts.mode: "current"(既定/現ウィンドウ置換) | "left"(左の縦分割) | "toggleterm"(float)
function M.open(dir, opts)
  opts = opts or {}
  local mode = opts.mode or "current"

  dir = norm(dir and dir ~= "" and dir or default_dir())
  if dir == "" then
    dir = vim.fn.getcwd()
  end

  if mode == "toggleterm" then
    open_toggleterm(dir)
    return
  end

  if focus_existing(dir) then
    vim.cmd("startinsert")
    return
  end

  clean_stale_sock(dir)
  add_history(dir)

  if mode == "left" then
    vim.cmd("topleft vnew") -- 画面左に縦分割して新規バッファ
  else
    vim.cmd("enew")
  end
  vim.fn.jobstart(build_cmd(dir), { term = true, cwd = dir })
  setup_term_buf(vim.api.nvim_get_current_buf(), dir)
  vim.cmd("startinsert")
end

-- タスクを正常終了(resume 可能)。claude に /exit を送って状態を保存させてから
-- 抜けさせる（claude-tasks exit に委譲）。ESC→/exit→保存待ちを内部で行い ~1.4s かかるため
-- jobstart で非同期に実行して nvim をブロックしない。
function M.kill(dir)
  if not dir or dir == "" then
    return
  end
  dir = norm(dir)
  vim.fn.jobstart({ "claude-tasks", "exit", dir })
end

-- 応答しなくなったタスクの強制終了（最終手段）。状態保存は期待できない。
function M.force_kill(dir)
  if not dir or dir == "" then
    return
  end
  dir = norm(dir)
  vim.fn.system({ "claude-tasks", "kill", dir })
end

-- Telescope: claude-tasks list（稼働状態付き・最終利用順）から選んで開く。
-- preview に最新会話ログ、C-x で正常終了 / C-d で強制kill。
function M.pick()
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("telescope が利用できません", vim.log.levels.WARN)
    return
  end
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  -- "<mark>\t<表示パス>\t<フルパス>" を parse
  local items = {}
  for _, line in ipairs(ct({ "list" })) do
    local mark, disp, full = line:match("^(%S+)\t(.-)\t(.+)$")
    if full then
      table.insert(items, { dir = full, mark = mark, disp = disp, live = (mark == "●") })
    end
  end

  local previewer = previewers.new_buffer_previewer({
    title = "Claude 最新会話",
    define_preview = function(self, entry)
      local lines = vim.fn.systemlist({ "claude-tasks", "preview", entry.value.dir })
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
    end,
  })

  pickers.new({}, {
    prompt_title = "Claude Tasks  (Enter: open / C-v: left split / C-f: float / C-x: exit&save / C-d: force-kill)",
    finder = finders.new_table({
      results = items,
      entry_maker = function(it)
        local display = it.mark .. " " .. it.disp
        -- 並びは claude-tasks list の最終利用順を維持。ordinal はパスのみ(フィルタ用)
        return { value = it, display = display, ordinal = it.disp }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewer,
    attach_mappings = function(bufnr, _map)
      actions.select_default:replace(function()
        actions.close(bufnr)
        local sel = action_state.get_selected_entry()
        if sel then
          M.open(sel.value.dir)
        end
      end)
      -- 開き方バリエーション: C-v=左の縦分割 / C-f=toggleterm(float)
      local function open_with(mode)
        return function()
          local sel = action_state.get_selected_entry()
          if sel then
            actions.close(bufnr)
            M.open(sel.value.dir, { mode = mode })
          end
        end
      end
      _map({ "i", "n" }, "<C-v>", open_with("left"))
      _map({ "i", "n" }, "<C-f>", open_with("toggleterm"))
      local function kill_action()
        local sel = action_state.get_selected_entry()
        if sel then
          M.kill(sel.value.dir) -- claude に /exit を送って状態保存させてから終了(非同期)
          actions.close(bufnr)
          -- claude が保存して抜けるまで少し待ってから一覧を更新（稼働状態が反映される）
          vim.defer_fn(M.pick, 1600)
        end
      end
      local function force_kill_action()
        local sel = action_state.get_selected_entry()
        if sel then
          M.force_kill(sel.value.dir)
          actions.close(bufnr)
          vim.schedule(M.pick)
        end
      end
      _map({ "i", "n" }, "<C-x>", kill_action)
      _map({ "i", "n" }, "<C-d>", force_kill_action)
      return true
    end,
  }):find()
end

function M.setup()
  vim.api.nvim_create_user_command("ClaudeOpen", function(o)
    M.open(o.args)
  end, {
    nargs = "?",
    complete = "dir",
    desc = "Claude タスクを開く(既定: 現プロジェクトの git ルート)",
  })

  vim.api.nvim_create_user_command("ClaudePick", function()
    M.pick()
  end, { desc = "Claude タスクを Telescope で選ぶ" })

  vim.api.nvim_create_user_command("ClaudeKill", function(o)
    M.kill(o.args ~= "" and o.args or default_dir())
  end, { nargs = "?", complete = "dir", desc = "Claude タスクを終了" })
end

return M
