-- plugins/misc.lua - その他・実験的
return {
    -- 括弧マッチング・自動補完
    { "andymass/vim-matchup" },
    { "windwp/nvim-autopairs" },
    { "kylechui/nvim-surround" },
    
    -- Markdownプレビュー（チートシート表示用）
    {
        "ellisonleao/glow.nvim",
        config = function()
            require('glow').setup({
                style = "dark",  -- ダークテーマ
                width = 120,      -- 幅
                height = 100,     -- 高さ
                border = "rounded", -- 枠線スタイル
            })
        end,
        cmd = "Glow",
    },

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
    {
        -- TreeSitter不要・正規表現ベースの便利テキストオブジェクト集
        "chrisgrieser/nvim-various-textobjs",
        event = "VeryLazy",
        opts = { keymaps = { useDefaults = false } }, -- マッピングは21_keymap.luaで個別設定
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

    -- 実行系 (jaq-nvimで代替済み)
    -- { "thinca/vim-quickrun" },
    -- { "Shougo/vimproc.vim", build = "make" },

    (vim.g.use_local_plugins and vim.g.use_local_plugins.jaq) and {
        dir = "/home/motoki/work/repo/nvim_plugin/jaq-nvim",  -- ローカル開発版
        config = function()
            require('jaq-nvim').setup({
                cmds = {
                    internal = {
                        lua = "luafile %",
                        vim = "source %",
                    },
                    external = {
                        markdown = "glow %",
                        python = "python3 %",
                        ruby = "ruby %",
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
                        border = "rounded",
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
    } or {
        "totochi-2022/jaq-nvim",  -- GitHub版（フォーク予定）
        config = function()
            require('jaq-nvim').setup({
                cmds = {
                    internal = {
                        lua = "luafile %",
                        vim = "source %",
                    },
                    external = {
                        markdown = "glow %",
                        python = "python3 %",
                        ruby = "ruby %",
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
                        border = "rounded",
                        winhl = "Normal",
                        borderhl = "FloatBorder",
                        height = 0.8,
                        width = 0.8,
                        x = 0.5,
                        y = 0.5,
                        winblend = 0
                    },
                    terminal = {
                        position = "bot",
                        line_no = false,
                        size = 10
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
                    -- 起動遅延の真因はclipboard即時設定だったため、clipboardをVeryLazy遅延化(14_autocmd.lua)して解決。
                    -- syncはfocus変化時のみクリップボードを読むので、trueでも起動速度に影響しない。
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
    {
        "mg979/vim-visual-multi",
        init = function()
            -- F4キーをプレフィックスとして使用
            vim.g.VM_leader = '<F4>'
            
            -- 主要なキーマップをF4プレフィックスで設定
            vim.g.VM_maps = {
                -- 基本操作
                ['Find Under'] = '<F4>n',         -- F4+n: 現在の単語を選択
                ['Find Subword Under'] = '<F4>n',
                ['Select All'] = '<F4>a',         -- F4+a: 全ての一致を選択
                ['Start Regex Search'] = '<F4>/',  -- F4+/: 正規表現検索
                
                -- カーソル追加
                ['Add Cursor Down'] = '<F4>j',     -- F4+j: 下にカーソル追加
                ['Add Cursor Up'] = '<F4>k',       -- F4+k: 上にカーソル追加
                
                -- 選択系
                ['Select h'] = '<F4>h',            -- F4+h: 左に選択拡張
                ['Select l'] = '<F4>l',            -- F4+l: 右に選択拡張
                
                -- その他
                ['Skip Region'] = '<F4>s',         -- F4+s: 現在の選択をスキップ
                ['Remove Region'] = '<F4>x',       -- F4+x: 現在の選択を削除
                ['Undo'] = '<F4>u',                -- F4+u: アンドゥ
                ['Redo'] = '<F4>r',                -- F4+r: リドゥ
            }
            
            -- nvim-cmpとの競合を回避
            -- マルチカーソルモード中は補完を無効化
            vim.g.VM_set_statusline = 1
            vim.g.VM_silent_exit = 1
        end,
        config = function()
            -- VMモード中はblink.cmpを無効化（plugins/lsp.luaのenabledコールバックがvim.b.disable_blink_cmpを参照）
            vim.api.nvim_create_autocmd('User', {
                pattern = 'visual_multi_start',
                callback = function()
                    vim.b.disable_blink_cmp = true
                end
            })

            vim.api.nvim_create_autocmd('User', {
                pattern = 'visual_multi_exit',
                callback = function()
                    vim.b.disable_blink_cmp = nil
                end
            })
        end,
    },

    -- コマンド出力キャプチャ（:Capture {cmd} で出力をバッファ展開）
    { "tyru/capture.vim", cmd = "Capture" },

    -- 翻訳（denops必須）
    { 
        "vim-denops/denops.vim",
        init = function()
            vim.g.denops_disable_version_check = 1
        end
    },
    { "skanehira/denops-translate.vim", dependencies = { "vim-denops/denops.vim" } },

    -- ブラウザ
    { "tyru/open-browser.vim" },

    -- ヘルプ
    -- doc/tags-jaはhelptags生成物。lazyはdoc/tags(英語)のみ自動クリーンするため
    -- tags-jaはbuild/起動時autocmd(14_autocmd.lua)でHEADに戻しLazy updateの衝突を防ぐ
    { "vim-jp/vimdoc-ja", build = "git checkout -- doc/tags-ja" },

    -- マークダウンプレビュー（ブラウザ表示）
    {
        "iamcco/markdown-preview.nvim",
        build = "cd app && npm install && git checkout -- yarn.lock",
        config = function()
            vim.g.mkdp_filetypes = { "markdown" }
            vim.g.mkdp_theme = 'dark'  -- プレビューをダークテーマで表示（標準ダーク）
        end,
        ft = { "markdown" },
    },

    -- マークダウンのインライン描画（バッファ内で見出し・表・コードブロック等を装飾）
    -- デフォルトは描画OFF（素のmarkdown表示）。toggle `r`（<LocalLeader>0 → r）で
    -- 描画ON/OFFを切り替える（16_toggle.lua）。
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = { "markdown" },
        opts = { enabled = false },
    },

    -- howm的なmarkdownメモ管理（telescope駆動のZettelkasten）
    -- 保管先は data/howm/ を流用。画像貼り付けはimg-clip/SmartPaste(sP)を使う
    -- キーマップ（,, プレフィックス）は lua/21_keymap.lua で管理
    {
        -- 原作(renerocksai)はメンテ停滞 → コミュニティ後継 fork に差し替え（API互換）
        "nvim-telekasten/telekasten.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
            "renerocksai/calendar-vim",  -- ,,k のカレンダー表示用
        },
        cmd = "Telekasten",  -- :Telekasten で遅延ロード
        config = function()
            local howm = vim.g.dir_setting.howm
            require('telekasten').setup({
                home       = howm,
                dailies    = howm .. '/daily',     -- 日次ノート
                weeklies   = howm .. '/weekly',    -- 週次ノート
                templates  = howm .. '/templates', -- テンプレート
                extension  = ".md",
                new_note_filename = "title",       -- タイトルをファイル名に
                -- 画像貼り付けはimg-clip/SmartPaste(sP)に任せるためtelekasten側は使わない
            })
        end,
    },

    -- クリップボードの画像を貼り付け（GROWIライク：画像保存+markdownリンク挿入）
    {
        "HakonHarnes/img-clip.nvim",
        cmd = "PasteImage",  -- キーマップは21_keymap.luaで管理（:PasteImageでcmd遅延ロード）
        opts = {
            default = {
                dir_path = "assets",          -- 画像の保存先（編集中ファイルと同階層のassets/）
                file_name = "%Y%m%d-%H%M%S",  -- ファイル名はタイムスタンプ
                url_encode_path = true,
                prompt_for_file_name = false, -- 毎回ファイル名を聞かず即保存
                relative_to_current_file = true,
            },
            filetypes = {
                markdown = {
                    url_encode_path = true,
                    template = "![$CURSOR]($FILE_PATH)",
                },
            },
        },
    },

    -- 構文ファイル
    { "khaveesh/vim-fish-syntax" },

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
        -- キーマップは lua/21_keymap.lua で定義
        cmd = { "ClaudeCode", "ClaudeCodeSend" },
        dependencies = { "folke/snacks.nvim" },
        config = function()
            require('claudecode').setup()
        end,
    },

    -- コメントアウトされたプラグイン
    -- { "mbbill/undotree" },
    -- { "direnv/direnv.vim" },
    -- { "notjedi/nvim-rooter.lua" },
}