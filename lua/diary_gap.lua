-- diary_gap.lua — 1 日の振り返り(diary-gap が毎朝 6 時に作るレポート)を見る。
-- 実体は claude-plugin-system の `diary-gap`(~/.claude_plugin/scripts)。レポートは ~/.local/share/diary-gap/。
-- 見るだけなら Claude は起こさない: サマリーの節と未処理の件数を nvim のバッファに出す。
-- 日記にする(候補を選ぶ)時だけ、そのバッファの c で日記フォルダの Claude を開いて /diary-gap。
-- 起動画面(dashboard)の d と :DiaryGap から呼ぶ。
local M = {}

local DIARY_DIR = vim.fn.expand("~/.config/nvim/data/howm")

-- 最新レポート → { lines, n = 未処理の件数, conflicts = 食い違いの件数, day = "MM-DD" }。無ければ nil
-- 未処理 = 「日記にした方がいい項目」の見出し(### N.)のうち ✅ 日記済み / ⏭ 見送り の印が無いもの
function M.state()
  local path = vim.fn.systemlist({ "diary-gap", "--latest" })[1]
  if vim.v.shell_error ~= 0 or not path then
    return nil
  end
  local lines = vim.fn.readfile(path)
  local n, conflicts, sec = 0, 0, ""
  for _, l in ipairs(lines) do
    if l:match("^## ") then
      sec = l
    elseif l:match("^### %d+%.") and not l:find("✅", 1, true) and not l:find("⏭", 1, true) then
      n = n + 1
    elseif sec == "## 日記と食い違っているもの" and l:match("^%- ") then
      conflicts = conflicts + 1
    end
  end
  return { lines = lines, n = n, conflicts = conflicts, day = vim.fn.fnamemodify(path, ":t:r"):sub(6, 10) }
end

-- 起動画面の項目名
function M.label()
  local g = M.state()
  if not g then
    return "󰃭 振り返り"
  end
  return g.n > 0 and ("󰃭 振り返り %d件 (%s)"):format(g.n, g.day) or ("󰃭 振り返り 済 (%s)"):format(g.day)
end

-- 日記にする: 日記フォルダで Claude を開いて /diary-gap(候補の一覧・日記化・印付けは Claude 側)
function M.claude()
  require("claude_tasks").open_prompt(DIARY_DIR, "/diary-gap")
end

-- サマリーの節と未処理の件数をバッファに出す(Claude は起こさない)
function M.open()
  local g = M.state()
  if not g then
    vim.notify("振り返りのレポートがまだありません(毎朝 6 時に diary-gap が作る)", vim.log.levels.INFO)
    return
  end
  local out, on = {}, false
  for _, l in ipairs(g.lines) do
    if l:match("^# ") then
      out[#out + 1] = l
    end
    if l:match("^## ") then
      on = (l == "## サマリー")
    end
    if on then
      out[#out + 1] = l
    end
  end
  out[#out + 1] = ""
  out[#out + 1] = g.n > 0 and ("日記にした方がいい項目: 未処理 %d 件"):format(g.n) or "日記にした方がいい項目: 済"
  if g.conflicts > 0 then
    out[#out + 1] = ("日記と食い違っているもの: %d 件"):format(g.conflicts)
  end
  out[#out + 1] = ""
  out[#out + 1] = "c: Claude で日記にする(/diary-gap)   q: 閉じる"
  vim.cmd("enew")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
  vim.bo.buftype, vim.bo.bufhidden, vim.bo.filetype = "nofile", "wipe", "markdown"
  vim.bo.modifiable = false
  vim.keymap.set("n", "c", M.claude, { buffer = true, desc = "振り返り: Claude で日記にする" })
  vim.keymap.set("n", "q", "<Cmd>bwipeout<CR>", { buffer = true, desc = "振り返り: 閉じる" })
end

vim.api.nvim_create_user_command("DiaryGap", M.open, { desc = "1 日の振り返り(サマリー)を見る" })

return M
