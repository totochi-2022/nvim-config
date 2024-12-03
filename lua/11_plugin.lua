-- 11_plugin.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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
vim.opt.rtp:prepend(lazypath)

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
                },
                extensions = {
                    command_palette = {
                        { "File",
                            { "entire selection (C-a)",  ':call feedkeys("GVgg")' },
                            { "save current file (C-s)", ':w' },
                            { "save all files (C-A-s)",  ':wa' },
                            { "quit (C-q)",              ':qa' },
                            { "file browser (C-i)", ":lua require'telescope'.extensions.file_browser.file_browser()", 1 },
                            { "search word (A-w)", ":lua require('telescope.builtin').live_grep()",  1 },
                            { "git files (A-f)",   ":lua require('telescope.builtin').git_files()",  1 },
                            { "files (C-f)",       ":lua require('telescope.builtin').find_files()", 1 },
                        },
                        { "Help",
                            { "tips",            ":help tips" },
                            { "cheatsheet",      ":help index" },
                            { "tutorial",        ":help tutor" },
                            { "summary",         ":help summary" },
                            { "quick reference", ":help quickref" },
                            { "search help(F1)", ":lua require('telescope.builtin').help_tags()", 1 },
                        },
                        { "Vim",
                            { "reload vimrc",              ":source $MYVIMRC" },
                            { 'check health',              ":checkhealth" },
                            { "jumps (Alt-j)",             ":lua require('telescope.builtin').jumplist()" },
                            { "commands",                  ":lua require('telescope.builtin').commands()" },
                            { "command history",           ":lua require('telescope.builtin').command_history()" },
                            { "registers (A-e)",           ":lua require('telescope.builtin').registers()" },
                            { "colorshceme",               ":lua require('telescope.builtin').colorscheme()",    1 },
                            { "vim options",               ":lua require('telescope.builtin').vim_options()" },
                            { "keymaps",                   ":lua require('telescope.builtin').keymaps()" },
                            { "buffers",                   ":Telescope buffers" },
                            { "search history (C-h)",      ":lua require('telescope.builtin').search_history()" },
                            { "paste mode",                ':set paste!' },
                            { 'cursor line',               ':set cursorline!' },
                            { 'cursor column',             ':set cursorcolumn!' },
                            { "spell checker",             ':set spell!' },
                            { "relative number",           ':set relativenumber!' },
                            { "search highlighting (F12)", ':set hlsearch!' },
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

    -- TreeSitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = ":TSUpdate",
        dependencies = {
            'JoosepAlviste/nvim-ts-context-commentstring',
            'RRethy/nvim-treesitter-endwise',
        },
        config = function()
            require('ts_context_commentstring').setup {
                enable_autocmd = true,
            }
            require('nvim-treesitter.configs').setup {
                endwise = {
                    enable = true,
                },
            }
        end,
    },

    -- 移動関連
    {
        "rainbowhxch/accelerated-jk.nvim",
        config = function()
            require('accelerated-jk').setup({
                mode = 'time_driven',
                enable_deceleration = false,
                acceleration_motions = { 'h', 'l', 'b', 'w', 'e', 'B', 'W', 'E', 'C-j', 'C-k' },
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
    {
        "unblevable/quick-scope",
        config = function()
            vim.g.qs_delay = 500
            vim.g.lazy_highlight = 1
            vim.g.qs_enable = 1
            vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
            vim.g.qs_hi_priority = 2
            vim.g.qs_filetype_blacklist = { "dashboard", "startify" }
        end,
    },
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
            require("which-key").setup {}
        end,
    },

    -- その他のプラグイン
    { "skanehira/denops-translate.vim", lazy = true },
    { "tyru/open-browser.vim" },
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui" },
    { "mfussenegger/nvim-dap-python" },
    { "vim-jp/vimdoc-ja", lazy = true },

    {
        "iamcco/markdown-preview.nvim",
        ft = { 'markdown' },
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },

    { "rbtnn/vim-jumptoline" },
    { "khaveesh/vim-fish-syntax", ft = { 'fish' } },
    { "kamykn/popup-menu.nvim" },
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
