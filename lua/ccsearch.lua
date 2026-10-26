-- ccsearch.lua — 過去の Claude 会話・自分の発言・日記を検索する Telescope(:CCSearch)。
--
-- 検索・索引・退避は claude-plugin-system の `ccsearch`(~/.claude_plugin/scripts)が持ち、
-- ここは打った語を渡して結果を並べるだけ。
--   入力: スペース=AND / a|b=OR / @d 日記 @c 会話 @p 自分の発言 @w Web(claude.ai)
--   Enter: 読み取り専用で開く(既定。Claude は起動しない)
--          会話 → 全文を開き、ヒットした発言へ飛ぶ / 日記 → その見出しの行へ
--          今の窓が端末なら新しいタブで開く
--   C-t  : 新しいタブで読み取り専用で開く
--   C-o  : すぐ始める(会話 → Claude のセッションとして開く / Web → ブラウザ / 日記 → 編集できる状態で開く)
--   読み取り専用で開いたあと E で始める(会話 → Claude で開く / 日記 → 編集できるようにする)
-- :CCSearch web [--full]  Web(claude.ai)の会話を今すぐ取り込む(裏で実行、終わったら通知)
-- 変換/無変換+; / s → すぐ Telescope([F13 F13 F14])。
-- 変換/無変換+/ → `:CCSearch ` を出して Enter 前で止める(語を打つ / web と打つ)([F13 F13 F15])。
-- どちらも 21_keymap.lua の henkan_seq。
local M = {}

-- nvim-server(systemd user service)経由だと PATH に ~/.local/bin が無いことがあるので絶対パスも見る
local cs_cmd = vim.fn.exepath("ccsearch")
if cs_cmd == "" then
  cs_cmd = vim.fn.expand("~/.local/bin/ccsearch")
end

local HIT_MARK = "◀ ヒット" -- ccsearch read がヒットした発言の見出しに付ける目印

local function detail(id)
  local out = vim.fn.system({ cs_cmd, "show", "--json", tostring(id) })
  if vim.v.shell_error ~= 0 or out == "" then return nil end
  local ok, d = pcall(vim.json.decode, out)
  return ok and d or nil
end

local function show_buf(buf, tab)
  if tab or vim.bo.buftype == "terminal" then
    vim.cmd("tab sbuffer " .. buf)
  else
    vim.api.nvim_win_set_buf(0, buf)
  end
end

-- 会話を Claude のセッションとして開く(ログが消えていれば退避から戻してから)。
-- Web(claude.ai)の会話は Claude Code では開けないので、ブラウザでその会話を開く
local function start_convo(d)
  if d.source == "web" then
    vim.ui.open(d.url)
    return
  end
  if not d.alive then
    local msg = vim.fn.system({ cs_cmd, "restore", d.session })
    if vim.v.shell_error ~= 0 then
      vim.notify("戻せませんでした: " .. msg, vim.log.levels.WARN)
      return
    end
  end
  require("claude_tasks").open_session(d.project, d.session)
end

-- 日記を開く。edit=false なら読み取り専用(E で編集できるようにする)。
-- 既に読み込まれている(編集中かもしれない)日記は読み取り専用にしない
local function open_diary(d, tab, edit)
  local buf = vim.fn.bufadd(d.project)
  local was_loaded = vim.api.nvim_buf_is_loaded(buf)
  vim.fn.bufload(buf)
  vim.bo[buf].buflisted = true
  if not edit and not was_loaded then
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true
    vim.keymap.set("n", "E", function()
      vim.bo[buf].modifiable = true
      vim.bo[buf].readonly = false
      pcall(vim.keymap.del, "n", "E", { buffer = buf })
      vim.notify("編集できるようにしました")
    end, { buffer = buf, desc = "ccsearch: 編集を始める" })
  end
  show_buf(buf, tab)
  pcall(vim.api.nvim_win_set_cursor, 0, { d.line or 1, 0 })
  vim.cmd("normal! zt")
end

-- Vivify で見るときだけ書き出す共通の 1 ファイル(毎回上書き=増えない。Vivify は変更で再読み込み)
local VIEW_FILE = vim.fn.expand("~/.cache/ccsearch/view.md")

local function view_in_vivify(buf)
  vim.fn.mkdir(vim.fn.fnamemodify(VIEW_FILE, ":h"), "p")
  vim.fn.writefile(vim.api.nvim_buf_get_lines(buf, 0, -1, false), VIEW_FILE)
  require("vivify").open_path(VIEW_FILE)
end

-- 会話の全文を読み取り専用バッファ(ファイル無し)で開く(E で Claude のセッションとして開く)。
-- 同じセッションならバッファを使い回す
local function read_convo(id, tab)
  local lines = vim.fn.systemlist({ cs_cmd, "read", tostring(id) })
  if vim.v.shell_error ~= 0 or #lines == 0 then
    vim.notify("会話を読めませんでした", vim.log.levels.WARN)
    return
  end
  local name = "ccsearch://" .. (lines[1]:match("session (%x+)") or tostring(id))
  local buf = vim.fn.bufnr(name)
  local fresh = buf == -1
  if fresh then
    buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(buf, name)
    vim.bo[buf].bufhidden = "hide"
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "markdown"
  vim.b[buf].ccsearch_id = id
  if fresh then
    -- filetype=markdown の autocmd が張る ,,v / mp(今のファイルを Vivify)を、書き出して開く版で上書き
    local function map(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = buf, desc = desc })
    end
    map("E", function()
      local d = detail(vim.b[buf].ccsearch_id)
      if d then start_convo(d) end
    end, "ccsearch: このセッションを Claude で開く")
    map(",,v", function() view_in_vivify(buf) end, "ccsearch: Vivify で見る")
    map("mp", function() view_in_vivify(buf) end, "ccsearch: Vivify で見る")
  end
  show_buf(buf, tab)
  for i, l in ipairs(lines) do
    if l:find(HIT_MARK, 1, true) then
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      vim.cmd("normal! zt")
      break
    end
  end
end

function M.pick(query)
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("telescope が利用できません", vim.log.levels.WARN)
    return
  end
  local finders = require("telescope.finders")
  local sorters = require("telescope.sorters")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  -- 打つたびに ccsearch q を走らせ直す(live_grep と同じ仕組み)。並びは ccsearch の新しい順のまま
  -- 行: "<id>\t<日時>\t<印>\t<場所>\t<id/ファイル名>\t<抜粋>"
  local finder = finders.new_job(function(prompt)
    if not prompt or vim.trim(prompt):len() < 2 then return nil end
    return vim.list_extend({ cs_cmd, "q" }, vim.split(vim.trim(prompt), "%s+"))
  end, function(line)
    local id, ts, mark, where, _, snippet = line:match("^(%d+)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t(.*)$")
    if not id then return nil end
    return {
      value = tonumber(id),
      display = ("%s %s  %s │ %s"):format(mark, ts:sub(6), where, snippet),
      ordinal = line,
    }
  end)

  local previewer = previewers.new_buffer_previewer({
    title = "前後の会話 / 日記",
    define_preview = function(self, entry)
      local lines = vim.fn.systemlist({ cs_cmd, "show", tostring(entry.value) })
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
      vim.bo[self.state.bufnr].filetype = "markdown"
      vim.wo[self.state.winid].wrap = true
    end,
  })

  -- how: "read"(読み取り専用) / "tab"(新しいタブで読み取り専用) / "start"(すぐ始める)
  local function run(prompt_bufnr, how)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    if not entry then return end
    local d = detail(entry.value)
    if not d then
      vim.notify("詳細を読めませんでした", vim.log.levels.WARN)
      return
    end
    if d.source == "diary" then
      open_diary(d, how == "tab", how == "start")
    elseif how == "start" then
      start_convo(d)
    else
      read_convo(entry.value, how == "tab")
    end
  end

  pickers.new({}, {
    prompt_title = "過去の会話・日記  (空白=AND  a|b=OR  @d 日記 @c 会話 @p 発言 @w Web / Enter: 読む  C-t: タブで  C-o: すぐ始める / 開いた後 E で始める)",
    default_text = query or "",
    finder = finder,
    sorter = sorters.highlighter_only({}),
    previewer = previewer,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function() run(prompt_bufnr, "read") end)
      map({ "i", "n" }, "<C-t>", function() run(prompt_bufnr, "tab") end)
      map({ "i", "n" }, "<C-o>", function() run(prompt_bufnr, "start") end)
      return true
    end,
  }):find()
end

-- Web の会話を今すぐ取り込む(裏で実行。終わったら結果を通知)
function M.web(full)
  vim.notify("ccsearch: Web の会話を取り込み中…")
  vim.system({ cs_cmd, "web", full and "--full" or nil }, { text = true }, function(res)
    vim.schedule(function()
      local msg = vim.trim(res.stderr or "")
      vim.notify("ccsearch: " .. (msg ~= "" and msg or "完了"),
        res.code == 0 and vim.log.levels.INFO or vim.log.levels.WARN)
    end)
  end)
end

-- コマンドラインに `:CCSearch ` を出して Enter 前で止める(どのモードからでも)。
-- ; と : を入れ替えた設定でも効くよう、割り当てを通さず(n)本物の : を送る。
-- i: 直後に打たれて溜まっているキーより前に差し込む(後ろに足すと語が先に処理される)
function M.prompt()
  local mode = vim.fn.mode()
  local lead = mode == "t" and "<C-\\><C-n>" or (mode:match("^[iR]") and "<Esc>" or "")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lead .. ":CCSearch ", true, false, true), "ni", false)
end

function M.setup()
  vim.api.nvim_create_user_command("CCSearch", function(o)
    local a = vim.trim(o.args)
    if a == "web" or a == "web --full" then
      M.web(a == "web --full")
    else
      M.pick(a)
    end
  end, {
    nargs = "*",
    desc = "過去の Claude 会話・日記を検索 (ccsearch) / web で Web の会話を取り込む",
    complete = function(lead, line)
      if line:match("^%s*CCSearch%s+%S*$") then
        return vim.tbl_filter(function(w) return w:find(lead, 1, true) == 1 end, { "web", "@d", "@c", "@p", "@w" })
      end
      return {}
    end,
  })
end

return M
