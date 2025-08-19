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

-- Toggle System Configuration
-- 新トグルシステムの設定ファイル
-- このファイルはいつ呼ばれても動作する自己完結型

-- ========== トグル定義設定 ==========

local definitions = {
    d = { -- キー = D (diagnostics)
        name = 'diagnostics',
        states = { 'cursor_only', 'full_with_underline', 'signs_only' },
        colors = {
            { fg = 'Normal', bg = 'Normal' },          -- cursor_only: Normal色
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- full_with_underline: 黒文字/DiagnosticWarn背景
            { fg = '#000000', bg = 'DiagnosticError' } -- signs_only: 黒文字/DiagnosticError背景
        },
        default_state = 'cursor_only',
        desc = '診断表示モード',
        display_char = '⚠ ', -- lualineで表示する文字（スペース付き）
        get_state = function()
            -- 現在の診断設定から状態を判定
            local config = vim.diagnostic.config()
            -- tiny-inline-diagnosticが有効かチェック
            local ok, tiny_diag = pcall(require, 'tiny-inline-diagnostic')
            local tiny_enabled = ok and tiny_diag.is_enabled and tiny_diag.is_enabled()

            if config.virtual_text then
                return 'full_with_underline'
            elseif tiny_enabled or (not config.virtual_text and config.signs and not config.underline) then
                -- tiny-inline-diagnosticが有効、またはvirtual_textなし、signsあり、underlineなし
                return 'cursor_only'
            else
                return 'signs_only'
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

    r = { -- キー = R (readonly) - 表示のみの例
        name = 'readonly',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal',  bg = 'Normal' },         -- off: Normal色
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- on: 黒文字/DiagnosticWarn背景
        },
        default_state = 'off',
        desc = '読み取り専用モード',
        readonly = true, -- このフラグで表示のみになる
        get_state = function()
            return vim.opt.readonly:get() and 'on' or 'off'
        end,
        -- set_stateは定義しない（表示のみなので）
    },

    p = { -- キー = P (paste_mode)
        name = 'paste_mode',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal',  bg = 'Normal' },         -- off: Normal色
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- on: 黒文字/DiagnosticWarn背景
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

    h = { -- キー = H (auto_hover)
        name = 'auto_hover',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal',  bg = 'Normal' },         -- off: Normal色
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- on: 黒文字/DiagnosticWarn背景
        },
        default_state = 'off',
        desc = '自動ホバー表示',
        display_char = '🎈', -- lualineで表示する文字
        auto_hide = true,  -- 最初の状態(off)の時はlualineから自動非表示
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

    c = { -- キー = C (color highlighting)
        name = 'colors',
        states = { 'off', 'hex', 'all' },
        colors = {
            { fg = 'Normal', bg = 'Normal' },          -- hex: HEXカラーのみ
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- hex: HEXカラーのみ
            { fg = '#000000', bg = 'DiagnosticError' } -- all: すべてのカラー表示
        },
        default_state = 'all',
        desc = 'カラー表示',
        display_char = '🎨', -- lualineで表示する文字
        get_state = function()
            -- グローバル変数でカラー表示の状態を管理
            if vim.g.color_highlighting_mode == nil then
                vim.g.color_highlighting_mode = 'all' -- デフォルトはall
            end
            return vim.g.color_highlighting_mode
        end,
        set_state = function(state)
            vim.g.color_highlighting_mode = state

            -- nvim-highlight-colorsの設定
            local highlight_colors_ok, highlight_colors = pcall(require, 'nvim-highlight-colors')
            if highlight_colors_ok then
                if state == 'off' then
                    highlight_colors.turnOff()
                else
                    -- 状態に応じて設定を変更
                    if state == 'hex' then
                        -- HEXカラーのみ有効
                        highlight_colors.setup({
                            render = 'virtual',
                            enable_hex = true,
                            enable_short_hex = true,
                            enable_rgb = false,
                            enable_hsl = false,
                            enable_named_colors = false,
                            enable_tailwind = false,
                            virtual_symbol = '■',
                            virtual_symbol_prefix = ' ',
                            virtual_symbol_suffix = '',
                            virtual_symbol_position = 'inline',
                        })
                    else -- all
                        -- すべてのカラー形式を有効
                        highlight_colors.setup({
                            render = 'virtual',
                            enable_hex = true,
                            enable_short_hex = true,
                            enable_rgb = true,
                            enable_hsl = true,
                            enable_named_colors = true,
                            enable_tailwind = true,
                            virtual_symbol = '■',
                            virtual_symbol_prefix = ' ',
                            virtual_symbol_suffix = '',
                            virtual_symbol_position = 'inline',
                        })
                    end
                    highlight_colors.turnOn()
                end
            end

            -- mini.hipatternsのトグル（パターンを完全に再設定）
            if vim.g.update_hipatterns then
                vim.g.update_hipatterns()
            end
        end
    },

    m = { -- キー = M (migemo)
        name = 'migemo',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal',  bg = 'Normal' },         -- off: Normal色
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- on: 黒文字/DiagnosticWarn背景
        },
        default_state = 'off',
        desc = 'Migemo検索',
        display_char = 'み', -- lualineで表示する文字
        get_state = function()
            return vim.g.migemo_enabled and 'on' or 'off'
        end,
        set_state = function(state)
            -- incsearch-migemo.nvimプラグインを使用
            local ok, migemo = pcall(require, 'incsearch-migemo')
            if not ok then
                vim.notify('incsearch-migemo.nvim not found', vim.log.levels.ERROR)
                return
            end

            if state == 'on' and migemo.has_migemo() then
                -- 標準の検索をmigemo検索に置き換え
                vim.keymap.set('n', '/', migemo.forward, { desc = 'Migemo forward search' })
                vim.keymap.set('n', '?', migemo.backward, { desc = 'Migemo backward search' })
                vim.keymap.set('n', 'g/', migemo.stay, { desc = 'Migemo stay search' })
                -- EasyMotionのmigemoも有効化
                vim.g.EasyMotion_use_migemo = 1
                -- 別の方法でEasyMotion再初期化を試行
                pcall(function()
                    -- lazy.nvim経由で再読み込み
                    local lazy = require('lazy')
                    lazy.reload({ plugins = { 'vim-easymotion' } })
                end)
                vim.g.migemo_enabled = true
            else
                -- 標準の検索に戻す
                vim.keymap.del('n', '/')
                vim.keymap.del('n', '?')
                vim.keymap.del('n', 'g/')
                -- EasyMotionのmigemoも無効化
                vim.g.EasyMotion_use_migemo = 0
                -- lazy.nvim経由で再読み込み
                pcall(function()
                    local lazy = require('lazy')
                    lazy.reload({ plugins = { 'vim-easymotion' } })
                end)
                vim.g.migemo_enabled = false
            end
        end
    },

    f = { -- キー = F (quickscope)
        name = 'quickscope',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal',  bg = 'Normal' },         -- off: Normal色
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- on: 黒文字/DiagnosticWarn背景
        },
        default_state = 'on',
        desc = 'QuickScope',
        display_char = '🔍', -- lualineで表示する文字
        get_state = function()
            return (vim.g.qs_enable == 1) and 'on' or 'off'
        end,
        set_state = function(state)
            if state == 'on' then
                vim.g.qs_enable = 1
            else
                vim.g.qs_enable = 0
            end
        end
    },

    j = { -- キー = J (jump_mode)
        name = 'jump_mode',
        states = { 'global', 'file_local' },
        colors = {
            { fg = 'Normal',  bg = 'Normal' },         -- off: Normal色
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- file_local: 黒文字/DiagnosticWarn背景
        },
        default_state = 'file_local',
        desc = 'ジャンプモード',
        display_char = '⚡', -- lualineで表示する文字
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

    w = { -- キー = W (windows_path)
        name = 'windows_path',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal',  bg = 'Normal' },         -- off: Normal色
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- on: 黒文字/DiagnosticWarn背景
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

    n = { -- キー = N (noice_cmdline)
        name = 'noice_cmdline',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal',  bg = 'Normal' },         -- off: Normal色
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- on: 黒文字/DiagnosticWarn背景
        },
        default_state = 'on',
        desc = 'Noiceコマンドライン',
        display_char = '💬', -- lualineで表示する文字
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

    i = { -- キー = I (lsp_progress)
        name = 'lsp_progress',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal',  bg = 'Normal' },         -- off: Normal色
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- on: 黒文字/DiagnosticWarn背景
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

-- ========== セットアップ実行 ==========

-- toggle-managerプラグインのセットアップ
-- プラグインが利用可能な場合のみ実行
local function setup_toggle_manager()
    local ok, toggle_manager = pcall(require, 'toggle-manager')
    if not ok then
        -- プラグインがまだ読み込まれていない場合は何もしない
        return false
    end

    -- セットアップ実行
    toggle_manager.setup({
        definitions = definitions
    })

    -- キーマップは21_keymap.luaで設定

    return true
end

-- 即座に試行
if not setup_toggle_manager() then
    -- 失敗した場合は、VimEnterで再試行
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            setup_toggle_manager()
        end,
        once = true,
    })
end
