-- 01_initial_setting.lua
require '01_initial_setting'

-- 02_option.lua
require '02_option'

-- 03_function.lua
require '03_function'

-- 11_plugin.lua
require '11_plugin'
vim.cmd [[autocmd BufWritePost 11_plugins.lua PackerCompile]]

-- 13_lsp.lua
require '13_lsp'

-- 14_autocmd.lua
require '14_autocmd'

-- 21_Keymap.lua
require '21_keymap'


-- RandomScheme()
