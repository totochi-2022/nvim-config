-- plugins/lsp.lua - LSP関連（自動インストール対応）
return {
    -- インライン診断表示
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        config = function()
            -- 標準診断無効化（signsのみ有効）
            vim.diagnostic.config({
                virtual_text = false,
                signs = true,         -- エラー行判別用にsignsを有効化
                underline = false,    -- アンダーラインは無効
                update_in_insert = false,
                severity_sort = true,
            })
            
            -- Neovimデフォルトの診断設定（signsのみ有効）
            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
                vim.lsp.handlers["textDocument/publishDiagnostics"], {
                    virtual_text = false,
                    signs = true,         -- signsを有効化
                    underline = false,    -- アンダーラインは無効
                    update_in_insert = false,
                    severity_sort = true,
                }
            )
            
            require('tiny-inline-diagnostic').setup({
                signs = {
                    left = " ",
                    right = " ",
                    diag = "●",
                    arrow = "  ",
                    up_arrow = "  ",
                    vertical = " │",
                    vertical_end = " └"
                },
                hi = {
                    error = "DiagnosticError",
                    warn = "DiagnosticWarn", 
                    info = "DiagnosticInfo",
                    hint = "DiagnosticHint",
                    arrow = "NonText",
                    background = "Normal", -- より目立つ背景
                },
                blend = {
                    factor = 0.15, -- より不透明に
                },
                options = {
                    -- Show the source of the diagnostic
                    show_source = true,
                    
                    -- Throttle the update of the diagnostic when moving cursor, in milliseconds
                    throttle = 20,
                    
                    -- The minimum length of the message, otherwise it will be on a new line
                    softwrap = 30,
                    
                    -- If multiple diagnostics are under the cursor, display all of them
                    multiple_diag_under_cursor = true,
                    
                    -- カーソル行のみ表示する重要な設定
                    show_all_diags_on_cursorline = false,  -- カーソル下の診断のみ表示
                },
                
                -- 複数行設定（全行表示を無効化）
                multilines = {
                    enabled = false,      -- 複数行診断を無効化
                    always_show = false,  -- 全行での常時表示を無効化
                },
            })
            
            -- 確実に標準診断設定（signsのみ有効、複数回実行）
            vim.defer_fn(function()
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = true,         -- signsを有効化
                    underline = false,    -- アンダーラインは無効
                    update_in_insert = false,
                    severity_sort = true,
                })
            end, 100)
            
            -- LSP起動時にも設定
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function()
                    vim.diagnostic.config({
                        virtual_text = false,
                        signs = true,         -- signsを有効化
                        underline = false,    -- アンダーラインは無効
                        update_in_insert = false,
                        severity_sort = true,
                    })
                end,
            })
        end
    },
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