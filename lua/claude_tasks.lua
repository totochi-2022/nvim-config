-- claude_tasks.lua
-- 複数の Claude Code セッションを「プロジェクト(ディレクトリ)」単位のタスクとして
-- 管理し、Telescope で選んで開く。
--
-- 考え方:
--   * タスク = ディレクトリ（claude-code はプロジェクト dir で動かすものなので）
--   * 過去に開いた dir は履歴ファイルに残る（プロセスが無くても一覧に出る）
--   * 選択時: プロセス生存 → attach / 停止中 → その dir を cwd にして起動
--
-- 永続化は dtach。Neovim は attach するだけなので :q / 再起動 / nvim-server 再起動
-- でも Claude プロセスは生き残る（dtach デーモンの子であって nvim の子ではない）。
-- dtach はデタッチキー(既定 C-\)以外を横取りしないのでキーバインドが衝突しない。

local M = {}

local data_dir = vim.fn.expand("~/.cache/claude-tasks")
local history_file = data_dir .. "/projects"

-- claude は絶対パスで解決（spawn 元によって PATH が異なる場合に備える）
local claude_cmd = vim.fn.exepath("claude")
if claude_cmd == "" then
  claude_cmd = "claude"
end

local function ensure_dir()
  vim.fn.mkdir(data_dir, "p")
end

-- dir → ソケットパス（dir のハッシュで一意・衝突なし）
local function sock_for(dir)
  return data_dir .. "/" .. vim.fn.sha256(dir):sub(1, 16) .. ".sock"
end

-- 履歴(最近順)を読む。存在しない dir は除外。
local function read_history()
  local out, seen = {}, {}
  if vim.fn.filereadable(history_file) == 1 then
    for _, line in ipairs(vim.fn.readfile(history_file)) do
      local dir = vim.trim(line)
      if dir ~= "" and not seen[dir] and vim.fn.isdirectory(dir) == 1 then
        seen[dir] = true
        table.insert(out, dir)
      end
    end
  end
  return out
end

-- dir を履歴の先頭へ（重複排除）
local function add_history(dir)
  ensure_dir()
  local hist = read_history()
  local merged = { dir }
  for _, d in ipairs(hist) do
    if d ~= dir then
      table.insert(merged, d)
    end
  end
  vim.fn.writefile(merged, history_file)
end

-- claude-code 自身が記録している過去プロジェクト(~/.claude.json の projects キー)。
-- 大きいことがあるので jq があれば高速抽出、無ければ vim.json にフォールバック。
local function claude_known_projects()
  local cfg = vim.fn.expand("~/.claude.json")
  if vim.fn.filereadable(cfg) == 0 then
    return {}
  end
  if vim.fn.executable("jq") == 1 then
    local out = vim.fn.systemlist({ "jq", "-r", ".projects | keys[]?", cfg })
    if vim.v.shell_error == 0 then
      return out
    end
  end
  local ok, data = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(cfg), "\n"))
  end)
  if ok and type(data) == "table" and type(data.projects) == "table" then
    local out = {}
    for k in pairs(data.projects) do
      table.insert(out, k)
    end
    return out
  end
  return {}
end

-- そのプロジェクトで最後に claude を使った時刻(epoch秒)。
-- claude-code は ~/.claude/projects/<パスを-で連結> にログを置くので、その
-- フォルダの mtime を「最終利用時刻」として使う。無ければソケット/0 にフォールバック。
local function last_used(dir)
  local enc = dir:gsub("[^%w]", "-")
  local st = vim.uv.fs_stat(vim.fn.expand("~/.claude/projects/") .. enc)
  if st then
    return st.mtime.sec
  end
  local s2 = vim.uv.fs_stat(sock_for(dir))
  return s2 and s2.mtime.sec or 0
end

-- ピッカーに出す全プロジェクト: 自分の履歴と claude-code 既知プロジェクトを統合し、
-- 実在する dir のみを「最終利用時刻の新しい順」で返す。
local function all_projects()
  local out, seen = {}, {}
  local function add(dir)
    dir = vim.fn.fnamemodify(dir, ":p"):gsub("/$", "")
    if dir ~= "" and not seen[dir] and vim.fn.isdirectory(dir) == 1 then
      seen[dir] = true
      table.insert(out, dir)
    end
  end
  for _, d in ipairs(read_history()) do
    add(d)
  end
  for _, d in ipairs(claude_known_projects()) do
    add(d)
  end
  table.sort(out, function(a, b)
    return last_used(a) > last_used(b)
  end)
  return out
end

-- その dir に claude の過去会話ログ(.jsonl)があるか。
-- あれば停止中タスクの起動を --continue にして前回会話を引き継ぐ。
local function has_history(dir)
  local enc = dir:gsub("[^%w]", "-")
  local pdir = vim.fn.expand("~/.claude/projects/") .. enc
  return #vim.fn.glob(pdir .. "/*.jsonl", true, true) > 0
end

-- ソケットにリスナーが居る = タスク稼働中
local function is_live(sock)
  if not vim.uv.fs_stat(sock) then
    return false
  end
  return #vim.fn.systemlist({ "pgrep", "-f", sock }) > 0
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
  local sock = sock_for(dir)
  if not is_live(sock) and vim.uv.fs_stat(sock) then
    os.remove(sock)
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

  dir = vim.fn.fnamemodify(dir and dir ~= "" and dir or default_dir(), ":p")
  dir = dir:gsub("/$", "") -- 末尾スラッシュを正規化
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

-- 稼働中セッションへ入力を流し込む（dtach -p: stdin をセッションの pty に転送 = claude への入力）
local function push(sock, data)
  local job = vim.fn.jobstart({ "dtach", "-p", sock })
  if job <= 0 then
    return false
  end
  vim.fn.chansend(job, data)
  vim.fn.chanclose(job, "stdin")
  return true
end

-- タスクを終了。claude に正規の終了コマンド(/exit)を送り、claude 自身に状態を
-- 保存させてから抜けさせる。dtach マスタを kill すると claude が SIGHUP で強制
-- 終了し、会話が保存されず resume が効かなくなるため、それは避ける。
-- claude 終了 → dtach マスタ終了 → ソケット自動削除、の順で後片付けされる。履歴は残す。
function M.kill(dir)
  if not dir or dir == "" then
    return
  end
  dir = vim.fn.fnamemodify(dir, ":p"):gsub("/$", "")
  local sock = sock_for(dir)
  if not is_live(sock) then
    if vim.uv.fs_stat(sock) then
      os.remove(sock) -- 既に死んでいれば stale ソケットだけ掃除
    end
    return
  end
  -- まず ESC で生成中断/入力クリアして素のプロンプトへ → 少し待って /exit を実行
  push(sock, "\27")
  vim.defer_fn(function()
    push(sock, "/exit\r")
  end, 200)
end

-- 応答しなくなったタスクの強制終了（最終手段）。状態保存は期待できない。
function M.force_kill(dir)
  if not dir or dir == "" then
    return
  end
  dir = vim.fn.fnamemodify(dir, ":p"):gsub("/$", "")
  vim.fn.system({ "pkill", "-f", sock_for(dir) })
  os.remove(sock_for(dir))
end

-- Telescope: 履歴の dir 一覧（稼働状態付き）から選んで開く / C-x で kill
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

  local items = {}
  for _, dir in ipairs(all_projects()) do
    table.insert(items, { dir = dir, live = is_live(sock_for(dir)) })
  end

  pickers.new({}, {
    prompt_title = "Claude Tasks  (Enter: open / C-v: left split / C-f: float / C-x: exit&save / C-d: force-kill)",
    finder = finders.new_table({
      results = items,
      entry_maker = function(it)
        local mark = it.live and "● " or "○ "
        local short = vim.fn.fnamemodify(it.dir, ":~")
        -- 並びは all_projects() の最終利用時刻順を維持。ordinal はパスのみ(フィルタ用)
        return { value = it, display = mark .. short, ordinal = short }
      end,
    }),
    sorter = conf.generic_sorter({}),
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
          M.kill(sel.value.dir) -- claude に /exit を送って状態保存させてから終了
          actions.close(bufnr)
          -- claude が保存して抜けるまで少し待ってから一覧を更新（稼働状態が反映される）
          vim.defer_fn(M.pick, 1200)
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
