-- 11_plugin.lua
local lazypath = vim.fn.stdpath("data") .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end


local config = {}
vim.opt.rtp:prepend(lazypath)
-- Windows環境の場合は並列数を制限
if vim.fn.has('win32') == 1 then
    config.concurrency = 1
else
    config.concurrency = 10 -- WSL2ではより多くの並列処理を許可
end

if vim.fn.has('win64') then
    -- vim.g.sqlite_clib_path = 'c:/bin/local/sqlite3.dll'
    vim.g.direnv_auto = 0
end
vim.opt.timeoutlen = 300 --すぐ出るように

require("lazy").setup({
    -- コアライブラリ
    { "tpope/vim-repeat" },
    { "nvim-lua/popup.nvim" },
    { "nvim-lua/plenary.nvim" },
    { "nvim-tree/nvim-web-devicons" },
    { "rcarriga/nvim-notify" },
    { "kana/vim-textobj-user" },

    { "kana/vim-operator-user" },

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
                    icons_enabled = true,
                    theme = 'auto',
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
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            'kkharji/sqlite.lua',
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-ghq.nvim',
            'nvim-telescope/telescope-frecency.nvim',
            'nvim-telescope/telescope-file-browser.nvim',
            'LinArcX/telescope-command-palette.nvim',
        },
        config = function()
            require('telescope').setup({
                extensions = {
                    command_palette = {
                        { "Convert",
                            { "Encoding",    "lua vim.cmd[[Telescope command_palette theme=ivy categories=Encoding\\ Menu]]" },
                            { "Line Ending", "lua vim.cmd[[Telescope command_palette theme=ivy categories=Line\\ Menu]]" },
                        },
                        { "Encoding Menu",
                            { "UTF-8",         "lua vim.cmd[[Telescope command_palette theme=ivy categories=UTF8\\ Menu]]" },
                            { "Japanese",      "lua vim.cmd[[Telescope command_palette theme=ivy categories=Japanese\\ Menu]]" },
                            { "Check Current", "set fileencoding?" },
                        },
                        { "UTF8 Menu",
                            { "Normal",   "set fileencoding=utf-8" },
                            { "with BOM", "set fileencoding=utf-8-bom" },
                        },
                        { "Japanese Menu",
                            { "Shift-JIS", "set fileencoding=cp932" },
                            { "EUC-JP",    "set fileencoding=euc-jp" },
                        },
                        { "Line Menu",
                            { "Format",  "lua vim.cmd[[Telescope command_palette theme=ivy categories=Format\\ Menu]]" },
                            { "Convert", "lua vim.cmd[[Telescope command_palette theme=ivy categories=Convert\\ Menu]]" },
                        },
                        { "Format Menu",
                            { "Windows (CRLF)", "set fileformat=dos" },
                            { "Unix (LF)",      "set fileformat=unix" },
                            { "Mac (CR)",       "set fileformat=mac" },
                        },
                        { "Convert Menu",
                            { "CRLF to LF", "%s/\\r\\n/\\n/g" },
                            { "Remove CR",  "%s/\\r//g" },
                        },
                    }
                    -- command_palette = {
                    --     { "Convert",
                    --         { "Encoding/Text/UTF-8/Normal",       ":set fileencoding=utf-8" },
                    --         { "Encoding/Text/UTF-8/with BOM",     ":set fileencoding=utf-8-bom" },
                    --         { "Encoding/Text/Japanese/Shift-JIS", ":set fileencoding=cp932" },
                    --         { "Encoding/Text/Japanese/EUC-JP",    ":set fileencoding=euc-jp" },
                    --         { "Encoding/Binary/UTF-16/LE",        ":set fileencoding=utf-16le" },
                    --         { "Encoding/Binary/UTF-16/BE",        ":set fileencoding=utf-16be" },
                    --         { "Line Ending/Format/Windows/CRLF",  ":set fileformat=dos" },
                    --         { "Line Ending/Format/Unix/LF",       ":set fileformat=unix" },
                    --         { "Line Ending/Format/Mac/CR",        ":set fileformat=mac" },
                    --         { "Line Ending/Convert/CRLF to LF",   ":%s/\\r\\n/\\n/g" },
                    --         { "Line Ending/Convert/Remove CR",    ":%s/\\r//g" },
                    --         { "Status/Check/Encoding",            ":set fileencoding?" },
                    --         { "Status/Check/Format",              ":set fileformat?" },
                    --     },
                    --     { "Convert",      -- 新しいトップレベルカテゴリ
                    --         { "Encoding", -- 文字コード変換サブカテゴリ
                    --             { "UTF-8", ":set fileencoding=utf-8" },
                    --             { "UTF-8 (BOM付き)", ":set fileencoding=utf-8-bom" },
                    --             { "UTF-16", ":set fileencoding=utf-16" },
                    --             { "EUC-JP", ":set fileencoding=euc-jp" },
                    --             { "Shift-JIS", ":set fileencoding=cp932" },
                    --             { "Check Current", ":set fileencoding?" },
                    --         },
                    --         { "Line Ending", -- 改行コード変換サブカテゴリ
                    --             { "Unix (LF)",      ":set fileformat=unix" },
                    --             { "Windows (CRLF)", ":set fileformat=dos" },
                    --             { "Mac (CR)",       ":set fileformat=mac" },
                    --             { "Check Current",  ":set fileformat?" },
                    --         },
                    --         { "Line Ending Batch", -- 改行一括変換
                    --             { "CRLF → LF (改行を Unix 形式に)", ":%s/\\r\\n/\\r/g" },
                    --             { "Remove CR (^M の削除)", ":%s/\\r//g" },
                    --         },
                    --     },
                    --     { "File",
                    --         { "entire selection (C-a)",  ':call feedkeys("GVgg")' },
                    --         { "save current file (C-s)", ':w' },
                    --         { "save all files (C-A-s)",  ':wa' },
                    --         { "quit (C-q)",              ':qa' },
                    --         { "file browser (C-i)",      ":lua require'telescope'.extensions.file_browser.file_browser()", 1 },
                    --         { "search word (A-w)",       ":lua require('telescope.builtin').live_grep()",                  1 },
                    --         { "git files (A-f)",         ":lua require('telescope.builtin').git_files()",                  1 },
                    --         { "files (C-f)",             ":lua require('telescope.builtin').find_files()",                 1 },
                    --     },
                    --     { "Help",
                    --         { "tips",            ":help tips" },
                    --         { "cheatsheet",      ":help index" },
                    --         { "tutorial",        ":help tutor" },
                    --         { "summary",         ":help summary" },
                    --         { "quick reference", ":help quickref" },
                    --         { "search help(F1)", ":lua require('telescope.builtin').help_tags()", 1 },
                    --     },
                    --     { "Vim",
                    --         { "reload vimrc",              ":source $MYVIMRC" },
                    --         { 'check health',              ":checkhealth" },
                    --         { "jumps (Alt-j)",             ":lua require('telescope.builtin').jumplist()" },
                    --         { "commands",                  ":lua require('telescope.builtin').commands()" },
                    --         { "command history",           ":lua require('telescope.builtin').command_history()" },
                    --         { "registers (A-e)",           ":lua require('telescope.builtin').registers()" },
                    --         { "colorshceme",               ":lua require('telescope.builtin').colorscheme()",    1 },
                    --         { "vim options",               ":lua require('telescope.builtin').vim_options()" },
                    --         { "keymaps",                   ":lua require('telescope.builtin').keymaps()" },
                    --         { "buffers",                   ":Telescope buffers" },
                    --         { "search history (C-h)",      ":lua require('telescope.builtin').search_history()" },
                    --         { "paste mode",                ':set paste!' },
                    --         { 'cursor line',               ':set cursorline!' },
                    --         { 'cursor column',             ':set cursorcolumn!' },
                    --         { "spell checker",             ':set spell!' },
                    --         { "relative number",           ':set relativenumber!' },
                    --         { "search highlighting (F12)", ':set hlsearch!' },
                    --     }

                    -- }
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
    -- TreeSitterの設定を更新
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
                    { "<LocalLeader>s", mode = { "o", "x" } },
                },
            },
            {
                'David-Kunz/treesitter-unit',
                event = "VeryLazy",
                keys = {
                    { "iu", mode = { "o", "x" } },
                    { "au", mode = { "o", "x" } },
                },
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
                -- 自動フォールディングの設定
                folding = {
                    enable = true,
                },
            }

            -- TreesitterベースのFoldingを有効化
            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
            -- デフォルトでは折りたたまない
            vim.opt.foldenable = false
            vim.opt.foldlevel = 99
        end,
    },


    -- アウトライン表示用のSymbols-outline
    {
        'simrat39/symbols-outline.nvim',
        config = function()
            require('symbols-outline').setup({
                -- 既存の設定はそのままで
                symbols = {
                    -- 変数関連の表示設定
                    Variable = { icon = "", hl = "@constant", hide = true }, -- すべての変数を非表示
                    Constant = { icon = "", hl = "@constant" },              -- 定数は表示

                    -- その他のシンボルは表示したいものだけ残す
                    File = { icon = "", hl = "@text.uri" },
                    Module = { icon = "󰕳", hl = "@namespace" },
                    Namespace = { icon = "󰌗", hl = "@namespace" },
                    Package = { icon = "󰏖", hl = "@namespace" },
                    Class = { icon = "󰌗", hl = "@type" },
                    Method = { icon = "󰆧", hl = "@method" },
                    Function = { icon = "󰊕", hl = "@function" },
                    Struct = { icon = "󰌗", hl = "@type" },
                    Interface = { icon = "", hl = "@type" },
                },

                -- 表示フィルター設定
                filter_kind = {
                    -- デフォルトで表示するシンボルの種類を指定
                    "Class",
                    -- "Constructor",
                    -- "Enum",
                    "Function",
                    -- "Interface",
                    "Method",
                    "Module",
                    -- "Namespace",
                    -- "Package",
                    "Struct",
                    -- "Variable",  -- コメントアウトすると変数は表示されない
                },
            })
        end,
    },


    -- TreeSitter
    -- {
    --     'nvim-treesitter/nvim-treesitter',
    --     build = ":TSUpdate",
    --     dependencies = {
    --         'JoosepAlviste/nvim-ts-context-commentstring',
    --         'RRethy/nvim-treesitter-endwise',
    --     },
    --     config = function()
    --         require('ts_context_commentstring').setup {
    --             enable_autocmd = true,
    --         }
    --         require('nvim-treesitter.configs').setup {
    --             endwise = {
    --                 enable = true,
    --             },
    --         }
    --     end,
    -- },

    -- 移動関連
    {
        "rainbowhxch/accelerated-jk.nvim",
        config = function()
            require('accelerated-jk').setup({
                mode = 'time_driven',
                enable_deceleration = false,
                mapping = {
                    -- ノーマルモードの設定
                    n = {
                        j = 'gj',
                        k = 'gk',
                        -- 他のモーション
                        h = 'h',
                        l = 'l',
                        b = 'b',
                        w = 'w',
                        e = 'e',
                        B = 'B',
                        W = 'W',
                        E = 'E',
                    },
                    -- ビジュアルモードの設定
                    x = {
                        j = 'gj',
                        k = 'gk',
                        -- 他のモーション
                        h = 'h',
                        l = 'l',
                        b = 'b',
                        w = 'w',
                        e = 'e',
                        B = 'B',
                        W = 'W',
                        E = 'E',
                    },
                },
                acceleration_motions = { 'j', 'k', 'h', 'l', 'b', 'w', 'e', 'B', 'W', 'E', 'C-j', 'C-k' },
                acceleration_limit = 150,
                acceleration_table = { 7, 12, 17, 21, 24, 28, 31, 40 },
                deceleration_table = { { 150, 9999 } }
            })
        end,
    },
    {
        "easymotion/vim-easymotion",
        init = function()
            vim.g.EasyMotion_do_mapping = 0
            vim.g.EasyMotion_use_migemo = 1
        end,
    },
    { "osyo-manga/vim-milfeulle", lazy = true },
    { "haya14busa/vim-edgemotion" },

    -- 検索関連
    { "haya14busa/vim-asterisk" },
    -- {
    --     "unblevable/quick-scope",
    --     config = function()
    --         vim.g.qs_delay = 500
    --         vim.g.lazy_highlight = 1
    --         vim.g.qs_enable = 1
    --         vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
    --         vim.g.qs_hi_priority = 2
    --         vim.g.qs_filetype_blacklist = { "dashboard", "startify" }
    --     end,
    -- },
    {
        "haya14busa/incsearch-migemo.vim",
        dependencies = { "haya14busa/incsearch.vim" },
    },
    {
        "kevinhwang91/nvim-hlslens",
        event = { "CmdlineEnter" },
        config = function()
            require('hlslens').setup()
        end,
    },

    -- 括弧関連
    { "andymass/vim-matchup" },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup {}
        end,
    },
    {
        "kylechui/nvim-surround",
        version = "*",
        config = function()
            require("nvim-surround").setup()
        end
    },

    -- インデント表示
    {
        'shellRaining/hlchunk.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            require('hlchunk').setup({
                chunk = {
                    enable = true
                },
                indent = {
                    enable = true
                }
            })
        end
    },

    -- フォールド関連
    {
        "LeafCage/foldCC.vim",
        init = function()
            vim.g.foldCCtext_enable_autofdc_adjuster = 1
            vim.g.foldCCtext_maxchars = 78
            vim.g.foldCCtext_head = "'▸▸'"
            vim.g.foldCCtext_tail = 'printf("[%4d lines (lv%d)]", v:foldend-v:foldstart+1, v:foldlevel)'
            vim.opt.foldtext = 'FoldCCtext()'
        end,
    },

    -- テキストオブジェクト


    -- テキストオブジェクト関連のプラグインすべてにdependenciesを追加
    {
        "kana/vim-textobj-line",
        dependencies = { "kana/vim-textobj-user" }
    },
    {
        "kana/vim-textobj-entire",
        dependencies = { "kana/vim-textobj-user" }
    },
    {
        "osyo-manga/vim-textobj-multiblock",
        dependencies = { "kana/vim-textobj-user" }
    },
    {
        "osyo-manga/vim-textobj-from_regexp",
        dependencies = { "kana/vim-textobj-user" }
    },
    {
        "rhysd/vim-textobj-anyblock",
        dependencies = { "kana/vim-textobj-user" }
    },
    {
        "sgur/vim-textobj-parameter",
        dependencies = { "kana/vim-textobj-user" }
    },
    {
        "glts/vim-textobj-comment",
        dependencies = { "kana/vim-textobj-user" }
    },

    {
        "terryma/vim-expand-region",
        config = function()
            vim.g.expand_region_text_objects = {
                ['iw'] = 0,
                ['iW'] = 0,
                ['i"'] = 1,
                ['i\''] = 1,
                ['i]'] = 1,
                ['ib'] = 1,
                ['iB'] = 1,
                ['il'] = 1,
                ['ip'] = 0,
                ['ie'] = 0,
            }
        end,
    },

    -- マーク
    {
        "chentoast/marks.nvim",
        config = function()
            require("marks").setup {
                default_mappings = false,
            }
        end,
    },

    -- ターミナル
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup({
                open_mapping = [[<F5>]],
                start_in_insert = true,
                direction = 'float',
                winbar = {
                    enabled = false,
                    name_formatter = function(term)
                        return term.name
                    end
                },
            })
        end
    },

    -- コメント
    {
        "scrooloose/nerdcommenter",
        init = function()
            vim.g.NERDCreateDefaultMappings = 0
            vim.g.NERDSpaceDelims = 1
            vim.g.NERDDefaultAlign = 'left'
        end,
    },

    -- 実行
    {
        "thinca/vim-quickrun",
        dependencies = {
            { "Shougo/vimproc.vim", build = "make" }
        },
        init = function()
            vim.g.quickrun_config = {
                _ = {
                    ['runner'] = 'vimproc',
                    ['runner/vimproc/updatetime'] = 1,
                    ['hook/time/enable'] = 1,
                    ['outputter/buffer/opener'] = 'below new',
                    ['outputter/buffer/into'] = 1,
                    ['outputter/buffer/close_on_empty'] = 1,
                }
            }
        end,
    },

    {
        "is0n/jaq-nvim",
        config = function()
            require('jaq-nvim').setup {
                cmds = {
                    internal = {
                        lua = "luafile %",
                        vim = "source %",
                        markdown = "MarkdownPreview",
                    },
                    external = {
                        python = "python3 %",
                        go     = "go run %",
                        sh     = "sh %",
                        ruby   = "ruby %",
                        fish   = "source %",
                        bash   = "bash %",
                    }
                },
                behavior = {
                    default     = "bang",
                    startinsert = false,
                    wincmd      = false,
                    autosave    = true,
                },
                ui = {
                    float = {
                        border   = "rounded",
                        winhl    = "Normal",
                        borderhl = "FloatBorder",
                        winblend = 0,
                        height   = 0.8,
                        width    = 0.8,
                        x        = 0.5,
                        y        = 0.5
                    },
                    terminal = {
                        position = "bot",
                        size = 10,
                        line_no = false
                    },
                    quickfix = {
                        position = "bot",
                        size = 10
                    },
                }
            }
        end,
    },

    -- Undo関連
    {
        "simnalamburt/vim-mundo",
    },


    --     "mbbill/undotree",
    --     config = function()
    --         -- diffパネルの高さを設定（デフォルトは10）
    --         vim.g.undotree_DiffpanelHeight = 15

    --         -- diffパネルを右側に表示（デフォルトは下部）
    --         vim.g.undotree_DiffAutoOpen = 1

    --         -- ウィンドウレイアウト
    --         -- 1: undotree左 | buffer | diffpanel右
    --         -- 2: undotree左 | buffer下diffpanel
    --         -- 3: undotree右 | buffer | diffpanel左
    --         -- 4: undotree右 | buffer下diffpanel
    --         vim.g.undotree_WindowLayout = 2

    --         -- フォーカス時に自動的にdiffを更新
    --         vim.g.undotree_DiffAutoOpen = 1

    --         -- 保存された変更を強調表示
    --         vim.g.undotree_HighlightSavedText = 1

    --         -- ウィンドウを開いた時に自動的にフォーカス
    --         vim.g.undotree_SetFocusWhenToggle = 1
    --     end,
    -- },
    -- 11_plugin.lua のundotreeの設定を更新


    {
        "jiaoshijie/undotree",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require('undotree').setup({
                float_diff = true,      -- フローティングウィンドウで差分表示
                layout = "left",        -- ツリーを左側に表示
                position = "left",      -- パネルの位置
                window = {
                    winblend = 0,       -- 透明度（0で不透明）
                    border = "rounded", -- ウィンドウの境界線スタイル
                },
                keymaps = {
                    -- キーマップのカスタマイズ
                    ["j"] = "move_next",
                    ["k"] = "move_prev",
                    ["gj"] = "move2parent",
                    ["gh"] = "move2parent",
                    ["<cr>"] = "action_enter",
                    ["p"] = "enter_diffbuf",
                    ["q"] = "quit",
                },
            })
            -- キーマップ設定
            vim.keymap.set('n', '<Leader>ut', require('undotree').toggle)
        end,
    },



    -- ヤンク関連
    {
        "gbprod/yanky.nvim",
        config = function()
            require("yanky").setup {
                ring = {
                    history_length = 100,
                    storage = "shada",
                    sync_with_numbered_registers = true,
                    cancel_event = "update",
                },
                system_clipboard = {
                    sync_with_ring = true,
                },
            }
        end,
    },

    -- バッファリサイズ
    {
        "kwkarlwang/bufresize.nvim",
        config = function()
            require("bufresize").setup()
        end,
    },

    -- その他のツール
    { "junegunn/vim-easy-align" },
    { "t9md/vim-quickhl" },
    -- operator関連
    {
        "jamesl33/vim-operator-convert-case",
        dependencies = {
            "kana/vim-operator-user",
            "tpope/vim-repeat",
        }
    },
    { "jamesl33/vim-operator-convert-case" },

    {
        "mizlan/iswap.nvim",
        config = function()
            require('iswap').setup {
                keys = 'qwertyuiop',
                grey = 'disable',
                hl_snipe = 'ErrorMsg',
                hl_selection = 'WarningMsg',
                hl_grey = 'LineNr',
                flash_style = true,
                hl_flash = 'ModeMsg',
                move_cursor = true,
                autoswap = true,
                debug = nil,
                hl_grey_priority = '1000',
            }
        end,
    },

    {
        "m-demare/hlargs.nvim",
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        config = function()
            require('hlargs').setup {}
        end,
    },

    { "Shougo/vinarise" },

    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require('colorizer').setup()
            vim.g.colorizer_nomap = 0
            vim.g.colorizer_startup = 0
        end,
    },

    {
        "mg979/vim-visual-multi",
        init = function()
            vim.g.VM_maps = {
                ["Select Operator"] = '<LocalLeader>aa',
                ["Reselect Last"] = '<LocalLeader>ag',
                ["Select All"] = '<LocalLeader>aA',
                ["Visual All"] = '<LocalLeader>aA',
                ["Find Subword Under"] = '<LocalLeader>a*',
                ["Find Under"] = '<LocalLeader>a*',
                ["Visual Regex"] = '<LocalLeader>a/',
                ["Start Regex Search"] = '<LocalLeader>a/',
                ["Undo"] = 'u',
                ["Redo"] = 'U',
                ["Exit"] = '<ESC>',
            }
            vim.g.VM_highlight_matches = 'hi Search ctermfg=228 cterm=underline'
            vim.g.VM_default_mappings = 0
            vim.g.VM_mouse_mappings = 0
        end,
    },

    -- コマンドライン関連
    { "tyru/capture.vim" },
    {
        "VonHeikemen/fine-cmdline.nvim",
        dependencies = {
            { "MunifTanjim/nui.nvim" }
        },
        config = function()
            local fineline = require('fine-cmdline')
            local fn = fineline.fn
            fineline.setup({
                cmdline = {
                    enable_keymaps = false,
                    smart_history = true,
                    prompt = ':'
                },
                popup = {
                    relative = "cursor",
                    position = {
                        row = 2,
                        col = -2,
                    },
                    buf_options = {
                        filetype = 'FineCmdlinePrompt'
                    },
                },
                win_options = {
                    winblend = 20,
                    winhighlight = 'Normal:Normal,FloatBorder;FloatBorder',
                },
                hooks = {
                    set_keymaps = function(imap, _)
                        imap('<Esc>', fn.close)
                        imap('<C-c>', fn.close)
                        imap('<Tab>', '<C-x><C-o>')
                        imap('<Up>', fn.up_search_history)
                        imap('<Down>', fn.down_search_history)
                        imap('<c-o>', fn.up_search_history)
                        imap('<c-i>', fn.down_search_history)
                        imap('<c-k>', fn.up_history)
                        imap('<c-j>', fn.down_history)
                    end
                },
            })
        end,
    },

    -- WhichKey
    {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup {

                plugins = {
                    marks = true,
                    registers = true,
                    spelling = {
                        enabled = false,
                    },
                    presets = {
                        operators = true,
                        motions = true,
                        text_objects = true,
                        windows = true,
                        nav = true,
                        z = true,
                        g = true,
                    },
                },
                -- キーマップの重複警告を無視する設定を追加
                ignore_warning = {
                    overlap = true, -- 重複するキーマップの警告を無視
                },
            }
        end,



    },

    {
        "debugloop/telescope-undo.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim"
        },
        config = function()
            require("telescope").setup({
                extensions = {
                    undo = {
                        use_delta = true,
                        side_by_side = true,
                        layout_strategy = "vertical",
                        layout_config = {
                            preview_height = 0.8,
                            width = 0.95,
                        },
                        -- 非推奨のdiff_context_linesの代わりに新しい設定を使用
                        vim_diff_opts = {
                            ctxlen = -1, -- 全行を表示
                        },
                        delta_options = {
                            side_by_side = true,
                            line_numbers = true,
                            width = -1,
                            syntax_highlighting = true,
                            minus_style = "syntax bold red",
                            plus_style = "syntax bold green",
                            zero_style = "syntax",
                            line_numbers_minus_style = "red",
                            line_numbers_plus_style = "green",
                            keep_plus_minus_markers = true,
                        },
                    },
                },
            })
            require("telescope").load_extension("undo")
        end,
    },
    -- {
    --     "debugloop/telescope-undo.nvim",
    --     dependencies = {
    --         "nvim-telescope/telescope.nvim",
    --         "nvim-lua/plenary.nvim"
    --     },
    --     config = function()
    --         require("telescope").setup({
    --             extensions = {
    --                 undo = {
    --                     use_delta = true,
    --                     side_by_side = true,
    --                     layout_strategy = "vertical",
    --                     layout_config = {
    --                         preview_height = 0.8, -- プレビュー領域を大きく
    --                         width = 0.95,     -- ウィンドウ幅を広く
    --                     },
    --                     diff_context_lines = -1, -- すべての行を表示
    --                     delta_options = {
    --                         side_by_side = true, -- 横並びで表示
    --                         line_numbers = true, -- 行番号表示
    --                         width = -1,       -- フル幅で表示
    --                         syntax_highlighting = true,
    --                         -- 変更箇所のみ色付け
    --                         minus_style = "syntax bold red", -- 削除行
    --                         plus_style = "syntax bold green", -- 追加行
    --                         zero_style = "syntax",        -- 変更なし行（通常の色）
    --                         -- 行番号の色
    --                         line_numbers_minus_style = "red",
    --                         line_numbers_plus_style = "green",
    --                         -- 変更箇所のみマーカーを表示
    --                         keep_plus_minus_markers = true,
    --                     },
    --                 },
    --             },
    --         })
    --         require("telescope").load_extension("undo")

    --         -- キーマップ設定
    --         vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
    --     end,
    -- },



    -- その他のプラグイン
    {
        'rhysd/clever-f.vim',
        config = function()
            vim.g.clever_f_smart_case = 1
            -- vim.g.clever_f_use_migemo = vim.g.incsearch_use_migemo or 0 -- 現在のmigemo状態に合わせる
            vim.g.clever_f_use_migemo = 1
            vim.g.clever_f_fix_key_direction = 1
            vim.g.clever_f_timeout_ms = 2000                            -- タイムアウト時間（ミリ秒）
            vim.g.clever_f_across_no_line = 0                           -- 0に設定すると改行を超えて検索します
            vim.g.clever_f_mark_direct = 1
            vim.g.clever_f_all_objects = 1
        end
    },
    { "skanehira/denops-translate.vim", lazy = true },
    { "tyru/open-browser.vim" },
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui" },
    { "mfussenegger/nvim-dap-python" },
    { "vim-jp/vimdoc-ja",               lazy = true },

    {
        "iamcco/markdown-preview.nvim",
        ft = { 'markdown' },
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },

    { "rbtnn/vim-jumptoline" },
    { "khaveesh/vim-fish-syntax", ft = { 'fish' } },
    -- { "kamykn/popup-menu.nvim" },


    {
        "kamykn/popup-menu.nvim",
        config = function()
            -- 基本設定
            vim.g.popup_menu_borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
        end,
    },
    {
        "osyo-manga/vim-precious",
        dependencies = { "Shougo/context_filetype.vim" }
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        }
    },
}, {
    concurrency = config.concurrency, -- 同時ダウンロード数を1に制限
    ui = {
        border = "rounded"
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip", "tar", "tarPlugin", "zip", "zipPlugin",
                "getscript", "getscriptPlugin", "vimball", "vimballPlugin",
                "2html_plugin", "logipat", "rrhelper", "netrw",
                "netrwPlugin", "netrwSettings", "netrwFileHandlers"
            },
        },
    },
    install = {
        colorscheme = { "habamax" }
    },
    -- 先ほどの設定に追加
    -- {
    --     "yioneko/nvim-yati",
    --     dependencies = { 'nvim-treesitter/nvim-treesitter' },
    -- },

    -- {
    --     "numToStr/Comment.nvim",
    --     config = function()
    --         require('Comment').setup {
    --             padding = true,
    --             sticky = true,
    --             ignore = nil,
    --             toggler = {
    --                 line = '<LocalLeader>cc',
    --                 block = '<localleader>CC',
    --             },
    --             opleader = {
    --                 line = '<LocalLeader>c',
    --                 block = '<LocalLeader>C',
    --             },
    --             extra = {
    --                 above = '<LocalLeader>cO',
    --                 below = '<LocalLeader>co',
    --                 eol = '<LocalLeader>cA',
    --             },
    --             mappings = {
    --                 basic = true,
    --                 extra = true,
    --             },
    --             pre_hook = nil,
    --             post_hook = nil,
    --         }
    --     end,
    -- },

    -- {
    --     "anuvyklack/pretty-fold.nvim",
    --     config = function()
    --         require('pretty-fold').setup()
    --     end
    -- },

    -- {
    --     "anuvyklack/fold-preview.nvim",
    --     dependencies = { "anuvyklack/keymap-amend.nvim" },
    --     config = function()
    --         require('fold-preview').setup({
    --             auto = 1000,
    --             auto_close = true,
    --             border = 'rounded',
    --         })
    --     end
    -- },

    -- {
    --     "rmagatti/session-lens",
    --     dependencies = {
    --         'rmagatti/auto-session',
    --         'nvim-telescope/telescope.nvim'
    --     },
    --     config = function()
    --         vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
    --         require('auto-session').setup {
    --             auto_session_enable_last_session = false,
    --         }
    --         require('session-lens').setup {
    --             path_display = { 'shorten' },
    --         }
    --     end
    -- },

    -- { "vim-scripts/indentLine.vim" },

    -- {
    --     "lukas-reineke/indent-blankline.nvim",
    --     config = function()
    --         require("ibl").setup {
    --             indent = { highlight = {"CursorColumn", "Whitespace",}, char = "" },
    --             whitespace = {
    --                 highlight = {"CursorColumn", "Whitespace",},
    --                 remove_blankline_trail = true,
    --             },
    --             scope = { enabled = true },
    --         }
    --     end,
    -- },

    -- { "direnv/direnv.vim" },

    -- {
    --     "notjedi/nvim-rooter.lua",
    --     config = function()
    --         require('nvim-rooter').setup {
    --             rooter_patterns = { '.git', '.hg', '.svn' },
    --             trigger_patterns = { '*' },
    --             manual = false,
    --         }
    --     end,
    -- },
})
