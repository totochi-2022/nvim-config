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
        states = { 'signs_only', 'cursor_only', 'full_with_underline' },
        colors = {
            { fg = 'Normal', bg = 'Normal' },          -- signs_only: Normal色
            { fg = '#000000', bg = 'DiagnosticWarn' }, -- cursor_only: 黒文字/DiagnosticWarn背景
            { fg = '#000000', bg = 'DiagnosticError' } -- full_with_underline: 黒文字/DiagnosticError背景
        },
        default_state = 'signs_only',
        desc = '診断表示モード',
        display_char = '⚠ ', -- lualineで表示する文字（スペース付き）
        auto_hide = true, -- 最初の状態(off)の時はlualineから自動非表示
        get_state = function()
            -- グローバル変数で状態を管理
            return vim.g.toggle_diagnostic_state or 'signs_only'
        end,
        set_state = function(state)
            vim.g.toggle_diagnostic_state = state -- 状態を記憶
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

    -- r = { -- キー = R (readonly) - 表示のみの例
    --     name = 'readonly',
    --     states = { 'off', 'on' },
    --     colors = {
    --         { fg = 'Normal',  bg = 'Normal' },         -- off: Normal色
    --         { fg = '#000000', bg = 'DiagnosticWarn' }, -- on: 黒文字/DiagnosticWarn背景
    --     },
    --     default_state = 'off',
    --     desc = '読み取り専用モード',
    --     readonly = true, -- このフラグで表示のみになる
    --     get_state = function()
    --         return vim.opt.readonly:get() and 'on' or 'off'
    --     end,
    --     -- set_stateは定義しない（表示のみなので）
    -- },

    p = { -- キー = P (paste_mode)
        name = 'paste_mode',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
        },
        default_state = 'off',
        desc = 'ペーストモード',
        display_char = '󰆒 ', -- lualineで表示する文字（スペース付き）
        auto_hide = true, -- 最初の状態(off)の時はlualineから自動非表示
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
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
        },
        default_state = 'off',
        desc = '自動ホバー表示',
        display_char = '🎈', -- lualineで表示する文字
        auto_hide = true, -- 最初の状態(off)の時はlualineから自動非表示
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
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal', bg = 'Normal' }, --
            { fg = 'Normal', bg = 'Normal' }, --
        },
        default_state = 'on',
        desc = 'カラー表示',
        display_char = ' ', -- lualineで表示する文字
        auto_hide = true, -- 最初の状態(off)の時はlualineから自動非表示
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
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
        },
        default_state = 'off',
        desc = 'Migemo検索',
        -- display_char = '󰰑 ', -- lualineで表示する文字（スペース付き）
        display_char = 'み', -- lualineで表示する文字（スペース付き）
        auto_hide = true, -- 最初の状態(off)の時はlualineから自動非表示
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
                -- flash の画面内ジャンプ(<LocalLeader><Space>)も migemo モードになる
                vim.g.migemo_enabled = true
            else
                -- 標準の検索に戻す
                pcall(vim.keymap.del, 'n', '/')
                pcall(vim.keymap.del, 'n', '?')
                pcall(vim.keymap.del, 'n', 'g/')
                vim.g.migemo_enabled = false
            end
        end
    },

    f = { -- キー = F (quickscope)
        name = 'quickscope',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
        },
        default_state = 'on',
        desc = 'QuickScope',
        display_char = ' ', -- lualineで表示する文字
        auto_hide = true, -- 最初の状態(off)の時はlualineから自動非表示
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

    r = { -- キー = R (render-markdown インライン描画)
        name = 'render_markdown',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
            { fg = 'Normal', bg = 'Normal' }, -- on: Normal色
        },
        default_state = 'off',
        desc = 'Markdownインライン描画',
        display_char = '📝', -- lualineで表示する文字
        auto_hide = true,    -- off の時は lualine から自動非表示
        get_state = function()
            return vim.g.render_markdown_enabled and 'on' or 'off'
        end,
        set_state = function(state)
            -- lazy の require フックでロードされる。markdown未オープンでも require可。
            local ok, rm = pcall(require, 'render-markdown')
            if not ok then
                vim.notify('render-markdown.nvim not found', vim.log.levels.WARN)
                return
            end
            if state == 'on' then
                vim.g.render_markdown_enabled = true
                rm.enable()
            else
                vim.g.render_markdown_enabled = false
                rm.disable()
            end
        end
    },

    j = { -- キー = J (jump_mode)
        name = 'jump_mode',
        states = { 'global', 'file_local' },
        colors = {
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
        },
        default_state = 'file_local',
        desc = 'ジャンプモード',
        display_char = '󱀼 ', -- lualineで表示する文字（スペース付き）
        auto_hide = true, -- 最初の状態(off)の時はlualineから自動非表示
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

    -- w = { -- キー = W (windows_path)
    --     name = 'windows_path',
    --     states = { 'off', 'on' },
    --     colors = {
    --         { fg = 'Normal',  bg = 'Normal' },         -- off: Normal色
    --         { fg = '#000000', bg = 'DiagnosticWarn' }, -- on: 黒文字/DiagnosticWarn背景
    --     },
    --     default_state = 'off',
    --     desc = 'Windowsパス変換',
    --     get_state = function()
    --         return vim.g.auto_windows_path_mode and 'on' or 'off'
    --     end,
    --     set_state = function(state)
    --         if state == 'on' then
    --             vim.g.auto_windows_path_mode = true
    --             -- autocmdを作成（簡略化版）
    --             vim.g.auto_path_autocmd_id = vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    --                 callback = function()
    --                     local line = vim.api.nvim_get_current_line()
    --                     if line == "" or line:find('\n') then return end
    --                     if IsWindowsPath and IsWindowsPath(line) then
    --                         local converted_path = ConvertWindowsPath and ConvertWindowsPath(line)
    --                         if converted_path and FileExists and FileExists(converted_path) then
    --                             vim.api.nvim_set_current_line("")
    --                             vim.cmd('edit ' .. vim.fn.fnameescape(converted_path))
    --                         end
    --                     end
    --                 end
    --             })
    --         else
    --             vim.g.auto_windows_path_mode = false
    --             if vim.g.auto_path_autocmd_id then
    --                 pcall(vim.api.nvim_del_autocmd, vim.g.auto_path_autocmd_id)
    --                 vim.g.auto_path_autocmd_id = nil
    --             end
    --         end
    --     end
    -- },

    n = { -- キー = N (noice表示モード)
        name = 'noice_mode',
        states = { 'off', 'all', 'below' },
        colors = {
            { fg = 'Normal', bg = 'Normal' },           -- off: Normal色
            { fg = '#000000', bg = 'DiagnosticInfo' },  -- all: 黒文字/Info背景
            { fg = '#000000', bg = 'DiagnosticHint' },  -- below: 黒文字/Hint背景
        },
        default_state = 'all',
        desc = 'Noice表示モード',
        display_char = '💬', -- lualineで表示する文字
        auto_hide = false, -- 常に表示
        get_state = function()
            -- グローバル変数で状態を管理
            if vim.g.noice_display_mode == nil then
                vim.g.noice_display_mode = 'all'
            end
            return vim.g.noice_display_mode
        end,
        set_state = function(state)
            vim.g.noice_display_mode = state

            local ok, noice = pcall(require, 'noice')
            if not ok then return end

            if state == 'off' then
                -- 完全無効化（トラブルシューティング用）
                pcall(vim.cmd, 'Noice disable')
                vim.opt.cmdheight = 1

            elseif state == 'all' then
                -- フル機能（コマンドライン＋LSP進捗＋通知）
                -- Noiceを一度無効化して設定をリセット
                pcall(vim.cmd, 'Noice disable')
                vim.opt.cmdheight = 0
                local ok_config, config = pcall(require, 'noice.config')
                if ok_config and config.options then
                    -- コマンドラインをフローティング表示
                    if config.options.cmdline then
                        config.options.cmdline.enabled = true
                        config.options.cmdline.view = "cmdline_popup"
                    end
                end
                -- LSP設定を完全に有効化
                if ok_config and config.options and config.options.lsp then
                    config.options.lsp = {
                    progress = {
                        enabled = true,
                        view = "mini"
                    },
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                    hover = {
                        enabled = true
                    },
                    signature = {
                        enabled = true
                    },
                    message = {
                        enabled = true
                    }
                    }
                end
                -- メッセージ・通知を有効化
                if ok_config and config.options then
                    if config.options.messages then
                        config.options.messages.enabled = true
                    end
                    if config.options.notify then
                        config.options.notify.enabled = true
                    end
                end
                -- nvim-notifyを上方向に設定
                local notify_ok, notify = pcall(require, "notify")
                if notify_ok then
                    notify.setup({
                        top_down = true,  -- 上から下に表示
                        timeout = 3000,
                        render = "wrapped-compact"
                    })
                end
                -- Noiceを再度有効化
                pcall(vim.cmd, 'Noice enable')

            elseif state == 'below' then
                -- 最小限表示（下部Noiceコマンドライン＋通知のみ、LSP進捗OFF）
                -- Noiceを一度無効化
                pcall(vim.cmd, 'Noice disable')
                -- cmdheightを設定
                vim.opt.cmdheight = 0
                local config = require('noice.config')
                -- コマンドラインを下部に表示
                config.options.cmdline.enabled = true
                config.options.cmdline.view = "cmdline"  -- 下部表示（フローティングではない）
                -- LSP設定を完全に無効化
                config.options.lsp = {
                    progress = {
                        enabled = false
                    },
                    override = {},
                    hover = {
                        enabled = false
                    },
                    signature = {
                        enabled = false
                    },
                    message = {
                        enabled = false
                    }
                }
                -- メッセージ・通知は有効化
                config.options.messages.enabled = true
                config.options.notify.enabled = true
                -- nvim-notifyを下方向に設定
                local notify_ok, notify = pcall(require, "notify")
                if notify_ok then
                    notify.setup({
                        top_down = false,  -- 下から上に表示
                        timeout = 3000,
                        render = "wrapped-compact"
                    })
                end
                -- Noiceを再度有効化
                pcall(vim.cmd, 'Noice enable')
            end
        end
    },

    -- i キーは削除（nに統合）

    l = { -- キー = L (laststatus)
        name = 'laststatus',
        states = { '2', '3' },
        colors = {
            { fg = 'Normal', bg = 'Normal' }, -- 2: Normal色
            { fg = 'Normal', bg = 'Normal' }, -- 3: Normal色 (lualine非表示だから色不要)
        },
        default_state = '3',
        desc = 'ステータスライン表示',
        get_state = function()
            local status = vim.opt.laststatus:get()
            return tostring(status)
        end,
        set_state = function(state)
            vim.opt.laststatus = tonumber(state)
        end
    },

    v = { -- キー = V (cursorcolumn)
        name = 'cursorcolumn',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
            { fg = 'Normal', bg = 'Normal' }, -- off: Normal色
        },
        default_state = 'off',
        desc = 'カーソル縦表示',
        auto_hide = true, -- 最初の状態(off)の時はlualineから自動非表示
        display_char = '󰥓', -- lualineで表示する文字
        get_state = function()
            return vim.g.toggle_cursorcolumn_state or 'off'
        end,
        set_state = function(state)
            vim.g.toggle_cursorcolumn_state = state
            local enable = (state == 'on')
            -- 全ウィンドウに反映
            for _, win in pairs(vim.api.nvim_list_wins()) do
                local config = vim.api.nvim_win_get_config(win)
                if config.relative == '' then -- 通常ウィンドウのみ
                    vim.api.nvim_win_set_option(win, 'cursorcolumn', enable)
                end
            end
            -- グローバル設定も更新（新しいウィンドウ用）
            vim.o.cursorcolumn = enable
        end
    },

    k = { -- キー = K (markdown preview follow / web版プレビュー追従)
        name = 'preview_follow',
        states = { 'off', 'on' },
        colors = {
            { fg = 'Normal', bg = 'Normal' },          -- off: Normal色
            { fg = '#000000', bg = 'DiagnosticInfo' }, -- on: 黒文字/Info背景
        },
        default_state = 'off',
        desc = 'プレビュー追従(web)',
        display_char = '󰍔 ', -- nf-md-language_markdown（末尾スペース付き）
        auto_hide = true,
        get_state = function()
            return vim.g.preview_follow and 'on' or 'off'
        end,
        set_state = function(state)
            require('preview_pane').set_follow(state == 'on')
        end,
    },
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
