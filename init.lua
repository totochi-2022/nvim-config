-- 最低限必要な設定のみを即時ロード
vim.loader.enable()
require('01_initial_setting')
require('02_option')

-- その他は遅延ロード
vim.defer_fn(function()
    require('00_loader')
end, 0)
