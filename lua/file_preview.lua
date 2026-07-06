-- file_preview.lua
-- nvim-server の自作プレビューア（preview.html, dispatch型）を呼ぶ薄いコマンド。
-- 拡張子で種類を判定し、web 接続中は右ペインへ（web_open_url）、端末では xdg-open。
-- 対応: svg / csv(グラフ) / stl(3D) / dxf(2D CAD)

local M = {}

local SUPPORTED = { svg = "svg", csv = "csv", stl = "stl", dxf = "dxf" }

-- 端末フォールバック用の「ファイルを開く」コマンド（WSL は wslview）
local function opener()
  for _, c in ipairs({ "wslview", "xdg-open", "explorer.exe", "open" }) do
    if vim.fn.executable(c) == 1 then
      return c
    end
  end
  return nil
end

-- URL クエリ用に最小限の percent-encode（パス区切り / は残す）
local function urienc(s)
  return (s:gsub("[^%w%-%._~/]", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

-- 専用プレビューア（プラグイン）に委譲する。lazy で ft 遅延ロードされる構成で、
-- 特に markdown-preview.nvim はコマンドを「command! -buffer」かつ FileType autocmd
-- 経由で登録するため、lazy ロード直後は当該バッファにコマンドがまだ無い。
-- そこで: 明示ロード → FileType を再発火してバッファローカルコマンドを登録 → 実行、
-- それでも無ければ autoload 関数を直接叩く、の順でフォールバックする。
local function delegate(plugin, cmd, label, fallback_fn)
  if vim.fn.exists(":" .. cmd) ~= 2 then
    pcall(function()
      require("lazy").load({ plugins = { plugin } })
    end)
    -- プラグインの BufEnter/FileType autocmd を当該バッファで発火させる
    pcall(vim.cmd, "doautocmd <nomodeline> FileType")
  end
  if vim.fn.exists(":" .. cmd) == 2 then
    vim.cmd(cmd)
    return
  end
  -- コマンドがまだ無い場合の最終手段（autoload 関数の直接呼び出し）
  if fallback_fn and vim.fn.exists("*" .. fallback_fn) == 1 then
    pcall(vim.fn[fallback_fn])
    return
  end
  vim.notify(label .. " を読み込めませんでした（" .. plugin .. "）", vim.log.levels.WARN)
end

function M.preview()
  -- markdown / typst は各専用プレビューアへ委譲（このプレビューアの発祥である markdown も含む）
  local ft = vim.bo.filetype
  if ft == "markdown" then
    -- 標準ビューアは Vivify（mkdp は ,,V / :MarkdownPreview で明示的に使う）
    require("vivify").open()
    return
  end
  if ft == "typst" then
    delegate("typst-preview.nvim", "TypstPreview", "Typst プレビュー")
    return
  end

  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("ファイルが保存されていません", vim.log.levels.WARN)
    return
  end
  local ext = vim.fn.expand("%:e"):lower()
  local kind = SUPPORTED[ext]
  if not kind then
    vim.notify(
      "プレビュー未対応: ." .. ext .. "（md/typst/svg/csv/stl/dxf）",
      vim.log.levels.WARN
    )
    return
  end

  local url = "/preview.html?kind=" .. kind .. "&path=" .. urienc(path)
  local ch = vim.g.nvim_server_channel
  if type(ch) == "number" and ch > 0 then
    -- web(nvim-server): 右ペインへ
    vim.rpcnotify(ch, "web_open_url", url, kind:upper() .. " Preview")
  else
    -- 端末/Neovide: 実ブラウザ/既定アプリで開く
    local op = opener()
    if op then
      vim.fn.jobstart({ op, path }, { detach = true })
    else
      vim.notify("プレビューを開けません（web未接続で opener も無し）", vim.log.levels.WARN)
    end
  end
end

-- ,,V 用: markdown-preview を明示的に開く（従来の md 分岐＝mkdp 委譲を保持）
function M.markdown_preview()
  delegate("markdown-preview.nvim", "MarkdownPreviewToggle", "Markdown プレビュー", "mkdp#util#toggle_preview")
end

function M.setup()
  vim.api.nvim_create_user_command("Preview", function()
    M.preview()
  end, { desc = "ファイルを右ペインでプレビュー(svg/csv/stl/dxf)" })
end

return M
