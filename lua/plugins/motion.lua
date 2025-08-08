-- plugins/motion.lua - 移動・ジャンプ関連
return {
    -- 移動関連
    {
        "rainbowhxch/accelerated-jk.nvim",
        config = function()
            require('accelerated-jk').setup({
                mode = 'time_driven',
                enable_deceleration = false,
                mapping = {
                    --ノーマルモードの設定
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
                    v = {
                        j = 'gj',
                        k = 'gk',
                    },
                },
                acceleration_motions = { 'j', 'k', 'h', 'l', 'b', 'w', 'e', 'B', 'W', 'E' },
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

    {
        "rhysd/clever-f.vim",
        config = function()
            vim.g.clever_f_across_no_line = 1
            vim.g.clever_f_smart_case = 1
            vim.g.clever_f_use_migemo = 1
            vim.g.clever_f_fix_key_direction = 1
        end
    },

    {
        "skanehira/jumpcursor.vim",
    },

    { "rbtnn/vim-jumptoline" },

    -- コメントアウトされたプラグイン
    -- {
    --     "unblevable/quick-scope",
    --     config = function()
    --         vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }
    --     end
    -- },
}

