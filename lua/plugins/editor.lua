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
                        AND = true,           -- default: true
                        -- invert toggle for include/exclude operators
                        invert = false,       -- default: false
                        -- lnum toggle for line numbers
                        lnum = true,          -- default: true
                        -- trim toggle for leading/trailing whitespace
                        trim = true,          -- default: true
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
            require('telescope').load_extension('yank_history')
        end,
    },

    -- 数値・文字列増減プラグイン
    {
        'monaqa/dial.nvim',
        config = function()
            local augend = require("dial.augend")
            require("dial.config").augends:register_group {
                default = {
                    -- 基本的な数値
                    augend.integer.alias.decimal, -- 10進数
                    augend.integer.alias.hex,     -- 16進数
                    augend.integer.alias.binary,  -- 2進数

                    -- 小数点
                    augend.decimal_fraction.new {
                        signed = true,
                    },

                    -- 日付関連
                    augend.date.alias["%Y/%m/%d"], -- 2024/01/01
                    augend.date.alias["%Y-%m-%d"], -- 2024-01-01
                    augend.date.alias["%H:%M"],    -- 23:59

                    -- ブール値・論理値
                    augend.constant.alias.bool,  -- true/false
                    augend.constant.alias.alpha, -- a/b/c/...
                    augend.constant.alias.Alpha, -- A/B/C/...

                    -- よく使う単語（実用的なもののみ）
                    augend.constant.new {
                        elements = { "yes", "no" },
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "TRUE", "FALSE" }, -- C言語のdefine用
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "ON", "OFF" }, -- Arduino用
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "HIGH", "LOW" }, -- Arduino用
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "True", "False" }, -- Python用
                        word = true,
                        cyclic = true,
                    },

                    -- 論理演算子
                    augend.constant.new {
                        elements = { "and", "or" }, -- Python/Shell用
                        word = true,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "&&", "||" }, -- C/JavaScript用
                        word = false,
                        cyclic = true,
                    },

                    -- 比較演算子
                    augend.constant.new {
                        elements = { "==", "!=" },
                        word = false,
                        cyclic = true,
                    },
                    augend.constant.new {
                        elements = { "<", ">" },
                        word = false,
                        cyclic = true,
                    },

                    -- 括弧（開き）
                    augend.constant.new {
                        elements = { "(", "{", "[" },
                        word = false,
                        cyclic = true,
                    },
                    -- 括弧（閉じ）
                    augend.constant.new {
                        elements = { ")", "}", "]" },
                        word = false,
                        cyclic = true,
                    },

                    -- クォート
                    augend.constant.new {
                        elements = { "'", "\"", "`" },
                        word = false,
                        cyclic = true,
                    },

                    -- 色関連
                    augend.hexcolor.new {
                        case = "lower",
                    },

                    -- 曜日（日本語）
                    augend.constant.new {
                        elements = { "月", "火", "水", "木", "金", "土", "日" },
                        word = true,
                        cyclic = true,
                    },
                },
            }
        end,
    },

    -- TreeSitter本体（mainブランチ - 新API）
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            -- パーサーインストール（new API）
            require('nvim-treesitter').install({
                "lua", "vim", "vimdoc", "query",
                "python", "javascript", "typescript",
                "markdown", "markdown_inline", "fish",
                "bash", "json", "yaml", "toml", "html", "css",
            })

            -- FileType毎にハイライト・フォールドを有効化
            vim.api.nvim_create_autocmd('FileType', {
                callback = function(ev)
                    local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
                    -- 対応パーサーがあれば起動
                    local ok = pcall(vim.treesitter.start, ev.buf, lang)
                    if ok then
                        -- Treesitterベースのフォールド・インデント
                        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })

            -- フォールド基本設定
            vim.opt.foldmethod = "expr"
            vim.opt.foldenable = false
            vim.opt.foldlevel = 99
        end,
    },

    -- treesitter-context: 関数階層表示
    {
        'nvim-treesitter/nvim-treesitter-context',
        event = "VeryLazy",
        config = function()
            require('treesitter-context').setup({
                enable = true,
                max_lines = 3,
                min_window_height = 10,
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

    -- コメント文字列をfiletype別に切り替え
    {
        'JoosepAlviste/nvim-ts-context-commentstring',
        event = "VeryLazy",
    },

    -- TreeSitterノードへのhopジャンプ
    {
        'mfussenegger/nvim-treehopper',
        event = "VeryLazy",
        config = function()
            require('tsht').config.hint_keys = { "h", "j", "f", "d", "n", "v", "s", "l", "a" }
        end,
    },

    -- ユニット(treesitter node)選択 - iu/au
    {
        'David-Kunz/treesitter-unit',
        event = "VeryLazy",
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
                    auto_close = true, -- 選択したら自動で閉じる
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

    -- 検索・置換
    {
        'MagicDuck/grug-far.nvim',
        config = function()
            require('grug-far').setup({
                -- シンタックスハイライト用の言語設定
                folding = {
                    enabled = true
                },
                -- 結果のハイライト
                resultLocation = {
                    showNumbersColumn = true
                },
                -- 検索エンジン設定
                engines = {
                    ripgrep = {
                        -- ripgrepの追加オプション
                        extraArgs = ''
                    }
                },
                -- キーマップ設定
                keymaps = {
                    replace = { n = '<leader>r' },
                    qflist = { n = '<leader>q' },
                    syncLocations = { n = '<leader>s' },
                    syncLine = { n = '<leader>l' },
                    close = { n = '<leader>c' },
                    historyOpen = { n = '<leader>t' },
                    historyAdd = { n = '<leader>a' },
                    refresh = { n = '<leader>f' },
                    openLocation = { n = '<leader>o' },
                    gotoLocation = { n = '<enter>' },
                    pickHistoryEntry = { n = '<enter>' },
                    abort = { n = '<leader>b' },
                    help = { n = 'g?' },
                    toggleShowCommand = { n = '<leader>p' },
                    swapEngine = { n = '<leader>e' }
                }
            })

            -- 現在のバッファで検索するコマンド
            vim.api.nvim_create_user_command('GrugFarCurrentBuffer', function()
                require('grug-far').open({
                    prefills = {
                        paths = vim.fn.expand('%:p') -- 現在のファイルのフルパス
                    }
                })
            end, {})

            -- カーソル下の単語を現在のバッファで検索
            vim.api.nvim_create_user_command('GrugFarCurrentWord', function()
                require('grug-far').open({
                    prefills = {
                        search = vim.fn.expand('<cword>'), -- カーソル下の単語
                        paths = vim.fn.expand('%:p')       -- 現在のファイル
                    }
                })
            end, {})
        end
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

    -- mini.basics（undo改善を含む基本設定）
    {
        "echasnovski/mini.basics",
        enabled = false,  -- まず無効にして既存機能との競合を避ける
        config = function()
            require('mini.basics').setup({
                options = {
                    basic = false,      -- 基本オプションは設定済みなので無効
                    extra_ui = false,   -- UIも設定済み
                    win_borders = 'default'
                },
                mappings = {
                    basic = false,      -- 基本マッピングは設定済み
                    option_toggle_prefix = '',  -- トグル機能は自前システムを使用
                    windows = false,    -- ウィンドウ操作は設定済み
                    move_with_alt = false, -- Alt移動は無効
                },
                autocommands = {
                    basic = false,      -- 基本autocmdは設定済み
                    relnum_in_visual_mode = false -- 相対行番号は手動制御
                }
            })
        end
    },

    -- より専用的なundo改善プラグイン
    {
        "machakann/vim-sandwich",
        enabled = false,  -- テスト用
        config = function()
            -- sandwichもundojoinを使ったundo統合をしている
        end
    },

}

