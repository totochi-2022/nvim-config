-- plugins/core.lua - 基本ライブラリ
return {
    -- Minor Mode Plugin
    {
        "totochi-2022/minor-mode.nvim",
        config = false, -- 設定不要、そのまま使用
    },
    -- ローカル開発用
    -- {
    --     dir = "/home/motoki/work/repo/nvim-plugin/minor-mode.nvim",
    --     name = "minor-mode.nvim",
    --     config = false,
    -- },
    
    -- Incremental Migemo Search
    {
        "totochi-2022/incsearch-migemo.nvim",
        config = function()
            require('incsearch-migemo').setup()
        end,
    },
    -- ローカル開発用
    -- {
    --     dir = "/home/motoki/work/repo/nvim-plugin/incsearch-migemo.nvim",
    --     name = "incsearch-migemo.nvim",
    --     config = function()
    --         require('incsearch-migemo').setup()
    --     end,
    -- },
    
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