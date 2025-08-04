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
            'fdschmidt93/telescope-egrepify.nvim',
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
                    },
                    undo = {
                        use_delta = true,
                        use_custom_command = nil,
                        side_by_side = true,
                        layout_strategy = "horizontal",
                        layout_config = {
                            preview_width = 0.65,
                        },
                        vim_diff_opts = {
                            ctxlen = vim.o.scrolloff,
                        },
                        entry_format = "state #$ID, $STAT, $TIME",
                        time_format = "",
                    },
                    egrepify = {
                        -- AND operator for tokens in prompt
                        AND = true, -- default: true
                        -- invert toggle for include/exclude operators
                        invert = false, -- default: false
                        -- lnum toggle for line numbers
                        lnum = true, -- default: true
                        -- trim toggle for leading/trailing whitespace
                        trim = true, -- default: true
                        -- permutations toggle for tokens in prompt
                        permutations = false, -- default: false
                        -- デフォルトのキーマップを使用（明示的設定を削除）
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
            require('telescope').load_extension('undo')
            require('telescope').load_extension('egrepify')
        end,
    },

    -- 数値・文字列増減プラグイン
    {
        'monaqa/dial.nvim',
        config = function()
            local augend = require("dial.augend")
            require("dial.config").augends:register_group{
                default = {
                    -- 基本的な数値
                    augend.integer.alias.decimal,      -- 10進数
                    augend.integer.alias.hex,          -- 16進数
                    augend.integer.alias.binary,       -- 2進数
                    
                    -- 小数点
                    augend.decimal_fraction.new{
                        signed = true,
                    },
                    
                    -- 日付関連
                    augend.date.alias["%Y/%m/%d"],     -- 2024/01/01
                    augend.date.alias["%Y-%m-%d"],     -- 2024-01-01
                    augend.date.alias["%H:%M"],        -- 23:59
                    
                    -- ブール値・論理値
                    augend.constant.alias.bool,        -- true/false
                    augend.constant.alias.alpha,       -- a/b/c/...
                    augend.constant.alias.Alpha,       -- A/B/C/...
                    
                    -- よく使う単語（実用的なもののみ）
                    augend.constant.new{
                        elements = {"yes", "no"},
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new{
                        elements = {"TRUE", "FALSE"},  -- C言語のdefine用
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new{
                        elements = {"ON", "OFF"},  -- Arduino用
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new{
                        elements = {"HIGH", "LOW"},  -- Arduino用
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new{
                        elements = {"True", "False"},  -- Python用
                        word = true,
                        cyclic = true,
                    },
                    
                    -- 論理演算子
                    augend.constant.new{
                        elements = {"and", "or"},  -- Python/Shell用
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new{
                        elements = {"&&", "||"},  -- C/JavaScript用
                        word = false,
                        cyclic = true,
                    },
                    
                    -- 比較演算子
                    augend.constant.new{
                        elements = {"==", "!="},
                        word = false,
                        cyclic = true,
                    },
                    augend.constant.new{
                        elements = {"<", ">"},
                        word = false,
                        cyclic = true,
                    },
                    
                    -- 括弧（開き）
                    augend.constant.new{
                        elements = {"(", "{", "["},
                        word = false,
                        cyclic = true,
                    },
                    -- 括弧（閉じ）
                    augend.constant.new{
                        elements = {")", "}", "]"},
                        word = false,
                        cyclic = true,
                    },
                    
                    -- クォート
                    augend.constant.new{
                        elements = {"'", "\"", "`"},
                        word = false,
                        cyclic = true,
                    },
                    
                    -- 色関連
                    augend.hexcolor.new{
                        case = "lower",
                    },
                    
                    -- 曜日（日本語）
                    augend.constant.new{
                        elements = {"月", "火", "水", "木", "金", "土", "日"},
                        word = true,
                        cyclic = true,
                    },
                },
            }
        end,
    },

    -- TreeSitter関連
    {
        'nvim-treesitter/nvim-treesitter',
        build = ":TSUpdate",
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
            {
                'nvim-treesitter/nvim-treesitter-context',
                config = function()
                    require('treesitter-context').setup({
                        enable = true,
                        max_lines = 3,  -- 最大3行までに制限
                        min_window_height = 10,  -- 10行以下のウィンドウでは無効
                        line_numbers = true,
                        multiline_threshold = 20,  -- 20行以上の場合のみコンテキストを表示
                        trim_scope = 'outer',  -- 外側のスコープを優先的に削除
                        mode = 'cursor',  -- カーソル位置のコンテキストを表示
                        separator = nil,  -- 区切り線なし（必要なら'-'などを設定）
                        zindex = 20,
                        on_attach = nil,  -- 特定のバッファで無効にしたい場合はここで関数を定義
                    })
                end,
            },
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
        'hedyhli/outline.nvim',
        config = function()
            require("outline").setup({
                outline_window = {
                    position = 'right',
                    width = 25,
                    relative_width = true,
                    auto_close = true,  -- 選択したら自動で閉じる
                },
                outline_items = {
                    highlight_hovered_item = true,
                    show_symbol_details = false,
                },
                symbols = {
                    filter = {
                        default = {
                            'Class', 'Constructor', 'Enum', 'Field', 'Function', 
                            'Interface', 'Method', 'Module', 'Namespace', 'Package', 
                            'Property', 'Struct', 'Trait'
                        },
                        lua = {
                            'Class', 'Constructor', 'Enum', 'Field', 'Function', 
                            'Interface', 'Method', 'Module', 'Namespace', 'Package', 
                            'Property', 'Struct', 'Trait'
                        },
                    },
                },
            })
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