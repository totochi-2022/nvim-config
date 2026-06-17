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

function M.preview()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("ファイルが保存されていません", vim.log.levels.WARN)
    return
  end
  local ext = vim.fn.expand("%:e"):lower()
  local kind = SUPPORTED[ext]
  if not kind then
    vim.notify(
      "プレビュー未対応: ." .. ext .. "（svg/csv/stl/dxf）",
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

function M.setup()
  vim.api.nvim_create_user_command("Preview", function()
    M.preview()
  end, { desc = "ファイルを右ペインでプレビュー(svg/csv/stl/dxf)" })
end

return M
