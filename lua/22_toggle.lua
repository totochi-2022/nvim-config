-- Toggle System Configuration
-- 新トグルシステムの設定ファイル

--[[
トグル定義での色設定方法:

1. colors配列方式（従来互換）:
   colors = {'ToggleGray', 'ToggleGreen'}
   
2. fg/bg指定方式（新方式）:
   colors = {
       { fg = '#FFFFFF', bg = '#808080' },  -- 状態1: 白文字/灰背景
       { fg = '#000000', bg = '#00FF00' }   -- 状態2: 黒文字/緑背景
   }
   
3. 混在方式:
   colors = {
       'ToggleGray',                        -- 状態1: 定義済みハイライト使用
       { fg = '#FFFFFF', bg = '#FF0000' }   -- 状態2: カスタム色
   }
--]]

local M = {}

-- ========== ライブラリ切り替え設定 ==========
local USE_NEW_PLUGIN = true  -- true: 新プラグイン使用, false: 従来システム使用

-- グローバル変数として設定（他のモジュールから参照可能）
vim.g.toggle_use_new_plugin = USE_NEW_PLUGIN

local toggle_lib
if USE_NEW_PLUGIN then
    toggle_lib = require('rc.toggle-manager')
else
    toggle_lib = require('rc.toggle')
end

-- ハイライト機能をライブラリから取得
if USE_NEW_PLUGIN then
    M.get_or_create_highlight = toggle_lib.get_or_create_highlight
else
    M.get_or_create_highlight = toggle_lib.get_or_create_highlight
end

M.definitions = {
    d = {  -- キー = D (diagnostics)
        name = 'diagnostics',
        states = {'cursor_only', 'full_with_underline', 'signs_only'},
        colors = {
            { fg = 'DiagnosticHint' },           -- cursor_only: DiagnosticHintの色を使用
            { fg = 'DiagnosticWarn' },           -- full_with_underline: DiagnosticWarnの色を使用
            { fg = 'Normal', bg = 'DiagnosticError' }  -- signs_only: Normal文字/DiagnosticError背景
        },
        default_state = 'cursor_only',
        desc = '診断表示モード',
        get_state = function()
            -- 現在の診断設定から状態を判定
            local config = vim.diagnostic.config()
            if not config.virtual_text and not config.signs then
                return 'signs_only'
            elseif config.virtual_text then
                return 'full_with_underline'
            else
                return 'cursor_only'
            end
        end,
        set_state = function(state)
            if state == 'cursor_only' then
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = true,
                    underline = false,
                    update_in_insert = false,
                    severity_sort = true,
                })
                local ok, tiny_diag = pcall(require, 'tiny-inline-diagnostic')
                if ok then
                    tiny_diag.enable()
                end
            elseif state == 'full_with_underline' then
                local ok, tiny_diag = pcall(require, 'tiny-inline-diagnostic')
                if ok then
                    tiny_diag.disable()
                end
                vim.diagnostic.config({
                    virtual_text = {
                        prefix = "●",
                        source = "if_many",
                        spacing = 2,
                    },
                    signs = true,
                    underline = true,
                    update_in_insert = false,
                    severity_sort = true,
                })
            elseif state == 'signs_only' then
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
        end
    },
    
    r = {  -- キー = R (readonly)
        name = 'readonly',
        states = {'off', 'on'},
        colors = {
            { fg = 'NonText' },                  -- off: NonTextの色を使用
            { fg = 'WarningMsg', bg = 'Visual' }  -- on: WarningMsg文字/Visual背景
        },
        default_state = 'off',
        desc = '読み取り専用モード',
        get_state = function() 
            return vim.opt.readonly:get() and 'on' or 'off' 
        end,
        set_state = function(state) 
            vim.opt.readonly = (state == 'on') 
        end
    },
    
    p = {  -- キー = P (paste_mode)
        name = 'paste_mode',
        states = {'off', 'on'},
        colors = {
            { fg = 'NonText' },                  -- off: NonTextの色を使用
            { fg = 'Normal', bg = 'MoreMsg' }    -- on: Normal文字/MoreMsg背景
        },
        default_state = 'off',
        desc = 'ペーストモード',
        get_state = function() 
            return vim.opt.paste:get() and 'on' or 'off' 
        end,
        set_state = function(state) 
            vim.opt.paste = (state == 'on') 
        end
    },
    
    h = {  -- キー = H (auto_hover)
        name = 'auto_hover',
        states = {'off', 'on'},
        colors = {
            { fg = 'NonText' },  -- off: NonTextの色を使用
            { fg = 'MoreMsg', bg = 'WarningMsg' }   -- on: MoreMsgの前景色、WarningMsgの前景色を背景に
        },
        default_state = 'off',
        desc = '自動ホバー表示',
        get_state = function() 
            return vim.g.toggle_auto_hover == 1 and 'on' or 'off' 
        end,
        set_state = function(state)
            if state == 'off' then
                vim.g.toggle_auto_hover = 0
                -- 既存のフローティングウィンドウを閉じる
                for _, winid in pairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_config(winid).relative ~= '' then
                        vim.api.nvim_win_close(winid, true)
                    end
                end
            else
                vim.g.toggle_auto_hover = 1
            end
        end
    },
    
    c = {  -- キー = C (colorizer)
        name = 'colorizer',
        states = {'off', 'on'},
        colors = {
            { fg = 'NonText' },                  -- off: NonTextの色を使用
            { fg = 'Normal', bg = 'DiagnosticInfo' }  -- on: Normal文字/DiagnosticInfo背景
        },
        default_state = 'on',
        desc = 'カラー表示',
        get_state = function()
            -- colorizerが利用可能かチェック
            local ok, colorizer = pcall(require, 'colorizer')
            if not ok then
                return 'off'
            end
            
            local buf = vim.api.nvim_get_current_buf()
            
            -- colorizerの内部状態をチェック（エラーハンドリング付き）
            if colorizer and colorizer.get_buffer_options then
                local buffer_ok, buffer_options = pcall(colorizer.get_buffer_options, buf)
                if buffer_ok and buffer_options then
                    return 'on'
                end
            end
            
            -- フォールバック: バッファ変数をチェック
            return vim.b[buf].colorizer_attached and 'on' or 'off'
        end,
        set_state = function(state)
            if state == 'on' then
                if vim.fn.exists(':ColorizerAttachToBuffer') == 2 then
                    vim.cmd('ColorizerAttachToBuffer')
                elseif vim.fn.exists(':ColorizerToggle') == 2 then
                    vim.cmd('ColorizerToggle')
                end
            else
                if vim.fn.exists(':ColorizerDetachFromBuffer') == 2 then
                    vim.cmd('ColorizerDetachFromBuffer')
                elseif vim.fn.exists(':ColorizerToggle') == 2 then
                    vim.cmd('ColorizerToggle')
                end
            end
        end
    },
    
    m = {  -- キー = M (migemo)
        name = 'migemo',
        states = {'off', 'on'},
        colors = {
            { fg = 'NonText' },                  -- off: NonTextの色を使用
            { fg = 'Normal', bg = 'DiagnosticWarn' }  -- on: Normal文字/DiagnosticWarn背景
        },
        default_state = 'off',
        desc = 'Migemo検索',
        get_state = function()
            return vim.g.incsearch_use_migemo == 1 and 'on' or 'off'
        end,
        set_state = function(state)
            if state == 'on' then
                vim.g.incsearch_use_migemo = 1
                if vim.fn.exists('<Plug>(incsearch-migemo-?)') then
                    vim.keymap.set('', '?', '<Plug>(incsearch-migemo-?)')
                    vim.keymap.set('', '/', '<Plug>(incsearch-migemo-/)')
                end
            else
                vim.g.incsearch_use_migemo = 0
                vim.keymap.set('', '?', '<Plug>(incsearch-backward)')
                vim.keymap.set('', '/', '<Plug>(incsearch-forward)')
            end
        end
    },
    
    t = {  -- キー = T (quickscope) - qから変更
        name = 'quickscope',
        states = {'off', 'on'},
        colors = {
            { fg = 'NonText' },                  -- off: NonTextの色を使用
            { fg = 'Normal', bg = 'MoreMsg' }     -- on: Normal文字/MoreMsg背景
        },
        default_state = 'on',
        desc = 'QuickScope',
        get_state = function()
            return vim.g.qs_enable and 'on' or 'off'
        end,
        set_state = function(state)
            if vim.fn.exists(':QuickScopeToggle') == 2 then
                vim.cmd('QuickScopeToggle')
            end
        end
    },
    
    j = {  -- キー = J (jump_mode)
        name = 'jump_mode',
        states = {'global', 'file_local'},
        colors = {
            { fg = 'Normal', bg = 'DiagnosticInfo' },  -- global: Normal文字/DiagnosticInfo背景
            { fg = 'Normal', bg = 'MoreMsg' }         -- file_local: Normal文字/MoreMsg背景
        },
        default_state = 'file_local',
        desc = 'ジャンプモード',
        get_state = function()
            return vim.g.jump_mode_file_local and 'file_local' or 'global'
        end,
        set_state = function(state)
            if state == 'file_local' then
                vim.g.jump_mode_file_local = true
                vim.keymap.set('n', '<C-o>', ':FileJumpBack<CR>', { noremap = true })
                vim.keymap.set('n', '<C-i>', ':FileJumpForward<CR>', { noremap = true })
            else
                vim.g.jump_mode_file_local = false
                pcall(vim.keymap.del, 'n', '<C-o>')
                pcall(vim.keymap.del, 'n', '<C-i>')
            end
        end
    },
    
    w = {  -- キー = W (windows_path)
        name = 'windows_path',
        states = {'off', 'on'},
        colors = {
            { fg = 'NonText' },                  -- off: NonTextの色を使用
            { fg = 'Normal', bg = 'DiagnosticWarn' }  -- on: Normal文字/DiagnosticWarn背景
        },
        default_state = 'off',
        desc = 'Windowsパス変換',
        get_state = function()
            return vim.g.auto_windows_path_mode and 'on' or 'off'
        end,
        set_state = function(state)
            if state == 'on' then
                vim.g.auto_windows_path_mode = true
                -- autocmdを作成（簡略化版）
                vim.g.auto_path_autocmd_id = vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
                    callback = function()
                        local line = vim.api.nvim_get_current_line()
                        if line == "" or line:find('\n') then return end
                        if IsWindowsPath and IsWindowsPath(line) then
                            local converted_path = ConvertWindowsPath and ConvertWindowsPath(line)
                            if converted_path and FileExists and FileExists(converted_path) then
                                vim.api.nvim_set_current_line("")
                                vim.cmd('edit ' .. vim.fn.fnameescape(converted_path))
                            end
                        end
                    end
                })
            else
                vim.g.auto_windows_path_mode = false
                if vim.g.auto_path_autocmd_id then
                    pcall(vim.api.nvim_del_autocmd, vim.g.auto_path_autocmd_id)
                    vim.g.auto_path_autocmd_id = nil
                end
            end
        end
    },
    
    n = {  -- キー = N (noice_cmdline)
        name = 'noice_cmdline',
        states = {'off', 'on'},
        colors = {
            { fg = 'NonText' },                  -- off: NonTextの色を使用
            { fg = 'Normal', bg = 'DiagnosticInfo' }  -- on: Normal文字/DiagnosticInfo背景
        },
        default_state = 'on',
        desc = 'Noiceコマンドライン',
        get_state = function()
            local ok, noice = pcall(require, 'noice')
            if ok then
                local config_ok, config = pcall(require, 'noice.config')
                if config_ok and config.options and config.options.cmdline then
                    return config.options.cmdline.enabled and 'on' or 'off'
                end
            end
            return 'off'
        end,
        set_state = function(state)
            local ok, noice = pcall(require, 'noice')
            if ok then
                local config_ok, config = pcall(require, 'noice.config')
                if config_ok and config.options and config.options.cmdline then
                    config.options.cmdline.enabled = (state == 'on')
                end
            end
        end
    },
    
    i = {  -- キー = I (lsp_progress)
        name = 'lsp_progress',
        states = {'off', 'on'},
        colors = {
            { fg = 'NonText' },                  -- off: NonTextの色を使用
            { fg = 'Normal', bg = 'DiagnosticInfo' }  -- on: Normal文字/DiagnosticInfo背景
        },
        default_state = 'on',
        desc = 'LSP進捗表示',
        get_state = function()
            local ok, noice = pcall(require, 'noice')
            if ok then
                local config_ok, config = pcall(require, 'noice.config')
                if config_ok and config.options and config.options.lsp and config.options.lsp.progress then
                    return config.options.lsp.progress.enabled and 'on' or 'off'
                end
            end
            return 'off'
        end,
        set_state = function(state)
            local ok, noice = pcall(require, 'noice')
            if ok then
                local config_ok, config = pcall(require, 'noice.config')
                if config_ok and config.options and config.options.lsp and config.options.lsp.progress then
                    if state == 'on' then
                        config.options.lsp.progress.enabled = true
                        config.options.lsp.progress.view = "mini"
                        local notify_ok, notify = pcall(require, "notify")
                        if notify_ok then
                            notify.setup({
                                top_down = true,
                                timeout = 3000,
                                render = "wrapped-compact"
                            })
                        end
                    else
                        config.options.lsp.progress.enabled = false
                        local notify_ok, notify = pcall(require, "notify")
                        if notify_ok then
                            notify.setup({
                                top_down = false,
                                timeout = 3000,
                                render = "wrapped-compact"
                            })
                        end
                    end
                end
            end
        end
    }
}

-- 初期化を遅延実行
vim.defer_fn(function()
    if USE_NEW_PLUGIN then
        -- 新プラグイン使用時
        toggle_lib.setup({
            definitions = M.definitions
        })
    else
        -- 従来システム使用時
        -- トグル定義を登録
        toggle_lib.register_definitions(M.definitions)
        
        -- ハイライトシステムを初期化
        toggle_lib.init_highlights()
        
        -- トグル定義を初期化
        toggle_lib.initialize_toggles()
        
        -- rc/toggle.luaのUI機能を初期化
        toggle_lib.setup()
    end
end, 100)

return M