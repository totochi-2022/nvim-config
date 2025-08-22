-- cursorcolumn test script

print("=== cursorcolumn test ===")

-- 現在の状態を確認
print("Initial state:")
print("vim.o.cursorcolumn =", vim.o.cursorcolumn)

-- ONにする
print("\nSetting cursorcolumn ON...")
vim.cmd('set cursorcolumn')
print("After 'set cursorcolumn':")
print("vim.o.cursorcolumn =", vim.o.cursorcolumn)

-- OFFにする
print("\nSetting cursorcolumn OFF...")
vim.cmd('set nocursorcolumn')
print("After 'set nocursorcolumn':")
print("vim.o.cursorcolumn =", vim.o.cursorcolumn)

-- 再度ONにする
print("\nSetting cursorcolumn ON again...")
vim.cmd('set cursorcolumn')
print("After 'set cursorcolumn' again:")
print("vim.o.cursorcolumn =", vim.o.cursorcolumn)



-- OFFにする
print("\nSetting cursorcolumn OFF...")
vim.cmd('set nocursorcolumn')
print("After 'set nocursorcolumn':")
print("vim.o.cursorcolumn =", vim.o.cursorcolumn)
