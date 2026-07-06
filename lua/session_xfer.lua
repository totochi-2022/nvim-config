-- session_xfer.lua
-- ターミナルで開いている nvim のセッション（バッファ/分割/タブ/cwd）を、
-- web版 nvim-server が起動している headless nvim インスタンスへ“そのまま”移す。
--
--   :ToServer [name]   現セッションを保存し、~/.cache/nvim-server/<name>.sock へ
--                      :source させる（name 省略時は nvim.sock を優先）。
--
-- nvim-server は ~/.cache/nvim-server/*.sock を listen する headless nvim を
-- 起動するため、--server <sock> --remote-send で :source を流し込めば復元できる。
-- undo履歴・ターミナルジョブは引き継がれない（mksession の仕様）。

local M = {}

local SERVER_DIR = vim.fn.expand("~/.cache/nvim-server")
local SESSION_FILE = SERVER_DIR .. "/xfer.vim"

-- 送信先候補の socket 一覧（自分自身と claude.sock は除外）
local function candidate_socks()
  local self = vim.v.servername or ""
  local socks = vim.fn.glob(SERVER_DIR .. "/*.sock", false, true)
  local out = {}
  for _, s in ipairs(socks) do
    if s ~= self and vim.fn.fnamemodify(s, ":t") ~= "claude.sock" then
      table.insert(out, s)
    end
  end
  return out
end

-- 一意な socket パスを作る（既存があれば -1, -2… を付ける）
local function unique_sock(base)
  local name, sock = base, SERVER_DIR .. "/" .. base .. ".sock"
  local i = 1
  while vim.fn.getftype(sock) ~= "" do
    name = base .. "-" .. i
    sock = SERVER_DIR .. "/" .. name .. ".sock"
    i = i + 1
  end
  return sock, name
end

-- 新しい headless nvim を <base>.sock で起動し、RPC を受け付けるまで待つ。
-- 成功で socket パスを返す（失敗は nil）。
local function spawn_session(base)
  vim.fn.mkdir(SERVER_DIR, "p")
  local sock = unique_sock(base)
  local id = vim.fn.jobstart(
    { vim.v.progpath, "--headless", "--listen", sock },
    { detach = true }
  )
  if id <= 0 then return nil end
  local ready = vim.wait(8000, function()
    local ok, ch = pcall(vim.fn.sockconnect, "pipe", sock, { rpc = true })
    if ok and ch and ch > 0 then
      pcall(vim.fn.chanclose, ch)
      return true
    end
    return false
  end, 100)
  if not ready then return nil end
  return sock
end

-- 送信先 socket を決める。既存の使用中セッションは上書きしない方針:
--   name あり: そのソケットが在れば使う／無ければ新規に <name>.sock を起こす
--   name なし: 毎回あたらしい term-HHMM セッションを起こす
local function resolve_target(name)
  if name and name ~= "" then
    local p = SERVER_DIR .. "/" .. name .. ".sock"
    if vim.fn.getftype(p) == "socket" then return p end
    return spawn_session(name)
  end
  return spawn_session(os.date("term-%H%M"))
end

function M.to_server(name)
  local target = resolve_target(name)
  if not target then
    vim.notify("送信先セッションを用意できませんでした（新規 nvim の起動に失敗）", vim.log.levels.ERROR)
    return
  end

  vim.fn.mkdir(SERVER_DIR, "p")

  -- レイアウトを“そのまま”残すための sessionoptions（terminal は除外）
  local saved = vim.o.sessionoptions
  vim.o.sessionoptions = "blank,buffers,curdir,folds,tabpages,winsize,winpos,help"
  local ok, err = pcall(vim.cmd, "mksession! " .. vim.fn.fnameescape(SESSION_FILE))
  vim.o.sessionoptions = saved
  if not ok then
    vim.notify("mksession 失敗: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  -- remote-send（キー入力扱い）は送信先が terminal モードだとジョブに吸われて
  -- 効かない。モード非依存の remote-expr + execute('source ...') で確実に流す。
  -- 送信元 nvim の実体は vim.v.progpath（PATH非依存）。
  local expr = string.format("execute('source %s')", SESSION_FILE)
  local target_name = vim.fn.fnamemodify(target, ":t")
  local err_lines = {}
  local id = vim.fn.jobstart(
    { vim.v.progpath, "--server", target, "--remote-expr", expr },
    {
      stderr_buffered = true,
      on_stderr = function(_, data)
        for _, l in ipairs(data or {}) do
          if l ~= "" then table.insert(err_lines, l) end
        end
      end,
      on_exit = function(_, code)
        if code == 0 and #err_lines == 0 then
          vim.notify("セッションを " .. target_name .. " へ転送しました", vim.log.levels.INFO)
        else
          vim.notify(
            "転送失敗（" .. target_name .. " / exit=" .. code .. "）\n"
              .. table.concat(err_lines, "\n"),
            vim.log.levels.ERROR
          )
        end
      end,
    }
  )
  if id <= 0 then
    vim.notify("転送プロセスを起動できませんでした（jobstart id=" .. id .. "）", vim.log.levels.ERROR)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("ToServer", function(o)
    M.to_server(o.args)
  end, {
    nargs = "?",
    complete = function()
      return vim.tbl_map(function(s)
        return (vim.fn.fnamemodify(s, ":t"):gsub("%.sock$", ""))
      end, candidate_socks())
    end,
    desc = "現セッションを web版 nvim-server インスタンスへ転送",
  })
end

return M
