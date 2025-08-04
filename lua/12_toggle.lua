-- Toggle Library Configuration
-- トグルライブラリの設定ファイル

local toggle = require('rc.toggle')

-- 基本設定
toggle.setup({
    save_state = true,
    restore_state = true,
    persist_file = vim.fn.stdpath('config') .. '/data/setting/toggle/states.json',
    
    -- アイコン設定
    icons = {
        boolean = { '❌', '✅' },
        cycle = { '🚫', '⚠️', '🔍' },
        vim_option = { '✏️', '🔒' },
        -- カスタムアイコン
        diagnostics = { '🚫', '⚠️', '🔍' },
        auto_hover = { '❌', '✅' },
        readonly = { '✏️', '🔒' },
        paste_mode = { '📝', '📋' },
        colorizer = { '⬜', '🎨' },
        migemo = { '🔤', '🇯🇵' },
        quickscope = { '👁️', '🎯' },
        jump_mode = { '🌐', '📄' },
        windows_path = { '🪟', '🐧' },
    }
})

-- 一括トグル定義
toggle.define_toggles({
    -- 診断表示トグル（既存のToggleDiagDispを置き換え）
    {
        name = 'diagnostics',
        type = 'cycle',
        states = { 'off', 'underline', 'full' },
        initial_state = 'full',
        -- keymap = '<LocalLeader>`',  -- 個別キーを削除
        desc = '診断表示モード切替',
        icons = { 'D', 'D', 'D' },
        colors = { 'NonText', 'NonText', 'Visual' },
        messages = {
            '診断表示: OFF',
            '診断表示: アンダーライン＋サイン',
            '診断表示: フル表示（重複対応）'
        },
        callbacks = {
            -- OFF
            function()
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = false,
                    underline = false,
                    update_in_insert = false,
                })
            end,
            -- アンダーラインのみ
            function()
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = true,
                    underline = true,
                    update_in_insert = false,
                })
            end,
            -- フル表示
            function()
                vim.diagnostic.config({
                    virtual_text = {
                        prefix = "●",
                        source = "if_many",
                        spacing = 2,
                        format = function(diagnostic)
                            local message = diagnostic.message
                            if #message > 50 then
                                message = message:sub(1, 47) .. "..."
                            end
                            local source = diagnostic.source and ("[" .. diagnostic.source .. "] ") or ""
                            return source .. message
                        end,
                    },
                    signs = { priority = 20 },
                    underline = true,
                    update_in_insert = false,
                    severity_sort = true,
                    float = {
                        border = "rounded",
                        source = "always",
                        header = "",
                        prefix = "",
                        format = function(diagnostic)
                            return diagnostic.message
                        end,
                    },
                })
            end
        }
    },
    
    -- 自動ホバートグル（既存のToggleAutoHoverを置き換え）
    {
        name = 'auto_hover',
        type = 'boolean',
        initial_state = false,
        -- keymap = '<LocalLeader>9',  -- 個別キーを削除
        desc = '自動ホバートグル',
        icons = { 'H', 'H' },
        colors = { 'NonText', 'Visual' },
        messages = { 'Auto hover: OFF', 'Auto hover: ON' },
        callbacks = {
            function()
                vim.g.toggle_auto_hover = 0
                for _, winid in pairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_config(winid).relative ~= '' then
                        vim.api.nvim_win_close(winid, true)
                    end
                end
            end,
            function()
                vim.g.toggle_auto_hover = 1
            end
        }
    },
    
    -- Windowsパス変換トグル（既存のToggleAutoWindowsPathModeを置き換え）
    {
        name = 'windows_path',
        type = 'boolean',
        initial_state = false,
        -- keymap = '<LocalLeader>3',  -- 個別キーを削除
        desc = '自動Windowsパス変換モードをトグル',
        icons = { 'W', 'W' },
        colors = { 'NonText', 'Visual' },
        messages = { 'Auto Windows Path Mode: OFF', 'Auto Windows Path Mode: ON' },
        callbacks = {
            function()
                vim.g.auto_windows_path_mode = false
                -- autocmdを削除
                if vim.g.auto_path_autocmd_id then
                    pcall(vim.api.nvim_del_autocmd, vim.g.auto_path_autocmd_id)
                    vim.g.auto_path_autocmd_id = nil
                end
            end,
            function()
                vim.g.auto_windows_path_mode = true
                -- autocmdを作成
                vim.g.auto_path_autocmd_id = vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
                    callback = function()
                        local line = vim.api.nvim_get_current_line()
                        
                        -- 空行や改行を含む行は無視
                        if line == "" or line:find('\n') then
                            return
                        end
                        
                        -- Windowsパスかどうかチェック（関数は03_function.luaで定義済み）
                        if IsWindowsPath and IsWindowsPath(line) then
                            local converted_path = ConvertWindowsPath and ConvertWindowsPath(line)
                            if converted_path and FileExists and FileExists(converted_path) then
                                -- 現在行をクリアしてファイルを開く
                                vim.api.nvim_set_current_line("")
                                vim.cmd('edit ' .. vim.fn.fnameescape(converted_path))
                            end
                        end
                    end
                })
            end
        }
    },
    
    -- Vimオプション系トグル
    {
        name = 'readonly',
        type = 'vim_option',
        option = 'readonly',
        -- keymap = '<LocalLeader>0',  -- 個別キーを削除
        desc = '読み取り専用モードトグル',
        icons = { 'R', 'R' },
        colors = { 'NonText', 'Visual' }
    },
    
    {
        name = 'paste_mode',
        type = 'vim_option',
        option = 'paste',
        -- keymap = '<LocalLeader>6',  -- 個別キーを削除
        desc = 'ペーストモードトグル',
        icons = { 'P', 'P' },
        colors = { 'NonText', 'Visual' }
    },
    
    -- プラグイン系トグル（コマンド実行タイプ）
    {
        name = 'colorizer',
        type = 'boolean',
        initial_state = true,
        -- keymap = '<LocalLeader>7',  -- 個別キーを削除
        desc = 'カラー表示トグル',
        icons = { 'C', 'C' },
        colors = { 'NonText', 'Visual' },
        skip_initial_callback = true,  -- 初期化時はコールバック実行をスキップ
        callbacks = {
            function() 
                if vim.fn.exists(':ColorizerDetachFromBuffer') == 2 then
                    vim.cmd('ColorizerDetachFromBuffer')
                elseif vim.fn.exists(':ColorizerToggle') == 2 then
                    vim.cmd('ColorizerToggle')
                end
            end,
            function() 
                if vim.fn.exists(':ColorizerAttachToBuffer') == 2 then
                    vim.cmd('ColorizerAttachToBuffer')
                elseif vim.fn.exists(':ColorizerToggle') == 2 then
                    vim.cmd('ColorizerToggle')
                end
            end
        }
    },
    
    {
        name = 'migemo',
        type = 'boolean',
        initial_state = false,
        -- keymap = '<LocalLeader>8',  -- 個別キーを削除
        desc = 'Migemoトグル',
        icons = { 'M', 'M' },
        colors = { 'NonText', 'Visual' },
        skip_initial_callback = true,
        callbacks = {
            function()
                vim.g.incsearch_use_migemo = 0
                if vim.fn.exists('<Plug>(incsearch-backward)') then
                    vim.keymap.set('', '?', '<Plug>(incsearch-backward)')
                    vim.keymap.set('', '/', '<Plug>(incsearch-forward)')
                end
            end,
            function()
                vim.g.incsearch_use_migemo = 1
                if vim.fn.exists('<Plug>(incsearch-migemo-?)') then
                    vim.keymap.set('', '?', '<Plug>(incsearch-migemo-?)')
                    vim.keymap.set('', '/', '<Plug>(incsearch-migemo-/)')
                end
            end
        }
    },
    
    {
        name = 'quickscope',
        type = 'boolean',
        initial_state = true,
        -- keymap = '<LocalLeader>5',  -- 個別キーを削除
        desc = 'QuickScopeトグル',
        icons = { 'Q', 'Q' },
        colors = { 'NonText', 'Visual' },
        skip_initial_callback = true,
        callbacks = {
            function() 
                if vim.fn.exists(':QuickScopeToggle') == 2 then
                    vim.cmd('QuickScopeToggle')
                end
            end,
            function() 
                if vim.fn.exists(':QuickScopeToggle') == 2 then
                    vim.cmd('QuickScopeToggle')
                end
            end
        }
    },
    
    {
        name = 'jump_mode',
        type = 'boolean',
        initial_state = true,
        -- keymap = '<LocalLeader>2',  -- 個別キーを削除
        desc = 'ジャンプモード切替（ファイル内⇔グローバル）',
        icons = { 'J', 'J' },
        colors = { 'NonText', 'Visual' },
        callbacks = {
            function()
                vim.g.jump_mode_file_local = false
                if vim.fn.mapcheck('<C-o>', 'n') ~= '' then
                    vim.keymap.del('n', '<C-o>')
                end
                if vim.fn.mapcheck('<C-i>', 'n') ~= '' then
                    vim.keymap.del('n', '<C-i>')
                end
            end,
            function()
                vim.g.jump_mode_file_local = true
                vim.keymap.set('n', '<C-o>', ':FileJumpBack<CR>', { noremap = true })
                vim.keymap.set('n', '<C-i>', ':FileJumpForward<CR>', { noremap = true })
            end
        }
    }
})

-- プレフィックスモード設定
toggle.setup_prefix_mode('<LocalLeader>0', {
    r = 'readonly',
    p = 'paste_mode',
    h = 'auto_hover',
    d = 'diagnostics',
    c = 'colorizer',
    m = 'migemo',
    q = 'quickscope',
    j = 'jump_mode',
    w = 'windows_path',
}, {
    title = '🔀 Toggle Mode',
    persistent = true,
    show_current_state = true,
    show_icons = true,
    footer = 'ESC: exit, 連続切り替え可能'
})

-- 追加のプレフィックスモード（カテゴリ別）
-- <LocalLeader>tは翻訳機能で使用するためコメントアウト
-- toggle.setup_prefix_mode('<LocalLeader>t', {
--     d = 'diagnostics',
--     h = 'auto_hover',
--     r = 'readonly',
--     p = 'paste_mode',
--     c = 'colorizer',
--     m = 'migemo',
--     q = 'quickscope',
--     j = 'jump_mode',
--     w = 'windows_path',
-- }, {
--     title = '🎛️ All Toggles',
--     persistent = true
-- })

-- lualine用のセレクターをセットアップ
local lualine_selector = toggle.setup_lualine_selector()

-- lualine設定の例をエクスポート
toggle.lualine_component = lualine_selector.get_component()

return toggle