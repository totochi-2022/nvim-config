-- Neovim初期化設定
vim.loader.enable()

-- 基本設定の即時ロード
require('01_initial_setting')
require('02_option')

-- その他の設定は順序を保持して遅延ロード
vim.defer_fn(function()
    require('00_loader')
end, 0)
