-- plugins/core.lua - 基本ライブラリ
return {
    -- Minor Mode Plugin
    {
        "totochi-2022/minor-mode.nvim",
        tag = "v1.0.0", -- 安定版を使用
        config = false, -- 設定不要、そのまま使用
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