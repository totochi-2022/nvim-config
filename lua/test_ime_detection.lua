-- WSL2環境でのIME状態判別テスト
-- :luafile ~/.config/nvim/lua/test_ime_detection.lua で実行

local M = {}

-- 方法1: 標準のgetimstatus()
M.test_getimstatus = function()
  print("=== getimstatus() テスト ===")
  local status = vim.fn.getimstatus()
  print("getimstatus() result: " .. tostring(status))
  print("Type: " .. type(status))
  return status
end

-- 方法2: PowerShell経由でWindowsのIME状態を取得
M.test_powershell_ime = function()
  print("=== PowerShell IME テスト ===")
  local cmd = 'powershell.exe -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.InputLanguage]::CurrentInputLanguage.Culture.Name"'
  local handle = io.popen(cmd)
  if handle then
    local result = handle:read('*a')
    handle:close()
    result = result:gsub('%s+', '')
    print("PowerShell result: " .. tostring(result))
    print("Is Japanese: " .. tostring(result:match('ja') ~= nil))
    return result
  else
    print("PowerShell command failed")
    return nil
  end
end

-- 方法3: zenhanコマンド（要インストール）
M.test_zenhan = function()
  print("=== zenhan テスト ===")
  local result = vim.fn.system(vim.env.HOME .. '/bin/zenhan')
  local exit_code = vim.v.shell_error
  print("zenhan result: " .. tostring(result))
  print("zenhan exit code: " .. tostring(exit_code))
  print("Is Japanese (exit_code == 1): " .. tostring(exit_code == 1))
  return exit_code
end

-- 方法4: Windows レジストリから現在のキーボードレイアウトを取得
M.test_registry_layout = function()
  print("=== Registry Layout テスト ===")
  local cmd = 'powershell.exe -Command "Get-ItemProperty -Path \'HKCU:\\Keyboard Layout\\Preload\' -Name 1 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 1"'
  local handle = io.popen(cmd)
  if handle then
    local result = handle:read('*a')
    handle:close()
    result = result:gsub('%s+', '')
    print("Registry result: " .. tostring(result))
    print("Is Japanese Layout (00000411): " .. tostring(result == '00000411'))
    return result
  else
    print("Registry command failed")
    return nil
  end
end

-- 方法5: WMI経由でキーボードレイアウトを取得
M.test_wmi_keyboard = function()
  print("=== WMI Keyboard テスト ===")
  local cmd = 'powershell.exe -Command "Get-WmiObject -Class Win32_Keyboard | Select-Object -First 1 -ExpandProperty Layout"'
  local handle = io.popen(cmd)
  if handle then
    local result = handle:read('*a')
    handle:close()
    result = result:gsub('%s+', '')
    print("WMI result: " .. tostring(result))
    return result
  else
    print("WMI command failed")
    return nil
  end
end

-- 方法6: Get-Culture経由で現在の入力ロケールを取得
M.test_culture = function()
  print("=== Get-Culture テスト ===")
  local cmd = 'powershell.exe -Command "Get-Culture | Select-Object -ExpandProperty Name"'
  local handle = io.popen(cmd)
  if handle then
    local result = handle:read('*a')
    handle:close()
    result = result:gsub('%s+', '')
    print("Culture result: " .. tostring(result))
    print("Is Japanese: " .. tostring(result:match('ja') ~= nil))
    return result
  else
    print("Culture command failed")
    return nil
  end
end

-- 全テストを実行
M.run_all_tests = function()
  print("WSL2環境でのIME状態判別テスト開始")
  print("=" .. string.rep("=", 50))
  
  M.test_getimstatus()
  print("")
  
  M.test_powershell_ime()
  print("")
  
  M.test_zenhan()
  print("")
  
  M.test_registry_layout()
  print("")
  
  M.test_wmi_keyboard()
  print("")
  
  M.test_culture()
  print("")
  
  print("=" .. string.rep("=", 50))
  print("テスト完了")
  print("IMEの状態を変更してから再度テストしてみてください")
end

-- 便利なキーマップを設定
vim.keymap.set('n', '<leader>ti', M.run_all_tests, { desc = 'Run IME detection tests' })
vim.keymap.set('n', '<leader>t1', M.test_getimstatus, { desc = 'Test getimstatus()' })
vim.keymap.set('n', '<leader>t2', M.test_powershell_ime, { desc = 'Test PowerShell IME' })
vim.keymap.set('n', '<leader>t3', M.test_zenhan, { desc = 'Test zenhan' })

return M