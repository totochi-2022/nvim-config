-- migemoトグルのデバッグスクリプト

print("=== Migemo Toggle Debug ===")

-- 1. プラグインの存在確認
print("\n1. Plugin check:")
print("  incsearch-migemo-/ mapping exists: " .. vim.fn.maparg('<Plug>(incsearch-migemo-/)', ''))
print("  incsearch-migemo-? mapping exists: " .. vim.fn.maparg('<Plug>(incsearch-migemo-?)', ''))
print("  incsearch-forward mapping exists: " .. vim.fn.maparg('<Plug>(incsearch-forward)', ''))
print("  incsearch-backward mapping exists: " .. vim.fn.maparg('<Plug>(incsearch-backward)', ''))

-- 2. 現在の変数値
print("\n2. Current variable values:")
print("  vim.g.incsearch_use_migemo = " .. tostring(vim.g.incsearch_use_migemo))

-- 3. 現在のキーマップ
print("\n3. Current key mappings:")
print("  / is mapped to: " .. vim.fn.maparg('/', ''))
print("  ? is mapped to: " .. vim.fn.maparg('?', ''))

-- 4. 手動でキーマップを設定してテスト
print("\n4. Manual keymap test:")

-- まずmigemoモードに設定
print("  Setting migemo mode manually...")
vim.g.incsearch_use_migemo = 1
vim.api.nvim_set_keymap('', '/', '<Plug>(incsearch-migemo-/)', { silent = true })
vim.api.nvim_set_keymap('', '?', '<Plug>(incsearch-migemo-?)', { silent = true })
print("  / is now mapped to: " .. vim.fn.maparg('/', ''))
print("  ? is now mapped to: " .. vim.fn.maparg('?', ''))

-- 通常モードに戻す
print("\n  Setting normal mode manually...")
vim.g.incsearch_use_migemo = 0
vim.api.nvim_set_keymap('', '/', '<Plug>(incsearch-forward)', { silent = true })
vim.api.nvim_set_keymap('', '?', '<Plug>(incsearch-backward)', { silent = true })
print("  / is now mapped to: " .. vim.fn.maparg('/', ''))
print("  ? is now mapped to: " .. vim.fn.maparg('?', ''))

-- 5. toggle定義から実行
print("\n5. Testing via toggle definition:")
local toggle_config = require('22_toggle')
local migemo_def = toggle_config.definitions.m

print("  Initial state: " .. migemo_def.get_state())
print("  Setting to 'on'...")
migemo_def.set_state('on')
print("  State after set: " .. migemo_def.get_state())
print("  / is mapped to: " .. vim.fn.maparg('/', ''))

print("\n=== Debug Complete ===")