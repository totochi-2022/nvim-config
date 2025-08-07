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

-- プリセットのハイライトグループを作成
local function create_preset_highlights()
    local presets = {
        -- 既存の色から作成
        ToggleError = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticError' })
            return { fg = '#000000', bg = hl.fg or '#FF0000', bold = true }
        end,
        ToggleWarn = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticWarn' })
            return { fg = '#000000', bg = hl.fg or '#FFAA00', bold = true }
        end,
        ToggleInfo = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticInfo' })
            return { fg = '#000000', bg = hl.fg or '#0088FF', bold = true }
        end,
        ToggleHint = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'DiagnosticHint' })
            return { fg = '#000000', bg = hl.fg or '#888888', bold = true }
        end,
        ToggleGreen = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'MoreMsg' })
            return { fg = '#000000', bg = hl.fg or '#00AA00', bold = true }
        end,
        ToggleGray = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'NonText' })
            return { fg = '#000000', bg = hl.fg or '#808080', bold = true }
        end,
        ToggleVisual = function()
            local hl = vim.api.nvim_get_hl(0, { name = 'Visual' })
            return { fg = '#000000', bg = hl.bg or '#4444AA', bold = true }
        end,
    }
    
    for name, get_colors in pairs(presets) do
        vim.api.nvim_set_hl(0, name, get_colors())
    end
end

-- 動的にハイライトグループを作成または取得
local function get_or_create_highlight(color_def, toggle_name, state_index)
    if type(color_def) == 'string' then
        -- 既存のハイライトグループ名を使用
        return color_def
    elseif type(color_def) == 'table' then
        -- fg/bgが指定されている場合、動的にハイライトグループを作成
        local hl_name = string.format('Toggle_%s_%d', toggle_name, state_index)
        local hl_opts = { bold = color_def.bold ~= false }  -- デフォルトはtrue
        
        -- fgの処理
        if color_def.fg then
            if type(color_def.fg) == 'string' then
                if color_def.fg:match('^#') then
                    hl_opts.fg = color_def.fg  -- 直値の場合
                else
                    -- ハイライトグループから色を取得
                    local src_hl = vim.api.nvim_get_hl(0, { name = color_def.fg })
                    hl_opts.fg = src_hl.fg and string.format('#%06x', src_hl.fg) or '#000000'
                end
            end
        else
            hl_opts.fg = '#000000'  -- デフォルト
        end
        
        -- bgの処理
        if color_def.bg then
            if type(color_def.bg) == 'string' then
                if color_def.bg:match('^#') then
                    hl_opts.bg = color_def.bg  -- 直値の場合
                else
                    -- ハイライトグループから色を取得（前景色を背景色として使用）
                    local src_hl = vim.api.nvim_get_hl(0, { name = color_def.bg })
                    hl_opts.bg = src_hl.fg and string.format('#%06x', src_hl.fg) or 
                               (src_hl.bg and string.format('#%06x', src_hl.bg) or '#808080')
                end
            end
        else
            hl_opts.bg = '#808080'  -- デフォルト
        end
        
        vim.api.nvim_set_hl(0, hl_name, hl_opts)
        return hl_name
    end
    return 'Normal'
end

-- 初期化時にプリセットハイライトを作成
vim.defer_fn(create_preset_highlights, 100)

-- カラースキーム変更時にもハイライトグループを再作成
vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
        vim.defer_fn(create_preset_highlights, 50)
    end
})

-- エクスポート用：動的ハイライト作成関数
M.get_or_create_highlight = get_or_create_highlight

M.definitions = {
    d = {  -- キー = D (diagnostics)
        name = 'diagnostics',
        states = {'cursor_only', 'full_with_underline', 'signs_only'},
        colors = {
            { fg = '#00FFFF', bg = '#4B0082' },  -- cursor_only: シアン文字/インディゴ背景
            { fg = '#FFFF00', bg = '#FF1493' },  -- full_with_underline: 黄文字/ディープピンク背景
            { fg = '#00FF00', bg = '#FF0000' }   -- signs_only: 緑文字/赤背景
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
            { fg = '#808080', bg = '#2F2F2F' },  -- off: グレー文字/ダークグレー背景
            { fg = '#FFD700', bg = '#8B008B' }   -- on: ゴールド文字/ダークマゼンタ背景
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
            { fg = '#808080', bg = '#2F2F2F' },  -- off: グレー文字/ダークグレー背景
            { fg = '#FFD700', bg = '#8B008B' }   -- on: ゴールド文字/ダークマゼンタ背景
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
            { fg = '#778899', bg = '#2F4F4F' },  -- off: ライトスレートグレー文字/ダークスレートグレー背景
            { fg = '#FF00FF', bg = '#00CED1' }   -- on: マゼンタ文字/ダークターコイズ背景
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
            { fg = '#B0B0B0', bg = '#404040' },  -- off: ライトグレー文字/ダークグレー背景
            { fg = '#FFA500', bg = '#4169E1' }   -- on: オレンジ文字/ロイヤルブルー背景
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
            { fg = '#808080', bg = '#2F2F2F' },  -- off: グレー文字/ダークグレー背景
            { fg = '#FFD700', bg = '#8B008B' }   -- on: ゴールド文字/ダークマゼンタ背景
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
            { fg = '#1E90FF', bg = '#FF6347' },  -- global: ドッジャーブルー文字/トマト背景
            { fg = '#32CD32', bg = '#9370DB' }   -- file_local: ライムグリーン文字/ミディアムパープル背景
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
            { fg = '#B0B0B0', bg = '#404040' },  -- off: ライトグレー文字/ダークグレー背景
            { fg = '#FFA500', bg = '#4169E1' }   -- on: オレンジ文字/ロイヤルブルー背景
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
            { fg = '#778899', bg = '#2F4F4F' },  -- off: ライトスレートグレー文字/ダークスレートグレー背景
            { fg = '#FF00FF', bg = '#00CED1' }   -- on: マゼンタ文字/ダークターコイズ背景
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
            { fg = '#778899', bg = '#2F4F4F' },  -- off: ライトスレートグレー文字/ダークスレートグレー背景
            { fg = '#FF00FF', bg = '#00CED1' }   -- on: マゼンタ文字/ダークターコイズ背景
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

-- 初期化処理
local function initialize_toggles()
    -- 保存されたデフォルト状態を読み込み
    local defaults_file = vim.fn.stdpath('config') .. '/data/setting/toggle/defaults.json'
    local file = io.open(defaults_file, 'r')
    if file then
        local content = file:read('*a')
        file:close()
        local ok, saved_defaults = pcall(vim.fn.json_decode, content)
        if ok and type(saved_defaults) == 'table' then
            -- 保存されたデフォルト状態を適用
            for key, state in pairs(saved_defaults) do
                if M.definitions[key] then
                    local set_ok, err = pcall(M.definitions[key].set_state, state)
                    if not set_ok then
                        print("Warning: Failed to set toggle '" .. key .. "': " .. tostring(err))
                    end
                end
            end
        end
    else
        -- 初回起動時は各トグルのdefault_stateを適用
        for key, def in pairs(M.definitions) do
            local set_ok, err = pcall(def.set_state, def.default_state)
            if not set_ok then
                print("Warning: Failed to initialize toggle '" .. key .. "': " .. tostring(err))
            end
        end
    end
end

-- 初期化を遅延実行
vim.defer_fn(function()
    initialize_toggles()
    -- rc/toggle.luaも初期化
    local ok, rc_toggle = pcall(require, 'rc.toggle')
    if ok and rc_toggle.setup then
        rc_toggle.setup()
    end
end, 100)

return M