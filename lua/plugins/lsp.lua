-- plugins/lsp.lua - LSP関連（自動インストール対応）
return {
    -- インライン診断表示
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        config = function()
            -- 診断設定（signsのみ有効、virtual_textはtiny-inline-diagnosticが担当）
            vim.diagnostic.config({
                virtual_text = false,
                signs = true,
                underline = false,
                update_in_insert = false,
                severity_sort = true,
            })

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

    -- Lua開発支援（Neovim設定編集時にvim.api等の補完を提供）
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    -- 補完エンジン（blink.cmp）
    {
        "saghen/blink.cmp",
        version = "*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "rafamadriz/friendly-snippets",
            "hrsh7th/vim-vsnip",
            {
                "saghen/blink.compat",
                version = "*",
                lazy = true,
                opts = {},
            },
            -- 既存のcmpソースをblink.compat経由で流用
            "hrsh7th/cmp-vsnip",
            "hrsh7th/cmp-emoji",
        },
        opts = {
            enabled = function()
                return not vim.b.disable_blink_cmp
            end,
            keymap = {
                preset = "default",
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
                ["<CR>"] = { "accept", "fallback" },
                ["<C-l>"] = { "show", "fallback" },
                ["<C-e>"] = { "cancel", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback" },
                ["<C-n>"] = { "select_next", "fallback" },
                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
                ["<Esc>"] = { "cancel", "fallback" },
            },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },
            completion = {
                menu = {
                    border = "rounded",
                    draw = {
                        columns = {
                            { "label", "label_description", gap = 1 },
                            { "kind_icon", "kind", gap = 1 },
                        },
                    },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                    window = { border = "rounded" },
                },
                ghost_text = { enabled = true },
                accept = {
                    auto_brackets = { enabled = false },
                },
            },
            signature = {
                enabled = true,
                window = { border = "rounded" },
            },
            sources = {
                default = { "lazydev", "lsp", "path", "vsnip", "buffer", "emoji" },
                providers = {
                    vsnip = {
                        name = "vsnip",
                        module = "blink.compat.source",
                        score_offset = -3,
                    },
                    emoji = {
                        name = "emoji",
                        module = "blink.compat.source",
                        score_offset = -5,
                    },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
                    },
                },
            },
            cmdline = {
                keymap = { preset = "inherit" },
                completion = { menu = { auto_show = true } },
            },
        },
        opts_extend = { "sources.default" },
    },
}