-- howm_link.lua
-- telekasten(markdown) に howm 風の come-from(<<<) 連想リンクを足すローカル拡張。
-- telekasten 本体には触れず、vault を ripgrep(telescope) して開くだけの薄い実装。
--
--   ,,a : カーソル下(or 選択)の語の come-from 宿主ノート(= "<<< 語" がある行)へ飛ぶ
--   ,,A : 現在位置に come-from 宣言 "<<< 語" を挿入（このノートを語の宿主にする）
--
-- howm の <<< / >>> はただのテキストなので、telekasten の [[ ]] と同じ .md に共存できる。
-- 宿主に "<<< 仕事" と1回書けば、他のノートで「仕事」を ,,a するとここへ辿れる
-- ＝ howm のタグ/カテゴリ相当（come-from キーワード）を telekasten 上で実現する。

local M = {}

-- vault(メモ保管先) = telekasten と同じ home（実行時に読むので常に同期）
local function vault()
  local d = vim.g.dir_setting and vim.g.dir_setting.howm
  return d and vim.fn.expand(d) or vim.fn.getcwd()
end

-- ripgrep(Rust正規表現)用にメタ文字をエスケープ
local function rg_escape(s)
  return (s:gsub("[%.%+%*%?%(%)%[%]%{%}%^%$|\\]", "\\%0"))
end

-- 対象キーワードを取得（visual=選択文字列 / normal=カーソル下の語）
local function target(visual)
  if visual then
    local s, e = vim.fn.getpos("'<"), vim.fn.getpos("'>")
    local lines = vim.fn.getline(s[2], e[2])
    if type(lines) ~= "table" then
      lines = { lines }
    end
    if #lines == 0 then
      return ""
    end
    if #lines == 1 then
      return vim.trim(string.sub(lines[1], s[3], e[3]))
    end
    return vim.trim(table.concat(lines, " "))
  end
  return vim.fn.expand("<cword>")
end

-- come-from 宿主へ飛ぶ: vault から "<<< 語" を探して telescope で開く
function M.follow(visual)
  local word = target(visual)
  if word == "" then
    vim.notify("キーワードがありません", vim.log.levels.WARN)
    return
  end
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("telescope が利用できません", vim.log.levels.WARN)
    return
  end
  builtin.grep_string({
    prompt_title = "come-from: " .. word,
    search = "<<<\\s*" .. rg_escape(word),
    use_regex = true,
    search_dirs = { vault() },
  })
end

-- come-from 宣言を挿入: 現在行の下に "<<< 語" を置く（このノートを語の宿主にする）
function M.declare(visual)
  local word = target(visual)
  if word == "" then
    vim.notify("キーワードがありません", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_put({ "<<< " .. word }, "l", true, true)
  vim.notify("come-from 宣言: <<< " .. word)
end

function M.setup()
  vim.api.nvim_create_user_command("HowmFollow", function()
    M.follow(false)
  end, { desc = "come-from 宿主ノートへ飛ぶ(カーソル語)" })
  vim.api.nvim_create_user_command("HowmDeclare", function()
    M.declare(false)
  end, { desc = "come-from 宣言 <<< を挿入(カーソル語)" })
end

return M
