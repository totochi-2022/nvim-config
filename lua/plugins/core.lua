-- plugins/core.lua - 基本ライブラリ
return {
    -- Minor Mode Plugin
    {
        vim.g.use_local_plugins and vim.g.use_local_plugins.minor_mode
            and { dir = "/home/motoki/work/repo/nvim_plugin/minor-mode.nvim" }  -- ローカル開発版
            or "totochi-2022/minor-mode.nvim",  -- GitHub版
        config = false, -- 設定不要、そのまま使用
    },
    
    -- Incremental Migemo Search
    {
        vim.g.use_local_plugins and vim.g.use_local_plugins.incsearch_migemo
            and { dir = "/home/motoki/work/repo/nvim_plugin/incsearch-migemo.nvim" }  -- ローカル開発版
            or "totochi-2022/incsearch-migemo.nvim",  -- GitHub版
        config = function()
            require('incsearch-migemo').setup()
        end,
    },
    
    -- コアライブラリ
    { "tpope/vim-repeat" },
    { "nvim-lua/popup.nvim" },
    { "nvim-lua/plenary.nvim" },
    { "nvim-tree/nvim-web-devicons" },
    { "rcarriga/nvim-notify" },
    { "kana/vim-textobj-user" },
    { "kana/vim-operator-user" },
    { "MunifTanjim/nui.nvim" },
}