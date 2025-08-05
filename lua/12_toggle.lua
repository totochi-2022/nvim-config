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
    -- 診断表示トグル（tiny-inline-diagnostic対応）
    {
        name = 'diagnostics',
        type = 'cycle',
        states = { 'cursor_only', 'full_with_underline', 'signs_only' },
        initial_state = 'cursor_only',
        desc = '診断表示モード切替',
        icons = { 'D', 'D', 'D' },
        colors = { 'Visual', 'DiagnosticWarn', 'NonText' },
        messages = {
            '診断表示: カーソル行のみ（tiny-inline-diagnostic）',
            '診断表示: フル表示＋アンダーライン',
            '診断表示: サインのみ'
        },
        callbacks = {
            -- カーソル行のみ（tiny-inline-diagnostic有効）
            function()
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = true,
                    underline = false,
                    update_in_insert = false,
                    severity_sort = true,
                })
                -- tiny-inline-diagnosticを有効化
                local ok, tiny_diag = pcall(require, 'tiny-inline-diagnostic')
                if ok then
                    tiny_diag.enable()
                end
            end,
            -- フル表示＋アンダーライン
            function()
                -- tiny-inline-diagnosticを無効化
                local ok, tiny_diag = pcall(require, 'tiny-inline-diagnostic')
                if ok then
                    tiny_diag.disable()
                end
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
                    signs = true,
                    underline = true,
                    update_in_insert = false,
                    severity_sort = true,
                })
            end,
            -- サインのみ
            function()
                -- tiny-inline-diagnosticを無効化
                local ok, tiny_diag = pcall(require, 'tiny-inline-diagnostic')
                if ok then
                    tiny_diag.disable()
                end
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = true,
                    underline = false,
                    update_in_insert = false,
                    severity_sort = true,
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
    },
    
    -- Noice コマンドライン トグル
    {
        name = 'noice_cmdline',
        type = 'boolean',
        initial_state = true,
        desc = 'Noice コマンドライン トグル',
        icons = { 'C', 'C' },
        colors = { 'NonText', 'Visual' },
        callbacks = {
            function()
                -- コマンドライン無効化
                local ok, noice = pcall(require, 'noice')
                if ok then
                    require('noice.config').options.cmdline.enabled = false
                    vim.notify("Noice コマンドライン無効化", vim.log.levels.INFO)
                end
            end,
            function()
                -- コマンドライン有効化
                local ok, noice = pcall(require, 'noice')
                if ok then
                    require('noice.config').options.cmdline.enabled = true
                    vim.notify("Noice コマンドライン有効化", vim.log.levels.INFO)
                end
            end
        }
    },
    
    -- LSP進捗表示トグル（2段階切り替え）
    {
        name = 'lsp_progress',
        type = 'boolean',
        initial_state = true,
        desc = 'LSP進捗表示トグル',
        icons = { 'L', 'L' },
        colors = { 'NonText', 'Visual' },
        messages = {
            '下部通知のみ（LSP進捗無効）',
            '上部通知＋下部LSP進捗（デフォルト）'
        },
        callbacks = {
            -- LSP進捗無効化（下部通知のみ）
            function()
                local ok, noice = pcall(require, 'noice')
                if ok then
                    require('noice.config').options.lsp.progress.enabled = false
                    -- 通知を下部表示に変更
                    require("notify").setup({
                        top_down = false,  -- 下から上に表示
                        timeout = 3000,
                        render = "wrapped-compact",
                        max_width = function() 
                            return math.min(math.floor(vim.o.columns * 0.4), 50)
                        end,
                        max_height = 10,
                        wrap = true,
                        level_timeout = {
                            [vim.log.levels.ERROR] = 5000,
                            [vim.log.levels.WARN] = 4000,  
                            [vim.log.levels.INFO] = 3000,
                        },
                    })
                    vim.notify("下部通知のみ", vim.log.levels.INFO)
                end
            end,
            -- LSP進捗有効化（上部通知＋下部LSP進捗・デフォルト）
            function()
                local ok, noice = pcall(require, 'noice')
                if ok then
                    require('noice.config').options.lsp.progress.enabled = true
                    require('noice.config').options.lsp.progress.view = "mini"
                    -- 通知を上部表示に変更
                    require("notify").setup({
                        top_down = true,  -- 上から下に表示
                        timeout = 3000,
                        render = "wrapped-compact",
                        max_width = function() 
                            return math.min(math.floor(vim.o.columns * 0.4), 50)
                        end,
                        max_height = 10,
                        wrap = true,
                        level_timeout = {
                            [vim.log.levels.ERROR] = 5000,
                            [vim.log.levels.WARN] = 4000,  
                            [vim.log.levels.INFO] = 3000,
                        },
                    })
                    vim.notify("上部通知＋下部LSP進捗", vim.log.levels.INFO)
                end
            end
        }
    }
})

-- プレフィックスモード設定（診断トグル復活）
toggle.setup_prefix_mode('<LocalLeader>0', {
    d = 'diagnostics',  -- 診断表示トグル復活
    r = 'readonly',
    p = 'paste_mode',
    h = 'auto_hover',
    c = 'colorizer',
    m = 'migemo',
    q = 'quickscope',
    j = 'jump_mode',
    w = 'windows_path',
    n = 'noice_cmdline', -- Noice コマンドライントグル
    l = 'lsp_progress',  -- LSP進捗表示トグル
}, {
    title = '🔀 Toggle Mode',
    persistent = true,
    show_current_state = true,
    show_icons = true,
    footer = 'ESC: exit, 連続切り替え可能'
})

-- lualine用のセレクターをセットアップ
local lualine_selector = toggle.setup_lualine_selector()

-- lualine設定の例をエクスポート
toggle.lualine_component = lualine_selector.get_component()

return toggle