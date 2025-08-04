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
    
    -- 新しく追加するカラースキーム
    {
        "catppuccin/nvim",
        name = "catppuccin",
        config = function()
            require("catppuccin").setup({
                flavour = "mocha", -- latte, frappe, macchiato, mocha
            })
        end
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require("rose-pine").setup({
                variant = "auto", -- auto, main, moon, dawn
            })
        end
    },
    {
        "rebelot/kanagawa.nvim",
        config = function()
            require("kanagawa").setup({
                compile = false,
                undercurl = true,
            })
        end
    },
    { "sainnhe/everforest" },

    -- アイコン設定
    {
        'nvim-tree/nvim-web-devicons',
        config = function()
            require('nvim-web-devicons').setup {
                -- フォールバック設定
                override = {
                    default_icon = {
                        icon = "",
                        color = "#6d8086",
                        name = "Default",
                    },
                },
                -- strict = true,
                -- override_by_filename = {
                --     [".gitignore"] = {
                --         icon = "",
                --         color = "#f1502f",
                --         name = "Gitignore"
                --     }
                -- },
                -- override_by_extension = {
                --     ["log"] = {
                --         icon = "",
                --         color = "#81e043",
                --         name = "Log"
                --     }
                -- },
            }
        end
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
                        'filetype',
                        -- Toggle状態を表示（OFF時は背景色ベース、ON時はVisual色）
                        {
                            function()
                                -- toggle_configが読み込まれているかチェック
                                local ok, toggle = pcall(require, '12_toggle')
                                if ok and toggle.lualine_component then
                                    return toggle.lualine_component()
                                end
                                return ''
                            end,
                        },
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
                    { "<C-", mode = { "n", "v" } },   -- Ctrlキー
                    { "<M-", mode = { "n", "v" } },   -- Alt/Metaキー
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

    -- パンくずリスト（breadcrumb）（fine-cmdlineと競合するため無効化）
    {
        'Bekaboo/dropbar.nvim',
        enabled = false,  -- fine-cmdlineと競合するため無効化
        dependencies = {
            'nvim-telescope/telescope.nvim'
        },
        config = function()
            require('dropbar').setup({
                -- 一般設定（より厳格な条件で無効化）
                enable = function(buf, win, _)
                    -- ウィンドウの高さが小さい場合は無効化
                    if vim.api.nvim_win_get_height(win) < 5 then
                        return false
                    end
                    
                    -- フローティングウィンドウでは無効化
                    if vim.api.nvim_win_get_config(win).relative ~= '' then
                        return false
                    end
                    
                    -- 特定のファイルタイプでは無効化
                    local disabled_filetypes = {
                        'help', 'alpha', 'dashboard', 'neo-tree', 'Trouble', 'lazy',
                        'mason', 'notify', 'toggleterm', 'lazyterm', 'oil',
                        'prompt', 'TelescopePrompt', 'FineCmdlinePrompt', 'cmdline',
                        ''  -- 空のfiletypeも除外
                    }
                    
                    -- 問題のあるbuftype は全て無効化
                    local disabled_buftypes = { 'nofile', 'prompt', 'popup', 'help', 'quickfix' }
                    if vim.tbl_contains(disabled_buftypes, vim.bo[buf].buftype) then
                        return false
                    end
                    
                    -- ウィンドウタイプをチェック
                    if vim.fn.win_gettype(win) ~= '' then
                        return false
                    end
                    
                    return not vim.tbl_contains(disabled_filetypes, vim.bo[buf].filetype)
                        and vim.bo[buf].buftype == ''
                        and vim.api.nvim_buf_get_name(buf) ~= ''
                end,

                -- 一般設定
                general = {
                    update_interval = 100,
                    enable = true,
                },

                -- アイコン設定
                icons = {
                    kinds = {
                        use_devicons = true,
                    },
                    ui = {
                        bar = {
                            separator = ' › ',
                            extends = '…',
                        },
                        menu = {
                            separator = ' ',
                            indicator = ' › ',
                        },
                    },
                },
                
                -- メニュー設定
                menu = {
                    -- クイック移動用のキーマップ
                    keymaps = {
                        ['<LeftMouse>'] = function()
                            local menu = require('dropbar.menu')
                            local utils = require('dropbar.utils')
                            if menu.current then
                                menu.current:close()
                            end
                            utils.bar.pick()
                        end,
                        ['q'] = function()
                            local menu = require('dropbar.menu')
                            if menu.current then
                                menu.current:close()
                            end
                        end,
                        ['<CR>'] = function()
                            local menu = require('dropbar.menu')
                            if menu.current then
                                local cursor = vim.api.nvim_win_get_cursor(menu.current.win)
                                local component = menu.current.entries[cursor[1]]:first_clickable(cursor[2])
                                if component then
                                    menu.current:click_on(component, nil, 1, 'l')
                                end
                            end
                        end,
                    },
                    win_configs = {
                        border = 'single',
                        style = 'minimal',
                    },
                },
                
                -- バー設定
                bar = {
                    hover = true,
                    -- ピック用のキー設定
                    pick = {
                        pivots = '1234567890',  -- 数字キーで分かりやすく
                    },
                    sources = function(buf, _)
                        local sources = require('dropbar.sources')
                        local utils = require('dropbar.utils')
                        if vim.bo[buf].ft == 'markdown' then
                            return {
                                sources.path,
                                sources.markdown,
                            }
                        end
                        if vim.bo[buf].buftype == 'terminal' then
                            return {
                                sources.terminal,
                            }
                        end
                        return {
                            sources.path,
                            utils.source.fallback({
                                sources.lsp,
                                sources.treesitter,
                            }),
                        }
                    end,
                },
            })
        end,
    },

    -- スクロールバー
    {
        'petertriho/nvim-scrollbar',
        dependencies = {
            'kevinhwang91/nvim-hlslens',
            'lewis6991/gitsigns.nvim'
        },
        config = function()
            require('scrollbar').setup({
                show = true,
                show_in_active_only = false,
                set_highlights = true,
                folds = 1000, -- handle folds, set to number to disable folds if no. of lines in buffer exceeds this
                max_lines = false, -- disables if no. of lines in buffer exceeds this
                hide_if_all_visible = false, -- Hides everything if all lines are visible
                throttle_ms = 100,
                handle = {
                    text = " ",
                    color = nil,
                    cterm = nil,
                    highlight = "CursorColumn",
                    hide_if_all_visible = true, -- Hides handle if all lines are visible
                },
                marks = {
                    Cursor = {
                        text = "•",
                        priority = 0,
                        color = nil,
                        cterm = nil,
                        highlight = "Normal",
                    },
                    Search = {
                        text = { "-", "=" },
                        priority = 1,
                        color = nil,
                        cterm = nil,
                        highlight = "Search",
                    },
                    Error = {
                        text = { "-", "=" },
                        priority = 2,
                        color = nil,
                        cterm = nil,
                        highlight = "DiagnosticVirtualTextError",
                    },
                    Warn = {
                        text = { "-", "=" },
                        priority = 3,
                        color = nil,
                        cterm = nil,
                        highlight = "DiagnosticVirtualTextWarn",
                    },
                    Info = {
                        text = { "-", "=" },
                        priority = 4,
                        color = nil,
                        cterm = nil,
                        highlight = "DiagnosticVirtualTextInfo",
                    },
                    Hint = {
                        text = { "-", "=" },
                        priority = 5,
                        color = nil,
                        cterm = nil,
                        highlight = "DiagnosticVirtualTextHint",
                    },
                    Misc = {
                        text = { "-", "=" },
                        priority = 6,
                        color = nil,
                        cterm = nil,
                        highlight = "Normal",
                    },
                    GitAdd = {
                        text = "│",
                        priority = 7,
                        color = nil,
                        cterm = nil,
                        highlight = "GitSignsAdd",
                    },
                    GitChange = {
                        text = "│",
                        priority = 7,
                        color = nil,
                        cterm = nil,
                        highlight = "GitSignsChange",
                    },
                    GitDelete = {
                        text = "▁",
                        priority = 7,
                        color = nil,
                        cterm = nil,
                        highlight = "GitSignsDelete",
                    },
                },
                excluded_buftypes = {
                    "terminal",
                },
                excluded_filetypes = {
                    "prompt",
                    "TelescopePrompt",
                    "noice",
                    "oil",
                },
                autocmd = {
                    render = {
                        "BufWinEnter",
                        "TabEnter",
                        "TermEnter",
                        "WinEnter",
                        "CmdwinLeave",
                        "TextChanged",
                        "VimResized",
                        "WinScrolled",
                    },
                    clear = {
                        "BufWinLeave",
                        "TabLeave",
                        "TermLeave",
                        "WinLeave",
                    },
                },
                handlers = {
                    cursor = true,
                    diagnostic = true,
                    gitsigns = true, -- Requires gitsigns
                    handle = true,
                    search = true, -- Requires hlslens
                    ale = false, -- Requires ALE
                },
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