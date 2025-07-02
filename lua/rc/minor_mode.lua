local M = {}

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
    elseif beforehook ~= nil and opts.before_hook == nil then
        opts.before_hook = beforehook
    end

    if afterhook ~= nil and opts.after_hook == nil then
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
