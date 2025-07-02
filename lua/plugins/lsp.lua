-- plugins/lsp.lua - LSP関連
return {
    -- LSP関連
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "jayp0521/mason-null-ls.nvim" },
    { "neovim/nvim-lspconfig" },
    {
        'Maan2003/lsp_lines.nvim',
        config = function()
            vim.g.toggle_diag_state = 1
            if ToggleDiagDisp then
                ToggleDiagDisp(false)
            end
            require("lsp_lines").setup()
        end,
    },

    -- 補完関連
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/vim-vsnip" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "onsails/lspkind-nvim" },
    { "hrsh7th/cmp-cmdline" },
    { "nvimtools/none-ls.nvim" },
    { "hrsh7th/cmp-omni" },
    { "hrsh7th/cmp-emoji" },
    {
        "tzachar/cmp-tabnine",
        build = "./install.sh",
        cond = function()
            return vim.fn.executable('node') == 1
        end,
    },
}