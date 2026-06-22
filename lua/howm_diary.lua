-- howm_diary.lua
-- telekasten の「1日1ファイル」日次ノートに対し、howm 本来の「時刻付きで
-- 書き散らす」エントリ単位ノートを足すローカル拡張。
--
--   ,,n : 新しい日記エントリを作成（daily/ に YYYY-MM-DD-HHMM.md を作って insert 開始）
--
-- 各エントリは独立した .md なので、telekasten の [[ ]] / バックリンク、
-- howm_link の come-from(<<<) 宿主、全文検索・タグ(#diary) の対象になる。
-- 日次インデックス(YYYY-MM-DD.md, ,,d=goto_today)とは同居させ、日付順に並べる。

local M = {}

-- 日記エントリの保管先 = telekasten の dailies と同じ daily/ ディレクトリ
local function daily_dir()
  local d = vim.g.dir_setting and vim.g.dir_setting.howm
  d = d and vim.fn.expand(d) or vim.fn.getcwd()
  return d .. "/daily"
end

-- 同分内に既存があれば -1, -2 ... を付けて衝突回避（連番フォールバック）
local function unique_path(dir, base, ext)
  local path = dir .. "/" .. base .. ext
  if vim.fn.filereadable(path) == 0 then
    return path
  end
  local n = 1
  while vim.fn.filereadable(dir .. "/" .. base .. "-" .. n .. ext) == 1 do
    n = n + 1
  end
  return dir .. "/" .. base .. "-" .. n .. ext
end

-- 新しい日記エントリを作成して開く
function M.new_entry()
  local dir = daily_dir()
  vim.fn.mkdir(dir, "p")

  local base = os.date("%Y-%m-%d-%H%M")      -- ファイル名: 時刻ベース
  local heading = os.date("%Y-%m-%d %H:%M")  -- 見出し: 読みやすい形
  local path = unique_path(dir, base, ".md")

  vim.cmd("edit " .. vim.fn.fnameescape(path))

  -- 空の新規バッファにだけテンプレートを流し込む（既存を開いた場合は触らない）
  if vim.api.nvim_buf_line_count(0) == 1 and vim.fn.getline(1) == "" then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "# " .. heading,
      "#diary",
      "",
      "",
    })
    vim.api.nvim_win_set_cursor(0, { 4, 0 })
    vim.cmd("startinsert")
  end
end

function M.setup()
  vim.api.nvim_create_user_command("HowmDiary", function()
    M.new_entry()
  end, { desc = "新しい日記エントリを作成(時刻ファイル)" })
end

return M
