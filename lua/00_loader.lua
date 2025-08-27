-- 01_initial_setting.lua
require '01_initial_setting'

-- 02_option.lua
require '02_option'

-- 11_plugin.lua
require '11_plugin'

-- 12_function.lua（プラグイン読み込み後に実行）
require '12_function'
-- vim.cmd [[autocmd BufWritePost 11_plugins.lua PackerCompile]]

-- 13_lsp.lua
require '13_lsp'

-- 14_autocmd.lua
require '14_autocmd'

-- 14_autocmd.lua
require '15_dap'

-- 21_Keymap.lua
require '21_keymap'

-- 22_toggle.lua (新トグルシステム)
require '22_toggle'

-- 23_cheatsheet.lua (チートシートシステム)
require '23_cheatsheet'

-- 31_startup.lua (最終起動処理)
require '31_startup'

-- RandomScheme()
