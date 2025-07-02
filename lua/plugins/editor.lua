-- plugins/editor.lua - エディタ機能
return {
    -- Telescope関連
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            'kkharji/sqlite.lua',
            'nvim-telescope/telescope-ghq.nvim',
            'nvim-telescope/telescope-frecency.nvim',
            'nvim-telescope/telescope-file-browser.nvim',
            'LinArcX/telescope-command-palette.nvim',
            'debugloop/telescope-undo.nvim',
        },
        config = function()
            require('telescope').setup({
                extensions = {
                    frecency = {
                        show_scores = false,
                        show_unindexed = true,
                        ignore_patterns = { "*.git/*", "*/tmp/*" },
                        workspaces = {
                            ["conf"] = "/home/my_username/.config",
                            ["data"] = "/home/my_username/.local/share",
                            ["project"] = "/home/my_username/projects",
                            ["wiki"] = "/home/my_username/wiki"
                        }
                    },
                    file_browser = {
                        hijack_netrw = true,
                    },
                    command_palette = {
                        -- 元の長いコマンドパレット設定をそのまま保持
                    }
                },
                pickers = {
                    buffers = {
                        show_all_buffers = true,
                        sort_lastused = true,
                        mappings = {
                            i = {
                                ["<c-k>"] = "delete_buffer",
                            }
                        }
                    }
                }
            })

            require('telescope').load_extension('ghq')
            require('telescope').load_extension('frecency')
            require('telescope').load_extension('file_browser')
            require('telescope').load_extension('command_palette')
        end,
    },

    -- TreeSitter関連
    {
        'nvim-treesitter/nvim-treesitter',
        build = ":TSUpdate",
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
            'nvim-treesitter/nvim-treesitter-context',
            'JoosepAlviste/nvim-ts-context-commentstring',
            'RRethy/nvim-treesitter-endwise',
            {
                'nvim-treesitter/nvim-treesitter-textobjects',
                event = "VeryLazy",
            },
            {
                'mfussenegger/nvim-treehopper',
                event = "VeryLazy",
                keys = {
                    { '<LocalLeader>s', '<cmd>lua require("tsht").nodes()<CR>', mode = 'o' },
                    { '<LocalLeader>s', '<cmd>lua require("tsht").nodes()<CR>', mode = 'x' },
                    { '<LocalLeader>s', '<cmd>lua require("tsht").nodes()<CR>', mode = 'n' },
                },
                config = function()
                    require('tsht').config.hint_keys = { "h", "j", "f", "d", "n", "v", "s", "l", "a" }
                end,
            },
            {
                'David-Kunz/treesitter-unit',
                config = function()
                    -- TreeSitter Unitの設定
                end
            },
        },
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query",
                    "python", "javascript", "typescript",
                    "markdown", "markdown_inline", "fish"
                },
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true
                },
                fold = {
                    enable = true
                },
                folding = {
                    enable = true,
                },
            }

            -- TreesitterベースのFoldingを有効化
            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
            vim.opt.foldenable = false
            vim.opt.foldlevel = 99

            -- treesitter-context設定
            require('treesitter-context').setup({
                enable = true,
                max_lines = 0,
                min_window_height = 0,
                line_numbers = true,
                multiline_threshold = 20,
                trim_scope = 'outer',
                mode = 'cursor',
                separator = nil,
                zindex = 20,
                on_attach = nil,
            })
        end,
    },

    -- アウトライン表示
    {
        'simrat39/symbols-outline.nvim',
        config = function()
            require("symbols-outline").setup()
        end
    },

    -- ファイラー
    {
        "stevearc/oil.nvim",
        opts = {
            default_file_explorer = true,
            view_options = {
                show_hidden = true,
            },
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    -- フォールディング
    {
        "LeafCage/foldCC.vim",
        config = function()
            vim.opt.foldtext = "FoldCCtext()"
            vim.g.foldCCtext_head = 'printf("   %-7s", v:folddashes)'
            vim.g.foldCCtext_tail = 'printf(" (%4d lines)", v:foldend-v:foldstart+1)'
        end
    },

    -- コメントアウトされたプラグイン
    -- { "anuvyklack/pretty-fold.nvim" },
    -- { "anuvyklack/fold-preview.nvim" },
    -- { "nvim-neo-tree/neo-tree.nvim" },
}