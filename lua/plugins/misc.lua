-- plugins/misc.lua - その他・実験的
return {
    -- 括弧マッチング・自動補完
    { "andymass/vim-matchup" },
    { "windwp/nvim-autopairs" },
    { "kylechui/nvim-surround" },

    -- テキストオブジェクト
    {
        "kana/vim-textobj-line",
        dependencies = { "kana/vim-textobj-user" },
    },
    {
        "kana/vim-textobj-entire",
        dependencies = { "kana/vim-textobj-user" },
    },
    {
        "osyo-manga/vim-textobj-multiblock",
        dependencies = { "kana/vim-textobj-user" },
    },
    {
        "osyo-manga/vim-textobj-from_regexp",
        dependencies = { "kana/vim-textobj-user" },
    },
    {
        "rhysd/vim-textobj-anyblock",
        dependencies = { "kana/vim-textobj-user" },
    },
    {
        "sgur/vim-textobj-parameter",
        dependencies = { "kana/vim-textobj-user" },
    },
    {
        "glts/vim-textobj-comment",
        dependencies = { "kana/vim-textobj-user" },
    },

    -- 領域拡張
    {
        "terryma/vim-expand-region",
        dependencies = { "kana/vim-textobj-user" },
    },

    -- マーク管理
    {
        "chentoast/marks.nvim",
        config = function()
            require('marks').setup {
                default_mappings = false,
                builtin_marks = { ".", "<", ">", "^" },
                cyclic = true,
                force_write_shada = false,
                refresh_interval = 250,
                sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
                excluded_filetypes = {},
                bookmark_0 = {
                    sign = "⚑",
                    virt_text = "hello world",
                    annotate = false,
                },
                mappings = {}
            }
        end
    },

    -- コメント
    {
        "scrooloose/nerdcommenter",
        init = function()
            vim.g.NERDCreateDefaultMappings = 0
            vim.g.NERDSpaceDelims = 1
            vim.g.NERDDefaultAlign = 'left'
            vim.g.NERDCommentEmptyLines = 1
            vim.g.NERDTrimTrailingWhitespace = 1
            vim.g.NERDToggleCheckAllLines = 1
        end
    },

    -- 実行系
    {
        "thinca/vim-quickrun",
        config = function()
            vim.g.quickrun_config = {
                ["_"] = {
                    runner = "vimproc",
                    runner_vimproc_updatetime = 60,
                    outputter = "error",
                    outputter_error_success = "buffer",
                    outputter_error_error = "quickfix",
                    outputter_buffer_split = ":rightbelow 8sp",
                    outputter_buffer_close_on_empty = 1,
                }
            }
        end
    },

    { "Shougo/vimproc.vim", build = "make" },

    {
        "is0n/jaq-nvim",
        config = function()
            require('jaq-nvim').setup({
                cmds = {
                    internal = {
                        lua = "luafile %",
                        vim = "source %"
                    },
                    external = {
                        markdown = "glow %",
                        python = "python3 %",
                        javascript = "node %",
                        sh = "sh %",
                    }
                },
                behavior = {
                    default = "float",
                    startinsert = false,
                    wincmd = false,
                    autosave = false
                },
                ui = {
                    float = {
                        border = "none",
                        winhl = "Normal",
                        borderhl = "FloatBorder",
                        winblend = 0,
                        height = 0.8,
                        width = 0.8,
                        x = 0.5,
                        y = 0.5
                    },
                    terminal = {
                        position = "bot",
                        size = 10,
                        line_no = false
                    },
                    quickfix = {
                        position = "bot",
                        size = 10
                    }
                }
            })
        end
    },

    -- Undo管理

    {
        "jiaoshijie/undotree",
        dependencies = "nvim-lua/plenary.nvim",
        config = true,
    },

    -- ヤンク管理
    {
        "gbprod/yanky.nvim",
        config = function()
            require("yanky").setup({
                ring = {
                    history_length = 100,
                    storage = "shada",
                    sync_with_numbered_registers = true,
                    cancel_event = "update",
                },
                picker = {
                    select = {
                        action = nil,
                    },
                    telescope = {
                        use_default_mappings = true,
                        mappings = nil,
                    },
                },
                system_clipboard = {
                    sync_with_ring = true,
                },
                highlight = {
                    on_put = true,
                    on_yank = true,
                    timer = 500,
                },
                preserve_cursor_position = {
                    enabled = true,
                },
            })
        end
    },

    -- バッファリサイズ
    {
        "kwkarlwang/bufresize.nvim",
        config = function()
            require("bufresize").setup()
        end
    },

    -- 整列
    { "junegunn/vim-easy-align" },

    -- ハイライト
    {
        "t9md/vim-quickhl",
        config = function()
            vim.g.quickhl_manual_colors = {
                "gui=bold ctermfg=16  ctermbg=153 guifg=#ffffff guibg=#0a7383",
                "gui=bold ctermfg=7   ctermbg=1   guibg=#a07040 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=2   guibg=#4070a0 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=3   guibg=#40a070 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=4   guibg=#70a040 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=5   guibg=#0070e0 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=6   guibg=#007020 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=21  guibg=#d4a00d guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=22  guibg=#06287e guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=45  guibg=#5b3674 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=16  guibg=#4b5363 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=50  guibg=#990000 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=56  guibg=#000099 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=17  guibg=#999900 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=17  guibg=#009900 guifg=#ffffff",
                "gui=bold ctermfg=7   ctermbg=17  guibg=#009999 guifg=#ffffff",
            }
        end
    },

    -- 大文字小文字変換
    {
        "jamesl33/vim-operator-convert-case",
        dependencies = { "kana/vim-operator-user" },
    },

    -- 要素交換
    {
        "mizlan/iswap.nvim",
        config = function()
            require('iswap').setup()
        end
    },

    -- 引数ハイライト
    {
        "m-demare/hlargs.nvim",
        config = function()
            require('hlargs').setup()
        end
    },

    -- バイナリエディタ
    { "Shougo/vinarise" },


    -- マルチカーソル
    { "mg979/vim-visual-multi" },

    -- コマンド出力キャプチャ
    { "tyru/capture.vim" },

    -- コマンドライン改良（noice.nvimに置き換えのため無効化）
    {
        "VonHeikemen/fine-cmdline.nvim",
        enabled = false,  -- noice.nvimと競合するため無効化
        dependencies = {
            "MunifTanjim/nui.nvim"
        },
        config = function()
            require('fine-cmdline').setup({
                cmdline = {
                    enable_keymaps = true,
                    smart_history = true,
                    prompt = ':'
                },
                popup = {
                    position = {
                        row = '50%',  -- 画面中央に配置
                        col = '50%',
                    },
                    size = {
                        width = '60%',
                        height = 1,
                    },
                    border = {
                        style = 'rounded',
                    },
                    win_options = {
                        winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
                    },
                },
            })
        end,
    },

    -- 翻訳（denops必須）
    { "vim-denops/denops.vim" },
    { "skanehira/denops-translate.vim", dependencies = { "vim-denops/denops.vim" } },

    -- ブラウザ
    { "tyru/open-browser.vim" },

    -- ヘルプ
    { "vim-jp/vimdoc-ja" },

    -- マークダウンプレビュー
    {
        "iamcco/markdown-preview.nvim",
        build = "cd app && npm install && git checkout -- yarn.lock",
        config = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },

    -- 構文ファイル
    { "khaveesh/vim-fish-syntax" },

    -- ポップアップメニュー
    { "kamykn/popup-menu.nvim" },

    -- コンテキスト連携
    {
        "osyo-manga/vim-precious",
        dependencies = { "Shougo/context_filetype.vim" }
    },

    -- ファイルタイプ判定
    { "Shougo/context_filetype.vim" },

    -- Claude Code統合
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        config = function()
            require('claudecode').setup()
        end,
        keys = {
            { "mz", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
            { "mx", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" }
        }
    },

    -- コメントアウトされたプラグイン
    -- { "mbbill/undotree" },
    -- { "direnv/direnv.vim" },
    -- { "notjedi/nvim-rooter.lua" },
}