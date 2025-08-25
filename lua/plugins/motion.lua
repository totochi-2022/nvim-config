-- plugins/motion.lua - 移動・ジャンプ関連
return {
    -- 移動関連
    -- フォーク版のaccelerated-jk（visualモード対応）
    {
        vim.g.use_local_plugins and vim.g.use_local_plugins.accelerated_jk
            and { dir = "/home/motoki/work/repo/nvim_plugin/accelerated-jk.nvim" }  -- ローカル開発版
            or "totochi-2022/accelerated-jk.nvim",  -- GitHub版
        config = function()
            require('accelerated-jk').setup({
                mode = 'time_driven',
                enable_deceleration = false,
                acceleration_motions = { 'j', 'k', 'w', 'b', 'e', 'W', 'B', 'E', 'h', 'l' },
                acceleration_motions_visual = { 'j', 'k', 'w', 'b', 'e', 'W', 'B', 'E', 'h', 'l' },  -- visualも同じ設定
                acceleration_limit = 150,
                acceleration_table = { 7, 12, 17, 21, 24, 26, 28, 30 }
            })
        end,
    },

    {
        'easymotion/vim-easymotion',
        config = function()
            vim.g.EasyMotion_do_mapping = 0
            vim.g.EasyMotion_smartcase = 1
            vim.g.EasyMotion_use_migemo = 1
        end
    },

    {
        "osyo-manga/vim-milfeulle",
        config = function()
            vim.g.milfeulle_default_kind = "buffer"
        end
    },

    { "haya14busa/vim-edgemotion" },

    {
        "haya14busa/vim-asterisk",
        config = function()
            vim.g['asterisk#keeppos'] = 1
        end
    },

    -- 古いincsearchプラグインを削除
    -- → totochi-2022/incsearch-migemo.nvim に移行済み

    {
        "kevinhwang91/nvim-hlslens",
        config = function()
            require('hlslens').setup()
        end
    },

    -- 元のclever-f.vim（競合あり）
    -- {
    --     "rhysd/clever-f.vim",
    --     -- dir = "/home/motoki/work/repo/nvim_plugin/clever-f.vim",  -- ローカル版（Vim script）
    --     config = function()
    --         vim.g.clever_f_across_no_line = 1
    --         vim.g.clever_f_smart_case = 1
    --         vim.g.clever_f_use_migemo = 1
    --         vim.g.clever_f_fix_key_direction = 1
    --         vim.g.clever_f_timeout_ms = 0  -- タイムアウト無効化でNoiceとの競合回避
    --     end
    -- },
    
    -- 新しいNeovim版clever-f
    -- GitHub版
    -- {
    --     "totochi-2022/clever-f.nvim",
    --     enabled = true,
    --     config = function()
    --         vim.g.clever_f_setup_called = true  -- setup呼び出しフラグ
    --         require('clever-f').setup({
    --             across_no_line = false,  -- false = 行またぎ有効
    --             smart_case = true,
    --             fix_key_direction = true,
    --             chars_lowercase = nil,
    --             use_migemo = false,
    --             use_vimtex = false,
    --         })
    --     end,
    -- },
    -- clever-f.nvim（Neovim版）
    {
        vim.g.use_local_plugins and vim.g.use_local_plugins.clever_f
            and { dir = "/home/motoki/work/repo/nvim_plugin/clever-f.nvim" }  -- ローカル開発版
            or "totochi-2022/clever-f.nvim",  -- GitHub版
        enabled = true,
        config = function()
            vim.g.clever_f_setup_called = true  -- setup呼び出しフラグ
            require('clever-f').setup({
                across_no_line = false,  -- false = 行またぎ有効
                smart_case = true,
                use_migemo = true,
                fix_key_direction = true,
                timeout_ms = 0,
            })
        end
    },

    {
        "skanehira/jumpcursor.vim",
    },

    { "rbtnn/vim-jumptoline" },

    {
        "unblevable/quick-scope",
        enabled = false,  -- トグルのバグでクリア問題の原因になるため無効化
        config = function()
            vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }
            vim.g.qs_enable = 1  -- デフォルトで有効
        end
    },
}

