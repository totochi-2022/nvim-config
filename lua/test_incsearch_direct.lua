-- incsearch直接テスト

print("=== Direct Incsearch Test ===")

-- 1. 現在のマッピング状態を詳細に確認
print("\n1. Detailed mapping check:")
local slash_map = vim.api.nvim_get_keymap('')
for _, map in ipairs(slash_map) do
    if map.lhs == '/' or map.lhs == '?' then
        print(string.format("  %s -> %s (mode: %s)", map.lhs, map.rhs or map.callback or "unknown", map.mode))
    end
end

-- 2. incsearchの内部設定を確認
print("\n2. Incsearch internal settings:")
print("  vim.g.incsearch#auto_nohlsearch = " .. tostring(vim.g['incsearch#auto_nohlsearch']))
print("  vim.g.incsearch#consistent_n_direction = " .. tostring(vim.g['incsearch#consistent_n_direction']))
print("  vim.g.incsearch#do_not_save_error_message = " .. tostring(vim.g['incsearch#do_not_save_error_message']))

-- 3. 既存のmigemo関数を呼び出してみる
print("\n3. Call existing migemo function:")
if vim.fn.exists('*s:migemo_mapping') == 1 then
    print("  s:migemo_mapping exists")
else
    print("  s:migemo_mapping not found")
end

-- 4. 03_function.luaで定義された関数を使う
print("\n4. Try using defined function:")
vim.cmd('call s:migemo_toggle()')
print("  After toggle, vim.g.incsearch_use_migemo = " .. tostring(vim.g.incsearch_use_migemo))
print("  / is mapped to: " .. vim.fn.maparg('/', ''))

print("\n=== Test Complete ===")