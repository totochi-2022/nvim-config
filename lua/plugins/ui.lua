-- plugins/ui.lua - UI関連
return {
    -- カラースキーム
    { "EdenEast/nightfox.nvim" },
    { "folke/tokyonight.nvim" },
    { "glepnir/zephyr-nvim" },
    { "morhetz/gruvbox" },
    {
        "kyoz/purify",
        rtp = 'vim'
    },

    -- UI関連
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'j-hui/fidget.nvim',
        },
        config = function()
            require('fidget').setup {}
            require('lualine').setup {
                options = {
                    disabled_filetypes = {
                        winbar = {
                            "dap-repl",
                            "dap-repl-18",
                            "dapui_breakpoints",
                            "dapui_console",
                            "dapui_scopes",
                            "dapui_watches",
                            "dapui_stacks",
                        },
                    },
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = { 'filename' },
                    lualine_x = {
                        'encoding',
                        'fileformat',
                        'filetype'
                    },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { 'filename' },
                    lualine_x = { 'location' },
                    lualine_y = {},
                    lualine_z = {}
                },
            }
        end
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")
            wk.setup({
                preset = "classic",
                delay = 300,
                -- spec = require("plugins.which-key-spec"), -- 一時的に無効化
                triggers = {
                    { "<auto>", mode = "nxsotc" },
                    { "s", mode = { "n", "v" } },     -- リーダーキー
                    { "<space>", mode = { "n", "v" } }, -- ローカルリーダー
                    { "m", mode = { "n", "v" } },     -- LSP用
                },
            })
        end,
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },

    {
        "shellRaining/hlchunk.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("hlchunk").setup({
                chunk = {
                    enable = true,
                    priority = 15,
                    style = {
                        { fg = "#806d9c" },
                        { fg = "#c21f30" },
                    },
                    use_treesitter = true,
                    chars = {
                        horizontal_line = "─",
                        vertical_line = "│",
                        left_top = "╭",
                        left_bottom = "╰",
                        right_arrow = ">",
                    },
                    textobject = "",
                    max_file_size = 1024 * 1024,
                    error_sign = true,
                },
                indent = {
                    enable = false,
                    priority = 10,
                    style = {
                        { fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui") },
                    },
                    use_treesitter = false,
                    chars = { "│", "¦", "┆", "┊", },
                    ahead_lines = 5,
                    delay = 100,
                },
                line_num = {
                    enable = false,
                    style = "#806d9c",
                    priority = 10,
                },
                blank = {
                    enable = false,
                    chars = {
                        "․",
                    },
                    style = {
                        { fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui") },
                    },
                    priority = 9,
                },
            })
        end
    },

    -- カーソルアニメーション（Terminal版Neovide風）
    {
        "sphamba/smear-cursor.nvim",
        config = function()
            require('smear_cursor').setup({
                -- Neovide設定に近づける
                cursor_color = '#ffffff',
                trail_size = 8,           -- neovide_cursor_trail_size = 0.8 相当
                trail_timeout = 30,       -- neovide_cursor_animation_length = 0.03 相当
                distance_stop_animating = 0.5,
                hide_target_hack = true,  -- ターミナルでのちらつき軽減
            })
        end,
    },

    -- コメントアウトされたプラグイン
    -- {
    --     "vim-scripts/indentLine.vim"
    -- },
    -- {
    --     "lukas-reineke/indent-blankline.nvim",
    --     main = "ibl",
    --     opts = {}
    -- },
}