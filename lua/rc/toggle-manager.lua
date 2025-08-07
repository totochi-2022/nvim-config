-- Bridge file for toggle-manager.nvim
-- This file allows requiring 'rc.toggle-manager' to access the plugin

-- パスを一時的に追加
local old_path = package.path
package.path = vim.fn.stdpath("config") .. "/lua/rc/toggle-manager.nvim/lua/?.lua;" .. 
               vim.fn.stdpath("config") .. "/lua/rc/toggle-manager.nvim/lua/?/init.lua;" .. 
               package.path

-- モジュールをロード
local toggle_manager = require('toggle-manager')

-- パスを元に戻す
package.path = old_path

return toggle_manager