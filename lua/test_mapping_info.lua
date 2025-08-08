-- マッピング情報の詳細確認

print("=== Mapping Info Test ===")

-- 現在のコマンドラインモードのマッピングを確認
print("\n[Command-line mode mappings]")
local cmaps = vim.api.nvim_get_keymap('c')
print("Total command-line mappings: " .. #cmaps)

-- rhsが存在しないマッピングを探す
print("\n[Mappings without rhs]")
local count = 0
for _, map in ipairs(cmaps) do
    if not map.rhs or map.rhs == "" then
        count = count + 1
        print(string.format("  %s: callback=%s, expr=%s", 
            map.lhs, 
            tostring(map.callback ~= nil),
            tostring(map.expr == 1)
        ))
    end
end
print("Mappings without rhs: " .. count)

-- 通常モードの / と ? マッピングを確認
print("\n[Normal mode / and ? mappings]")
local normal_maps = vim.api.nvim_get_keymap('')
for _, map in ipairs(normal_maps) do
    if map.lhs == '/' or map.lhs == '?' then
        print(string.format("  %s -> rhs='%s', callback=%s", 
            map.lhs, 
            map.rhs or "", 
            tostring(map.callback ~= nil)
        ))
    end
end

print("\n=== Test Complete ===")