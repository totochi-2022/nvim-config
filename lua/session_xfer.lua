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

-- name(ベース名) または既定ルールで送信先 socket を決める
local function resolve_target(name)
  if name and name ~= "" then
    local p = SERVER_DIR .. "/" .. name .. ".sock"
    return vim.fn.filereadable(p) == 1 and p or nil, p
  end
  local cands = candidate_socks()
  -- nvim.sock を優先、無ければ最初の候補
  for _, s in ipairs(cands) do
    if vim.fn.fnamemodify(s, ":t") == "nvim.sock" then return s end
  end
  return cands[1]
end

function M.to_server(name)
  local target, wanted = resolve_target(name)
  if not target then
    vim.notify(
      "送信先 socket が見つかりません" .. (wanted and ("（" .. wanted .. "）") or "")
        .. "\n候補: " .. table.concat(vim.tbl_map(function(s)
          return vim.fn.fnamemodify(s, ":t")
        end, candidate_socks()), ", "),
      vim.log.levels.WARN
    )
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
