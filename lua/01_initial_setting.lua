local dir_setting = {}

-- 基本パスの取得
dir_setting.config = vim.fn.stdpath('config')  -- 設定ファイルのパス
local base_data = vim.fn.stdpath('data')      -- データディレクトリのパス
dir_setting.share_data = dir_setting.config .. '/data'

-- 各種データディレクトリの設定
dir_setting.undo = base_data .. '/undo'
dir_setting.backup = base_data .. '/backup'
dir_setting.swap = base_data .. '/swap'

dir_setting.howm =    dir_setting.share_data  .. '/howm'
dir_setting.junk =    dir_setting.share_data  .. '/junk'
dir_setting.bookmark =dir_setting.share_data .. '/bookmark'

-- スキップするプラグイン設定
local skip_plugins = {
    'gzip', 'tar', 'tarPlugin', 'zip', 'zipPlugin', 'rrhelper', '2html_plugin', 'vimball',
    'vimballPlugin', 'getscript', 'getscriptPlugin', 'netrw', 'netrwPlugin', 'netrwSettings',
    'netrwFileHandlers',
}

for plugin in pairs(skip_plugins) do
    vim.g['loaded_' .. plugin] = 1
end

-- ディレクトリの作成
vim.g.dir_setting = dir_setting
vim.cmd [[
 for key in keys(g:dir_setting)
   if key != "repo" && !isdirectory(g:dir_setting[key])
     call mkdir(iconv(g:dir_setting[key], &encoding, &termencoding), 'p')
   endif
 endfor
]]
