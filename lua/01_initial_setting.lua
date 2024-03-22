local dir_setting = {}
local config = vim.env.XDG_CONFIG_HOME
local data = vim.env.XDG_DATA_HOME

--読込をスキップするプラグイン
local skip_plugins = {
    'gzip', 'tar', 'tarPlugin', 'zip', 'zipPlugin', 'rrhelper', '2html_plugin', 'vimball',
    'vimballPlugin', 'getscript', 'getscriptPlugin', 'netrw', 'netrwPlugin', 'netrwSettings',
    'netrwFileHandlers',
}

for plugin in pairs(skip_plugins) do
    vim.g['loaded_' .. plugin] = 1
end

--- ないとき
if config == nil then
    config = "$HOME/.config"
end

if data == nil then
    data = "$HOME/.local/share"
end

--- 環境変数を展開
config = vim.fn.expand(config)
data = vim.fn.expand(data)
dir_setting.data = data .. '/nvim'
dir_setting.config = config .. '/nvim'

dir_setting.undo  = dir_setting.data .. '/undo'
dir_setting.backup = dir_setting.data .. '/backup'
dir_setting.backup = dir_setting.data .. '/swap'

dir_setting.howm  =  dir_setting.data .. '/howm'
dir_setting.junk  =  dir_setting.data .. '/junk'
dir_setting.bookmark =  dir_setting.data .. '/bookmark'

-- dir確認なければ、作成
vim.g.dir_setting = dir_setting
vim.cmd [[
 for key in keys(g:dir_setting)
   if key != "repo" && !isdirectory(g:dir_setting[key])
     call mkdir(iconv(g:dir_setting[key], &encoding, &termencoding), 'p')
   endif
 endfor
]]

