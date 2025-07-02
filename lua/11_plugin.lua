-- 11_plugin.lua - メインプラグイン設定
local lazypath = vim.fn.stdpath("data") .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

local config = {}
vim.opt.rtp:prepend(lazypath)
-- Windows環境の場合は並列数を制限
if vim.fn.has('win32') == 1 then
    config.concurrency = 1
else
    config.concurrency = 20 -- WSL2ではより多くの並列処理を許可
end

if vim.fn.has('win64') then
    vim.g.direnv_auto = 0
end
vim.opt.timeoutlen = 300 --すぐ出るように

-- 各プラグインファイルを読み込み（依存関係順）
local plugin_modules = {
    'plugins.core',      -- 基本ライブラリを最初に
    'plugins.ui',        -- UI系（which-key含む）
    'plugins.terminal',  -- ターミナル
    'plugins.motion',    -- 移動・ジャンプ
    'plugins.editor',    -- エディタ機能
    'plugins.lsp',       -- LSP
    'plugins.debug',     -- デバッグ
    'plugins.misc',      -- その他
    'plugins.git',       -- Git（最後、現在空）
}

local all_plugins = {}
for _, module in ipairs(plugin_modules) do
    local plugins = require(module)
    for _, plugin in ipairs(plugins) do
        table.insert(all_plugins, plugin)
    end
end

require("lazy").setup(all_plugins, {
    concurrency = config.concurrency,
    ui = {
        border = "rounded"
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})