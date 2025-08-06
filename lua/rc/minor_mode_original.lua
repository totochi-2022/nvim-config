local M = {}

-- バリデーション関数
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
            if not entry.action or entry.action == "" then
                table.insert(errors, "entries[" .. i .. "].action is required")
            end
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
            if not action.action or action.action == "" then
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

-- 包括的なモード定義関数
function M.define_complete_mode(config)
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
    local persistent = options.persistent ~= false -- デフォルトtrue
    local exit_keys = options.exit_keys or {'<Esc>', 'q'} -- デフォルトで q と Esc
    local use_desc = options.use_desc ~= false -- デフォルトtrue
    local show_help_key = options.show_help_key or '?' -- デフォルトで ? でヘルプ
    
    -- プラグ名生成
    local plug_pending = ("<Plug>(m-p-%s)"):format(namespace)
    local plug_before_hook = ("<Plug>(m-b-%s)"):format(namespace)
    local plug_after_hook = ("<Plug>(m-a-%s)"):format(namespace)
    
    -- モード配列対応
    local modes = type(mode) == "table" and mode or { mode }
    
    -- タイムアウト制御
    local timeoutlen
    
    -- フック設定（タイムアウト制御込み）
    local enter_hook_with_timeout = function()
        timeoutlen = vim.opt.timeoutlen
        vim.opt.timeoutlen = 10000
        print("-- MODE:" .. namespace .. " --")
        -- ユーザー定義のenter_hookがあれば実行
        if hooks.enter then
            hooks.enter()
        end
    end
    
    local exit_hook_with_timeout = function()
        vim.opt.timeoutlen = timeoutlen
        print("exit minor mode")
        -- ユーザー定義のexit_hookがあれば実行
        if hooks.exit then
            hooks.exit()
        end
    end
    
    -- 継続用フック（タイムアウトのみ延長）
    local pending_hook = function()
        -- タイムアウトを維持（何もしない）
    end
    
    -- フックマッピング設定
    for _, m in ipairs(modes) do
        vim.keymap.set(m, plug_before_hook, enter_hook_with_timeout)
        vim.keymap.set(m, plug_after_hook, exit_hook_with_timeout)
        
        -- persistent設定によってpendingの動作を変更
        if persistent then
            vim.keymap.set(m, plug_pending, pending_hook)  -- 継続用（enter_hookは実行しない）
        else
            vim.keymap.set(m, plug_pending, plug_after_hook)
        end
        
        -- 終了キーの設定（finally的に必ず実行）
        for _, exit_key in ipairs(exit_keys) do
            vim.keymap.set(m, plug_pending .. exit_key, plug_after_hook, 
                use_desc and { desc = "モード終了" } or {})
        end
        
        -- ヘルプキーの設定
        if show_help_key then
            local help_function_name = namespace .. '_show_help'
            _G[help_function_name] = function()
                local help_lines = {"=== " .. namespace .. " MODE HELP ===", ""}
                
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
            
            vim.keymap.set(m, plug_pending .. show_help_key, '<cmd>lua ' .. help_function_name .. '()<CR>' .. plug_pending, 
                use_desc and { desc = "ヘルプ表示" } or {})
        end
    end
    
    -- エントリーポイント設定
    for _, entry in ipairs(entries) do
        local map_opts = {}
        if use_desc and entry.desc then
            map_opts.desc = entry.desc
        end
        
        -- アクション毎フックがある場合は組み込む
        local action_with_hook = entry.action
        if entry.hook then
            -- フック関数をグローバルに保存
            local hook_name = namespace .. '_entry_' .. entry.key .. '_hook'
            _G[hook_name] = entry.hook
            -- アクション実行後にフックを実行
            action_with_hook = entry.action .. '<cmd>lua ' .. hook_name .. '()<CR>'
        end
        
        for _, m in ipairs(modes) do
            vim.keymap.set(m, entry.key, plug_before_hook .. action_with_hook .. plug_pending, map_opts)
        end
    end
    
    -- モード内アクション設定
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
    
    -- WhichKey登録
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

function M.create(namespace, prefix, mode, beforehook, afterhook, options)
    local plug_pending = ("<Plug>(m-p-%s)"):format(namespace)
    local plug_before_hook = ("<Plug>(m-b-%s)"):format(namespace)
    local plug_after_hook = ("<Plug>(mr-a-%s)"):format(namespace)
    local timeoutlen

    -- options が nil の場合、空の table を使用
    local opts = options or {}

    -- 後方互換性のために 4, 5 番目の引数をオプションとして扱う
    if type(beforehook) == "table" and afterhook == nil and options == nil then
        opts = beforehook
        beforehook = nil
        afterhook = nil
    elseif type(beforehook) == "function" and opts.before_hook == nil then
        opts.before_hook = beforehook
    elseif beforehook ~= nil and type(beforehook) ~= "function" and opts.before_hook == nil then
        opts.before_hook = beforehook
    end

    if type(afterhook) == "function" and opts.after_hook == nil then
        opts.after_hook = afterhook
    elseif afterhook ~= nil and type(afterhook) ~= "function" and opts.after_hook == nil then
        opts.after_hook = afterhook
    end

    -- グローバルな終了キー設定
    if vim.g.minor_mode_exit_keys == nil then
        vim.g.minor_mode_exit_keys = { '<Esc>' } -- デフォルト値
    end

    -- オプション設定
    local exit_keys = opts.exit_keys or vim.g.minor_mode_exit_keys
    local persistent = opts.persistent or false
    local use_desc = (opts.use_desc ~= nil) and opts.use_desc or true

    -- デフォルトフック
    local default_before_hook = function()
        timeoutlen = vim.opt.timeoutlen
        vim.opt.timeoutlen = 10000
        print("-- MODE:" .. namespace .. " --")
    end

    local default_after_hook = function()
        vim.opt.timeoutlen = timeoutlen
        print("exit minor mode")
    end

    -- フック設定
    local before_hook = opts.before_hook or default_before_hook
    local after_hook = opts.after_hook or default_after_hook

    -- モード設定
    if mode == nil then
        mode = 'n'
    end

    -- モードの配列対応
    local modes = type(mode) == "table" and mode or { mode }

    -- 各モードに対してマッピングを設定
    for _, m in ipairs(modes) do
        vim.keymap.set(m, plug_before_hook, before_hook)
        vim.keymap.set(m, plug_after_hook, after_hook)

        -- persistentオプションによってプラグの動作を変更
        if persistent then
            vim.keymap.set(m, plug_pending, plug_before_hook)
        else
            vim.keymap.set(m, plug_pending, plug_after_hook)
        end

        -- 終了キーの設定
        for _, exit_key in ipairs(exit_keys) do
            if use_desc then
                vim.keymap.set(m, plug_pending .. exit_key, plug_after_hook, { desc = "モード終了" })
            else
                vim.keymap.set(m, plug_pending .. exit_key, plug_after_hook)
            end
        end
    end

    -- WhichKeyが存在するかを安全に確認する関数
    local function which_key_exists()
        local status_ok, _ = pcall(require, "which-key")
        return status_ok
    end

    -- 単一文字のプレフィックスをWhichKeyトリガーに追加（ここに新しいコードを追加）
    if #prefix == 1 then
        -- グローバルWhichKey更新関数が定義されていれば使用
        if _G.update_which_key_triggers then
            _G.update_which_key_triggers()
            -- そうでなければ、WhichKeyが存在する場合は既存のtriggersにプレフィックスを追加
        elseif which_key_exists() then
            local wk = require("which-key")
            local config = wk.config or {}
            local triggers = config.triggers or {}

            -- テーブルでなければ空のテーブルに初期化
            if type(triggers) ~= "table" then
                triggers = {}
            end

            -- すでに存在しないか確認してから追加
            local found = false
            for _, t in ipairs(triggers) do
                if t == prefix then
                    found = true
                    break
                end
            end

            if not found then
                table.insert(triggers, prefix)
                -- 設定を更新
                pcall(function()
                    wk.setup({ triggers = triggers })
                end)
            end
        end
    end

    local minor = {
        -- 複数エントリーポイント用の関数
        add_entry = function(entry_key, entry_desc)
            local map_opts = {}
            if use_desc and entry_desc then
                map_opts.desc = entry_desc
            end

            for _, m in ipairs(modes) do
                vim.keymap.set(m, entry_key, plug_before_hook, map_opts)
            end

            -- WhichKeyに登録
            if which_key_exists() and entry_desc then
                local wk = require("which-key")
                if wk.add then
                    for _, m in ipairs(modes) do
                        wk.add({
                            { entry_key, desc = entry_desc, mode = m }
                        })
                    end
                elseif wk.register then
                    for _, m in ipairs(modes) do
                        wk.register({
                            [entry_key] = { desc = entry_desc }
                        }, { mode = m })
                    end
                end
            end
        end,

        set = function(repeater, action, desc)
            -- descは省略可能
            local map_opts = {}
            if use_desc and desc then
                map_opts.desc = desc
            end

            for _, m in ipairs(modes) do
                if persistent then
                    vim.keymap.set(m, prefix .. repeater, plug_before_hook .. action .. plug_pending, map_opts)
                    vim.keymap.set(m, plug_pending .. repeater, action .. plug_pending, map_opts)
                else
                    vim.keymap.set(m, prefix .. repeater, plug_before_hook .. action .. plug_pending, map_opts)
                    vim.keymap.set(m, plug_pending .. repeater, action .. plug_pending, map_opts)
                end
            end

            -- WhichKeyに登録（自動判定）
            if which_key_exists() and desc then
                local wk = require("which-key")
                -- which-keyが新API（v3）をサポートしているかチェック
                if wk.add then
                    -- 新API（v3）を使用
                    for _, m in ipairs(modes) do
                        wk.add({
                            { prefix .. repeater, desc = desc, mode = m }
                        })
                    end
                elseif wk.register then
                    -- 旧API（v2）を使用
                    for _, m in ipairs(modes) do
                        wk.register({
                            [repeater] = { desc = desc }
                        }, { prefix = prefix, mode = m })
                    end
                end
            end
            -- -- WhichKeyに登録
            -- if which_key_exists() and desc then
            --     local wk = require("which-key")
            --     for _, m in ipairs(modes) do
            --         wk.register({
            --             [repeater] = { desc = desc }
            --         }, { prefix = prefix, mode = m })
            --     end
            -- end
        end,

        set_multi = function(params)
            local keymaps = {}

            for _, param in pairs(params) do
                local repeater = param[1]
                local action = param[2]
                local desc = param[3] -- 3番目の要素があればdescとして使用

                table.insert(keymaps, { repeater, action, desc })

                local map_opts = {}
                if use_desc and desc then
                    map_opts.desc = desc
                end

                for _, m in ipairs(modes) do
                    if persistent then
                        vim.keymap.set(m, prefix .. repeater, plug_before_hook .. action .. plug_pending, map_opts)
                        vim.keymap.set(m, plug_pending .. repeater, action .. plug_pending, map_opts)
                    else
                        vim.keymap.set(m, prefix .. repeater, plug_before_hook .. action .. plug_pending, map_opts)
                        vim.keymap.set(m, plug_pending .. repeater, action .. plug_pending, map_opts)
                    end
                end
            end

            -- -- WhichKeyに登録（存在する場合のみ）
            -- if which_key_exists() then
            --     local wk = require("which-key")
            --     local wk_mappings = {}

            --     for _, keymap in pairs(params) do
            --         local repeater = keymap[1]
            --         local desc = keymap[3] or ""

            --         wk_mappings[repeater] = { desc = desc }
            --     end

            --     for _, m in ipairs(modes) do
            --         wk.register(wk_mappings, { prefix = prefix, mode = m })
            --     end
            -- end
            -- WhichKeyに登録（自動判定）
            if which_key_exists() then
                local wk = require("which-key")
                
                -- which-keyが新API（v3）をサポートしているかチェック
                if wk.add then
                    -- 新API（v3）を使用
                    local wk_mappings = {}
                    for _, keymap in pairs(params) do
                        local repeater = keymap[1]
                        local desc = keymap[3] or ""
                        for _, m in ipairs(modes) do
                            table.insert(wk_mappings, { prefix .. repeater, desc = desc, mode = m })
                        end
                    end
                    wk.add(wk_mappings)
                elseif wk.register then
                    -- 旧API（v2）を使用
                    local wk_mappings = {}
                    for _, keymap in pairs(params) do
                        local repeater = keymap[1]
                        local desc = keymap[3] or ""
                        wk_mappings[repeater] = { desc = desc }
                    end
                    for _, m in ipairs(modes) do
                        wk.register(wk_mappings, { prefix = prefix, mode = m })
                    end
                end
            end

        end,
    }

    return minor
end

return M
