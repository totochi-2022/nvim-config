-- plugins/typst.lua - Typst プレビュー
-- typst-preview.nvim: tinymist を使った増分ライブプレビュー（mkdp の Typst 版）。
-- 既定ではブラウザを開くが、nvim-server 経由のときは右ペインに横取りしたい。
-- そのため open_cmd を後段で差し替える前提で導入しておく（フック実装は別途）。
return {
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    init = function()
      -- typst/tinymist は既定で CJK フォントを持たず日本語が化けるので、
      -- Windows 側のユーザーフォント(Cica 等)を見せて自動フォールバックさせる。
      -- tinymist は nvim の環境変数を継承する。
      local paths = vim.fn.glob(
        "/mnt/c/Users/*/AppData/Local/Microsoft/Windows/Fonts",
        true,
        true
      )
      if #paths > 0 then
        local cur = vim.env.TYPST_FONT_PATHS
        vim.env.TYPST_FONT_PATHS = table.concat(paths, ":")
          .. (cur and (":" .. cur) or "")
      end
    end,
    -- tinymist / typst-preview のバイナリを取得
    build = function()
      require("typst-preview").update()
    end,
    config = function()
      require("typst-preview").setup({})

      -- nvim-server(web) 接続中はプレビュー URL を右ペインへ横取りし、
      -- 端末/Neovide では従来どおり実ブラウザで開く（mkdp と同じ dual-mode）。
      local ok, u = pcall(require, "typst-preview.utils")
      if ok and not u._nvim_server_patched then
        u._nvim_server_patched = true
        local orig = u.visit
        u.visit = function(link)
          local ch = vim.g.nvim_server_channel
          if type(ch) == "number" and ch > 0 then
            vim.rpcnotify(ch, "web_open_url", "http://" .. link, "Typst Preview")
          else
            orig(link)
          end
        end
      end
    end,
  },
}
