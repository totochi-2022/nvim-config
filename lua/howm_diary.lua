-- howm_diary.lua
-- telekasten の「1日1ファイル」日次ノートに対し、howm 本来の「時刻付きで
-- 書き散らす」エントリ単位ノートを足すローカル拡張。
--
--   ,,n : 新しい日記エントリを作成（daily/ に YYYY-MM-DD-HHMM-<host>.md を作って insert 開始）
--         ファイル名にホスト名を付けるのは、複数端末から同じ git リポジトリに書いても
--         ファイルが衝突せず（＝同一ファイルの二重編集が起きず）pull/push できるようにするため。
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

  local host = (vim.uv or vim.loop).os_gethostname()    -- マシン名（端末間の衝突防止）
  local base = os.date("%Y-%m-%d-%H%M") .. "-" .. host  -- ファイル名: 時刻+ホスト
  local heading = os.date("%Y-%m-%d %H:%M")  -- 見出し: 読みやすい形（ホストは付けない）
  local path = unique_path(dir, base, ".md")

  vim.cmd("edit " .. vim.fn.fnameescape(path))

  -- 作成したファイルのフルパスをクリップボードへコピー
  local fullpath = vim.fn.fnamemodify(path, ":p")
  vim.fn.setreg("+", fullpath)
  vim.notify("コピー: " .. fullpath, vim.log.levels.INFO)

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

-- 最新の日記エントリを開く。
-- daily/ の時刻付きエントリ(YYYY-MM-DD-HHMM[-host].md)だけを対象にし、
-- ファイル名は時刻プレフィックスで辞書順 = 時系列順なので名前最大 = 最新。
-- (日次インデックス YYYY-MM-DD.md は ,,d で開けるのでここでは除外する)
function M.open_latest()
  local dir = daily_dir()
  local files = vim.fn.glob(dir .. "/*.md", true, true)
  local latest
  for _, f in ipairs(files) do
    local name = vim.fn.fnamemodify(f, ":t")
    if name:match("^%d%d%d%d%-%d%d%-%d%d%-%d%d%d%d") then
      if not latest or name > vim.fn.fnamemodify(latest, ":t") then
        latest = f
      end
    end
  end
  if not latest then
    vim.notify("日記エントリが見つかりません: " .. dir, vim.log.levels.WARN)
    return
  end
  vim.cmd("edit " .. vim.fn.fnameescape(latest))
end

-- 日記リポジトリをバックグラウンドで同期（howm/tools/sync.sh を叩く）。
-- cron(5:00/20:00) だけだと WSL 停止中の回を取りこぼすので、起動時にも一発走らせる保険。
-- 非ブロッキング・出力無視のファイア&フォーゲット。スクリプトが無ければ何もしない。
function M.sync_async()
  local howm = vim.g.dir_setting and vim.g.dir_setting.howm
  if not howm then return end
  local script = vim.fn.expand(howm) .. "/tools/sync.sh"
  if vim.fn.filereadable(script) == 0 then return end
  vim.fn.jobstart({ "bash", script }, { detach = true })
end

function M.setup()
  vim.api.nvim_create_user_command("HowmDiary", function()
    M.new_entry()
  end, { desc = "新しい日記エントリを作成(時刻ファイル)" })

  vim.api.nvim_create_user_command("HowmDiaryLatest", function()
    M.open_latest()
  end, { desc = "最新の日記エントリを開く" })

  -- 起動時に 1 回だけ同期（取りこぼし対策）。
  -- setup() が VimEnter 後に呼ばれる（遅延ロード等）と once autocmd は取り逃すので、
  -- 既に起動済みなら即実行、まだなら VimEnter を待つ、の両対応にする。
  if vim.v.vim_did_enter == 1 then
    M.sync_async()
  else
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function() M.sync_async() end,
      desc = "howm 日記リポジトリを起動時に同期",
    })
  end
end

return M
