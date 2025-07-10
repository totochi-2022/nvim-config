-- plugins/lsp.lua - LSP関連（自動インストール対応）
return {
    -- LSPマネージャー
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
    },
    {
        "jay-babu/mason-null-ls.nvim",
        dependencies = { "mason.nvim", "nvimtools/none-ls.nvim" },
        event = { "BufReadPre", "BufNewFile" },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "mason-lspconfig.nvim" },
    },

    -- 診断表示の改善（lsp_lines.nvimを無効化してシンプルに）
    -- {
    --     'Maan2003/lsp_lines.nvim',
    --     config = function()
    --         vim.g.toggle_diag_state = 1
    --         if ToggleDiagDisp then
    --             ToggleDiagDisp(false)
    --         end
    --         require("lsp_lines").setup()
    --         -- デフォルトは無効にして、トグルで切り替え
    --         vim.diagnostic.config({
    --             virtual_text = true,
    --             virtual_lines = false,
    --         })
    --     end,
    -- },

    -- フォーマッター・リンター
    {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- 補完エンジン
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-emoji",
            "hrsh7th/vim-vsnip",
            "hrsh7th/cmp-vsnip",
            "onsails/lspkind-nvim",
        },
    },

    -- スニペット
    { "hrsh7th/vim-vsnip" },
    { "hrsh7th/cmp-vsnip" },

    -- 補完ソース
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "hrsh7th/cmp-emoji" },

    -- アイコン・UI
    { "onsails/lspkind-nvim" },
}