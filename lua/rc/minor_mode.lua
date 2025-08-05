-- Minor Mode Library for Neovim
-- モーダルキーバインディングシステム
-- vim の <Plug> マッピング機能を活用してキーシーケンスを実現

local M = {}

-- 設定バリデーション関数
-- minor_mode設定の妥当性をチェック
local function validate_config(config)
    local errors = {}

    -- 必須フィールドのチェック
    if not config.namespace or config.namespace == "" then
        table.insert(errors, "namespace is required and cannot be empty")
    end

    -- entriesの検証
    if config.entries then
        for i, entry in ipairs(config.entries) do
            if not entry.key or entry.key == "" then
                table.insert(errors, "entries[" .. i .. "].key is required")
            end
            -- actionは省略可能（モード開始のみの場合）
            if entry.hook and type(entry.hook) ~= "function" then
                table.insert(errors, "entries[" .. i .. "].hook must be a function")
            end
        end
    end

    -- actionsの検証
    if config.actions then
        for i, action in ipairs(config.actions) do
            if not action.key or action.key == "" then
                table.insert(errors, "actions[" .. i .. "].key is required")
            end
            if not action.action then
                table.insert(errors, "actions[" .. i .. "].action is required")
            end
            if action.hook and type(action.hook) ~= "function" then
                table.insert(errors, "actions[" .. i .. "].hook must be a function")
            end
        end
    end

    -- hooksの検証
    if config.hooks then
        if config.hooks.enter and type(config.hooks.enter) ~= "function" then
            table.insert(errors, "hooks.enter must be a function")
        end
        if config.hooks.exit and type(config.hooks.exit) ~= "function" then
            table.insert(errors, "hooks.exit must be a function")
        end
    end

    return errors
end

-- メインのモード定義関数
-- 包括的なminor_modeを定義する新しいAPI
function M.define_mode(config)
    -- バリデーション実行
    local validation_errors = validate_config(config)
    if #validation_errors > 0 then
        error("minor_mode configuration errors:\n" .. table.concat(validation_errors, "\n"))
    end

    local namespace = config.namespace
    local entries = config.entries or {}
    local actions = config.actions or {}
    local hooks = config.hooks or {}
    local options = config.options or {}

    -- デフォルト設定
    local mode = options.mode or 'n'
    local persistent = options.persistent ~= false          -- デフォルトtrue
    local exit_keys = options.exit_keys or { '<Esc>', 'q' } -- デフォルトで q と Esc
    local use_desc = options.use_desc ~= false              -- デフォルトtrue
    local show_help_key = options.show_help_key or '?'      -- デフォルトで ? でヘルプ
    local change_timeout = options.change_timeout ~= false  -- デフォルトtrue（後方互換性のため）

    -- <Plug>マッピング名を生成
    -- pending: モード継続用、before_hook: モード開始用、after_hook: モード終了用
    local plug_pending = ("<Plug>(m-p-%s)"):format(namespace)
    local plug_before_hook = ("<Plug>(m-b-%s)"):format(namespace)
    local plug_after_hook = ("<Plug>(m-a-%s)"):format(namespace)

    -- モード配列対応
    local modes = type(mode) == "table" and mode or { mode }

    -- タイムアウト制御
    local timeoutlen

    -- モード開始/終了フックの設定
    -- タイムアウト値を変更してキー入力待ち時間を延長
    local enter_hook_with_timeout = function()
        if change_timeout then
            timeoutlen = vim.opt.timeoutlen
            vim.opt.timeoutlen = 10000
        end
        print("-- MODE:" .. namespace .. " --")
        -- ユーザー定義のenter_hookがあれば実行
        if hooks.enter then
            hooks.enter()
        end
    end

    local exit_hook_with_timeout = function()
        if change_timeout then
            vim.opt.timeoutlen = timeoutlen
        end
        print("exit minor mode")
        -- ユーザー定義のexit_hookがあれば実行
        if hooks.exit then
            hooks.exit()
        end
    end

    -- モード継続フック（タイムアウトのみ維持）
    local pending_hook = function()
        -- タイムアウトを維持（何もしない）
    end

    -- 各モードに対してフックマッピングを設定
    -- <Plug>を通してフック関数を呼び出し
    for _, m in ipairs(modes) do
        vim.keymap.set(m, plug_before_hook, enter_hook_with_timeout)
        vim.keymap.set(m, plug_after_hook, exit_hook_with_timeout)

        -- persistent設定によってpendingの動作を変更
        if persistent then
            vim.keymap.set(m, plug_pending, pending_hook) -- 継続用（enter_hookは実行しない）
        else
            vim.keymap.set(m, plug_pending, plug_after_hook)
        end

        -- 終了キーの設定（finally的に必ず実行）
        for _, exit_key in ipairs(exit_keys) do
            vim.keymap.set(m, plug_pending .. exit_key, plug_after_hook,
                use_desc and { desc = "モード終了" } or {})
        end

        -- ヘルプ表示機能の設定
        -- ?キーでモードのヘルプをフローティングウィンドウで表示
        if show_help_key then
            local help_function_name = namespace .. '_show_help'
            _G[help_function_name] = function()
                local help_lines = { "=== " .. namespace .. " MODE HELP ===", "" }

                -- エントリーポイント
                if #entries > 0 then
                    table.insert(help_lines, "Entry Points:")
                    for _, entry in ipairs(entries) do
                        table.insert(help_lines, "  " .. entry.key .. " - " .. (entry.desc or "No description"))
                    end
                    table.insert(help_lines, "")
                end

                -- モード内アクション
                if #actions > 0 then
                    table.insert(help_lines, "Mode Actions:")
                    for _, action in ipairs(actions) do
                        table.insert(help_lines, "  " .. action.key .. " - " .. (action.desc or "No description"))
                    end
                    table.insert(help_lines, "")
                end

                -- 終了キー
                table.insert(help_lines, "Exit Keys:")
                for _, exit_key in ipairs(exit_keys) do
                    table.insert(help_lines, "  " .. exit_key .. " - モード終了")
                end
                table.insert(help_lines, "  " .. show_help_key .. " - このヘルプ")

                -- ヘルプを表示（シンプルで確実な方法）
                local help_text = table.concat(help_lines, '\n')

                -- 一時バッファでヘルプを表示
                local buf = vim.api.nvim_create_buf(false, true)
                local lines = vim.split(help_text, '\n')
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                vim.api.nvim_buf_set_option(buf, 'modifiable', false)
                vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
                vim.api.nvim_buf_set_option(buf, 'filetype', 'help')

                -- フローティングウィンドウで表示
                local width = 60
                local height = #lines + 2
                local win = vim.api.nvim_open_win(buf, true, {
                    relative = 'cursor',
                    width = width,
                    height = height,
                    col = 0,
                    row = 1,
                    border = 'rounded',
                    style = 'minimal',
                    title = ' ' .. namespace .. ' Help ',
                    title_pos = 'center'
                })

                -- qとEscでウィンドウを閉じる
                vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, noremap = true })
                vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf, noremap = true })
            end

            vim.keymap.set(m, plug_pending .. show_help_key,
                '<cmd>lua ' .. help_function_name .. '()<CR>' .. plug_pending,
                use_desc and { desc = "ヘルプ表示" } or {})
        end
    end

    -- エントリーポイント（モード開始キー）の設定
    -- モード外から実行してモードを開始するキー
    for _, entry in ipairs(entries) do
        local map_opts = {}
        if use_desc and entry.desc then
            map_opts.desc = entry.desc
        end

        -- アクション毎フックがある場合は組み込む
        local action_with_hook = entry.action or '' -- actionが未定義の場合は空文字
        if entry.hook then
            -- フック関数をグローバルに保存
            local hook_name = namespace .. '_entry_' .. entry.key .. '_hook'
            _G[hook_name] = entry.hook
            -- アクション実行後にフックを実行
            action_with_hook = action_with_hook .. '<cmd>lua ' .. hook_name .. '()<CR>'
        end

        for _, m in ipairs(modes) do
            vim.keymap.set(m, entry.key, plug_before_hook .. action_with_hook .. plug_pending, map_opts)
        end
    end

    -- モード内アクション（繰り返し可能なキー）の設定
    -- モード内で実行可能な各種アクション
    for _, action in ipairs(actions) do
        local map_opts = {}
        if use_desc and action.desc then
            map_opts.desc = action.desc
        end

        -- アクション毎フックがある場合は組み込む
        local action_with_hook = action.action
        if action.hook then
            -- フック関数をグローバルに保存
            local hook_name = namespace .. '_action_' .. action.key .. '_hook'
            _G[hook_name] = action.hook
            -- アクション実行後にフックを実行
            action_with_hook = action.action .. '<cmd>lua ' .. hook_name .. '()<CR>'
        end

        for _, m in ipairs(modes) do
            vim.keymap.set(m, plug_pending .. action.key, action_with_hook .. plug_pending, map_opts)
        end
    end

    -- WhichKey統合
    -- which-keyプラグインと連携してキー説明を表示
    local function register_which_key()
        local ok, wk = pcall(require, "which-key")
        if not ok then return end

        -- エントリーポイントをWhichKeyに登録
        if wk.add then
            -- 新API（v3）
            local wk_mappings = {}
            for _, entry in ipairs(entries) do
                if entry.desc then
                    for _, m in ipairs(modes) do
                        table.insert(wk_mappings, { entry.key, desc = entry.desc, mode = m })
                    end
                end
            end
            if #wk_mappings > 0 then
                wk.add(wk_mappings)
            end
        elseif wk.register then
            -- 旧API（v2）
            for _, entry in ipairs(entries) do
                if entry.desc then
                    for _, m in ipairs(modes) do
                        wk.register({ [entry.key] = { desc = entry.desc } }, { mode = m })
                    end
                end
            end
        end
    end

    register_which_key()
end

return M
