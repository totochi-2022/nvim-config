vim.cmd 'packadd packer.nvim' -- ../init.lua
if vim.fn.has('win64') then
    -- vim.g.sqlite_clib_path = 'c:/bin/local/sqlite3.dll'
    vim.g.direnv_auto = 0
end
vim.opt.timeoutlen = 300 --すぐ出るように
require 'packer'.startup({
    function()
        use { 'wbthomason/packer.nvim', opt = true }
        --}}}

        --- libraray ---{{{
        use { 'tpope/vim-repeat', opt = false }
        use { 'nvim-lua/popup.nvim', opt = false }
        use { 'nvim-lua/plenary.nvim', opt = false }
        use { 'nvim-tree/nvim-web-devicons', opt = false }
        use { 'rcarriga/nvim-notify', opt = false }
        use { 'kana/vim-textobj-user', opt = false }
        use { 'kana/vim-operator-user', opt = false }
        --}}}

        --- color scheme ---{{{
        use { 'EdenEast/nightfox.nvim' }
        use { 'glepnir/zephyr-nvim' }
        use { 'folke/tokyonight.nvim' }
        use { 'morhetz/gruvbox' }
        use { 'kyoz/purify',
            rtp = 'vim'
        }

        --}}}

        --- fuzzy finder ---{{{
        use { 'nvim-telescope/telescope.nvim',
            --{{{
            requires = {
                'kkharji/sqlite.lua',    -- frecencyのDB
                'nvim-lua/plenary.nvim', -- library
                'nvim-telescope/telescope-ghq.nvim',
                'nvim-telescope/telescope-frecency.nvim',
                'nvim-telescope/telescope-file-browser.nvim',
                'LinArcX/telescope-command-palette.nvim',
            },
            config = function()
                require('telescope').setup({
                    pickers = {
                        buffers = {
                            -- {{{
                            show_all_buffers = true,
                            sort_lastused = true,
                            mappings = {
                                i = {
                                        ["<c-k>"] = "delete_buffer",
                                }
                            }
                        } -- }}}
                    },
                    extensions = {
                        command_palette = { -- {{{
                            { "File",
                                { "entire selection (C-a)",  ':call feedkeys("GVgg")' },
                                { "save current file (C-s)", ':w' },
                                { "save all files (C-A-s)",  ':wa' },
                                { "quit (C-q)",              ':qa' },
                                { "file browser (C-i)", ":lua require'telescope'.extensions.file_browser.file_browser()",
                                    1 },
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
                        } -- }}}
                    }
                })

                require('telescope').load_extension('ghq')
                require('telescope').load_extension('frecency')
                require('telescope').load_extension('file_browser')
                require('telescope').load_extension('command_palette')
            end,
        } --}}}}}}

        --- status line ---{{{
        use { 'nvim-lualine/lualine.nvim',
            --{{{
            requires = {
                'nvim-tree/nvim-web-devicons',
                'j-hui/fidget.nvim',
            },
            config = function()
                require('fidget').setup {}
                require('lualine').setup {
                    options = {
                        -- g:laststatus が3の時だけ、globalstatus を有効に
                        -- globalstatus = assert(load([[if vim.g.laststatus == 3 then true else false end]])()),
                        -- globalstatus = true,
                        icons_enabled = true,
                        theme = 'auto',
                    },
                    sections = {
                        lualine_a = { 'mode' },
                        lualine_b = { 'branch', 'diff', 'diagnostics' },
                        lualine_c = { 'filename' },
                        lualine_x = {
                            -- { require('auto-session-library').current_session_name },
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
        } --}}}
        -- use { 'akinsho/bufferline.nvim',
        --     -- {{{
        --     tag = "v3.*",
        --     requires = 'vim-tree/nvim-web-devicons',
        --     options = {
        --         custom_filter = function(buf_number)
        --             if not not vim.api.nvim_buf_get_name(buf_number):find(vim.fn.getcwd(), 0, true) then
        --                 return true
        --             end
        --         end
        --     },
        --     config = function()
        --         require("bufferline").setup {}
        --     end,
        -- } -- }}}
        --}}}

        --- treesitter ---{{{
        use({
            'nvim-treesitter/nvim-treesitter',
            --{{{
            requires = {
                'JoosepAlviste/nvim-ts-context-commentstring',
                -- 'yioneko/nvim-yati',
            },
            config = function()
                -- require("nvim-treesitter.configs").setup {
                --     context_commentstring = { enable = true },
                --     yati = { enable = true },
                -- }
                    require('ts_context_commentstring').setup {
                        enable_autocmd = true,
                    }

            end,
        }) --}}}
        --}}}

        --- lsp ---{{{
        use { 'williamboman/mason.nvim' }
        use { 'williamboman/mason-lspconfig.nvim' }
        use { 'jayp0521/mason-null-ls.nvim' }
        use { 'neovim/nvim-lspconfig' }
        -- use({ 'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
        use({
            'Maan2003/lsp_lines.nvim',
            --{{{
            config = function()
                vim.g.toggle_diag_state = 1
                ToggleDiagDisp(false)
                require("lsp_lines").setup()
                -- vim.diagnostic.config({ virtual_text = false })
            end,
        })

        --}}}
        use { 'hrsh7th/cmp-nvim-lsp' }
        --}}}

        --- cmp --- {{{
        use { 'hrsh7th/nvim-cmp' }
        use { 'hrsh7th/vim-vsnip' }
        use { 'hrsh7th/cmp-buffer' }
        use { 'hrsh7th/cmp-path' }
        use { 'onsails/lspkind-nvim' }
        use { 'hrsh7th/cmp-cmdline' }

        -- use { 'jose-elias-alvarez/null-ls.nvim' }
        use { 'nvimtools/none-ls.nvim'}
        use { 'hrsh7th/cmp-omni' }
        use { 'hrsh7th/cmp-emoji' }
        -- use { 'hrsh7th/cmp-calc' };
        -- use { 'f3fora/cmp-spell' }
        -- use { 'outkat/cmp-mocword' }
        -- use { 'uga-rosa/cmp-dictionary' }
        use { 'tzachar/cmp-tabnine', run = "./install.sh" }
        --}}}

        --- moving ---{{{
        use { 'rainbowhxch/accelerated-jk.nvim',
            --{{{
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
        } --}}}
        use { 'easymotion/vim-easymotion',
            --{{{
            setup = {
                'vim.g.EasyMotion_do_mapping = 0', -- mappingは自分で
                'vim.g.EasyMotion_use_migemo = 1',
            },
        }                                              --}}}
        use { 'osyo-manga/vim-milfeulle', opt = true } -- jump history  current buffer

        use { 'haya14busa/vim-edgemotion' }
        --}}}

        --- search ---{{{
        use { 'haya14busa/vim-asterisk' }

        use { 'unblevable/quick-scope',
            -- {{{
            config = function()
                vim.g.qs_delay = 500
                vim.g.lazy_highlight = 1
                vim.g.qs_enable = 1
                vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
                vim.g.qs_hi_priority = 2
                vim.g.qs_filetype_blacklist = { "dashboard", "startify" }
            end,
        } -- }}}
        use { 'haya14busa/incsearch-migemo.vim',
            --{{{
            requires = { 'haya14busa/incsearch.vim' },
        } --}}}
        use { 'kevinhwang91/nvim-hlslens',-- {{{
           config = require('hlslens').setup()
        } -- }}}
        -- use { 'rhysd/clever-f.vim',{{{
        --     config = function()
        --         vim.g.clever_f_smart_case = 0
        --         vim.g.clever_f_use_migemo = 1
        --         vim.g.clever_f_across_no_line = 0
        --         vim.g.clever_f_fix_key_direction = 1
        --         vim.g.clever_f_chars_match_any_signs = ';'
        --     end,
        -- } }}}
        -- }}}

        --- brackets ---{{{
        use { 'andymass/vim-matchup' }

        use { 'windwp/nvim-autopairs',
            -- {{{
            event = "InsertEnter",
            config = function()
                require("nvim-autopairs").setup {}
            end,
        } -- }}}
        use { 'RRethy/nvim-treesitter-endwise',
            --{{{
            config = function()
                require('nvim-treesitter.configs').setup {
                    endwise = {
                        enable = true,
                    },
                }
            end,
        } --}}}
        use { 'kylechui/nvim-surround',
            -- {{{
            tag = "*", -- Use for stability; omit to use `main` branch for the latest features
            config = function()
                require("nvim-surround").setup {
                    -- Configuration here, or leave empty to use defaults
                }
            end,
        }
        --    surr{ ound_words             ysiw)           (surround_words)
        --     }make strings               ys$"            "make strings"
        --    [delete ar*ound me!]        ds]             delete around me!
        --    remove <b>HTML t*ags</b>    dst             remove HTML tags
        --    'change quot*es'            cs'"            "change quotes"
        --    <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
        --    delete(functi*on calls)     dsf             function calls
        --    }}}
        --}}}

        --- fold ---{{{
        use { 'LeafCage/foldCC.vim', -- {{{
            setup = function() -- setupで指定しないと動作しない
                vim.g.foldCCtext_enable_autofdc_adjuster = 1
                vim.g.foldCCtext_maxchars = 78
                vim.g.foldCCtext_head = "'▸▸'"
                vim.g.foldCCtext_tail = 'printf("[%4d lines (lv%d)]", v:foldend-v:foldstart+1, v:foldlevel)'
                vim.opt.foldtext = 'FoldCCtext()'
            end,
        } -- }}}

        -- use {'anuvyklack/pretty-fold.nvim',
        --     config = function()
        --         require('pretty-fold').setup()
        --     end
        -- }
        -- use {'anuvyklack/fold-preview.nvim',
        --     requires = 'anuvyklack/keymap-amend.nvim',
        --     config = function()
        --         require('fold-preview').setup({
        --             auto = 1000,
        --             auto_close = true,
        --             border = 'rounded',
        --         })
        --     end
        -- }
        --}}}
        --- mark bookmark -{{{
        use { 'chentoast/marks.nvim',
            -- {{{
            config = function()
                require("marks").setup {
                    default_mappings = false,
                }
            end,
        } -- }}}
        --}}}
        --- terminal -{{{
        use { "akinsho/toggleterm.nvim",
            -- {{{
            config = function()
                require("toggleterm").setup({
                    open_mapping = [[<F5>]], -- This is the default mapping.
                    start_in_insert = true,
                    direction = 'float',
                    winbar = {
                        enabled = false,
                        name_formatter = function(term) --  term: Terminal
                            return term.name
                        end
                    },
                })
            end
        } --}}}
        --}}}
        --- comment ---{{{
        use { 'scrooloose/nerdcommenter',
            -- {{{
            config = function()
                vim.g.NERDCreateDefaultMappings = 0
                vim.g.NERDSpaceDelims = 1
                vim.g.NERDDefaultAlign = 'left'
            end,
        } -- }}}
        -- use { 'numToStr/Comment.nvim',
        --     --{{{
        --     config = function()
        --         require('Comment').setup {
        --             padding = true, ---Add a space b/w comment and the line
        --             sticky = true, ---Whether the cursor should stay at its position
        --             ignore = nil, ---Lines to be ignored while (un)comment
        --             ---LHS of toggle mappings in NORMAL mode
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
        -- } --}}}
        --}}}
        --- runner -{{{
        use { 'thinca/vim-quickrun',
            --{{{
            requires = { 'Shougo/vimproc.vim', run = 'make' },
            setup = function()
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
        } --}}}
        use { 'is0n/jaq-nvim',
            -- {{{
            config = function()
                require('jaq-nvim').setup {
                    cmds = {
                        -- Uses vim commands
                        internal = {
                            lua = "luafile %",
                            vim = "source %",
                            markdown = "MarkdownPreview",
                        },
                        -- Uses shell commands
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
                        -- Default type
                        default     = "bang",
                        -- Start in insert mode
                        startinsert = false,
                        -- Use `wincmd p` on startup
                        wincmd      = false,
                        -- Auto-save files
                        autosave    = true,
                    },

                    ui = {
                        float = {
                            -- See ':h nvim_open_win'
                            border   = "rounded",
                            -- See ':h winhl'
                            winhl    = "Normal",
                            borderhl = "FloatBorder",
                            -- See ':h winblend'
                            winblend = 0,
                            -- Num from `0-1` for measurements
                            height   = 0.8,
                            width    = 0.8,
                            x        = 0.5,
                            y        = 0.5
                        },
                        terminal = {
                            -- Window position
                            position = "bot",
                            -- Window size
                            size = 10,
                            -- Disable line numbers
                            line_no = false
                        },
                        quickfix = {
                            -- Window position
                            position = "bot",
                            -- Window size
                            size = 10
                        },
                    }
                }
            end,
        } -- }}}
        --}}}
        --- region textobj ---{{{
        use { 'kana/vim-textobj-line' }             -- al il
        use { 'kana/vim-textobj-entire' }           -- al il
        use { 'osyo-manga/vim-textobj-multiblock' } -- isb asb
        use { 'osyo-manga/vim-textobj-from_regexp' }
        use { 'rhysd/vim-textobj-anyblock' }        -- ib  ar
        use { 'sgur/vim-textobj-parameter' }        -- i, a,
        use { 'glts/vim-textobj-comment' }          -- ic ac aCc-v
        -- use { 'osyo- manga/vim-textobj-blockwise' } -- I A
        use { 'terryma/vim-expand-region',
            -- {{{
            config = function()
                vim.g.expand_region_text_objects = {
                        ['iw'] = 0,
                        ['iW'] = 0,
                        ['i"'] = 1,
                        ['i\''] = 1,
                        ['i]'] = 1,
                        -- ['iss'] = 1,
                        -- ['ass'] = 1,
                        ['ib'] = 1,
                        ['iB'] = 1,
                        ['il'] = 1,
                        ['ip'] = 0,
                        ['ie'] = 0,
                }
            end,
        } -- }}}
        use { 'mfussenegger/nvim-treehopper',
            --{{{
            config = function()
                require("tsht").config.hint_keys = { "h", "j", "f", "d", "n", "v", "s", "l", "a" }
            end,
        } --}}}
        --}}}
        --- undo ---{{{
        use { 'simnalamburt/vim-mundo',
            --{{{
            config = {
                -- 'vim.g.mundo_width = 45',
                -- 'vim.g.mundo_preview_height = 15',
                -- 'vim.g.mundo_preview_bottom = 1',
                -- 'vim.g.mundo_right = 1',
                -- 'vim.g.mundo_close_on_revert = 0',
                -- 'vim.g.mundo_auto_preview = 1',
                -- 'vim.g.mundo_auto_preview_delay = 250',
                -- 'vim.g.mundo_verbose_graph = 1',
                -- 'vim.g.mundo_playback_delay = 60',
                -- 'vim.g.mundo_header= 1',
                -- 'vim.g.mundo_return_on_revert = 1',
                -- 'vim.g.mundo_inline_undo = 1',
                -- 'vim.g.mundo_mirror_graph = 1',
                -- 'vim.g.mundo_disable = 0',
                -- 'vim.g.mundo_help  = 0',
                -- 'vim.g.mundo_preview_statusline = true',
                -- 'vim.g.mundo_tree_statusline = true',
            },
        } --}}}
        --}}}
        --- yank ---{{{
        use { "gbprod/yanky.nvim",
            -- {{{
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
        } -- }}}
        --}}}
        --- session ---{{{
        -- use { 'rmagatti/session-lens',
        --     --{{{
        --     requires = {
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
        -- } --}}}}}}
        --- tool --{{{
        use { 'kwkarlwang/bufresize.nvim', -- バッファ閉じたときにレイアウト自動修正
            -- {{{
            config = function()
                require("bufresize").setup()
            end,
        }                                    -- }}},
        -- use { 'vim-scripts/indentLine.vim' } -- インデントライン表示

        use  { "lukas-reineke/indent-blankline.nvim",
            require("ibl").setup {
                indent = { highlight = {"CursorColumn", "Whitespace",}, char = "" },
                whitespace = {
                    highlight = {"CursorColumn", "Whitespace",},
                    remove_blankline_trail = true,
                },
                scope = { enabled = true },
            }
        }
        use { 'junegunn/vim-easy-align' }    -- 整列

        use { 't9md/vim-quickhl' }           -- 選択ワードハイライト

        -- use { 'direnv/direnv.vim' } -- direnv

        use { 'jamesl33/vim-operator-convert-case', -- hoge-case変換
            --{{{
            requires = {
                'kana/vim-operator-user',
                'tpope/vim-repeat',
            }
        } --}}}
        use { 'mizlan/iswap.nvim',
            --{{{
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
        } --}}}
        use { 'm-demare/hlargs.nvim',
            --{{{
            requires = { 'nvim-treesitter/nvim-treesitter' },
            config = function()
                require('hlargs').setup {}
            end,
        }                         --}}}
        use { 'Shougo/vinarise' } --- binary editor

        use { 'norcalli/nvim-colorizer.lua',
            --{{{
            config = function()
                require 'colorizer'.setup()
                vim.g.colorizer_nomap = 0
                vim.g.colorizer_startup = 0
            end,
        } --}}}
        use { 'mg979/vim-visual-multi',
            --{{{
            setup = function() -- setupで指定しないと色々上書きされる
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
        } --}}}
        -- use { 'notjedi/nvim-rooter.lua',
        --     -- {{{
        --     config = function()
        --         require('nvim-rooter').setup {
        --             rooter_patterns = { '.git', '.hg', '.svn' },
        --             trigger_patterns = { '*' },
        --             manual = false,
        --         }
        --     end,
        -- } -- }}}
        --}}}
        --- commandline ---{{{
        use { 'tyru/capture.vim' }
        use { 'VonHeikemen/fine-cmdline.nvim',
            --{{{
            requires = {
                { 'MunifTanjim/nui.nvim' }
            },
            config = function()
                local fineline = require('fine-cmdline')
                local fn = fineline.fn
                fineline.setup({
                    cmdline = {
                        enable_keymaps = false,
                        -- enable_keymaps = true,
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
        } --}}}
        --- map helper---{{{
        use { 'folke/which-key.nvim',
            --{{{
            opt = false,
            config = function()
                require("which-key").setup {}
            end,
        } --}}}
        --}}}

        --- translate ---{{{
        use { 'skanehira/denops-translate.vim',
            opt = true,
            -- requires = 'vim-denops/denops.vim',
        }
        use { 'tyru/open-browser.vim' }
        use {'mfussenegger/nvim-dap'}
        use { 'rcarriga/nvim-dap-ui' }
        use { 'https://github.com/mfussenegger/nvim-dap-python' }
        use { 'vim-jp/vimdoc-ja', opt = true }
        --}}}
        -- vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
        -- use {
        --   "nvim-neo-tree/neo-tree.Evim",
        --     branch = "v2.x",
        --     requires = {
        --       "nvim-lua/plenary.nvim",
        --       "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        --       "MunifTanjim/nui.nvim",
        --     }
        -- }
        use { 'iamcco/markdown-preview.nvim',
            -- {{{
            ft = { 'markdown' },
            run = function()
                vim.fn["mkdp#util#install"]()
            end,
        } -- }}}

        use { 'rbtnn/vim-jumptoline' }
        use { 'khaveesh/vim-fish-syntax', ft = { 'fish' } }

        use { 'kamykn/popup-menu.nvim' }
        use { 'osyo-manga/vim-precious',
            requires = { 'Shougo/context_filetype.vim' }
        }
        use {'vim-scripts/visual-basic.vim'}
    end,
    config = {
        display = {
            open_fn = function(a)
                return require('packer.util').float({ border = 'rounded' }) end
        }
    }
})---





