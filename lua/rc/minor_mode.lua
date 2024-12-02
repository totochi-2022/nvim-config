local M = {}

function M.create(namespace, prefix, mode, beforehook, afterhook)
    local plug_pending = ("<Plug>(m-p-%s)"):format(namespace)
    local plug_before_hook = ("<Plug>(m-b-%s)"):format(namespace)
    local plug_after_hook = ("<Plug>(mr-a-%s)"):format(namespace)
    local timeoutlen

    if beforehook == nil then
        beforehook = function()
            timeoutlen = vim.opt.timeoutlen
            vim.opt.timeoutlen = 10000
            print("-- MODE:" .. namespace .. " --")
        end
    end

    if mode == nil then
        mode = 'n'
    end

    if afterhook == nil then
        afterhook = function()
            vim.opt.timeoutlen = timeoutlen
            print("exit minor mode")
        end
    end

    vim.keymap.set(mode, plug_before_hook, beforehook)
    vim.keymap.set(mode, plug_after_hook, afterhook)
    vim.keymap.set(mode, plug_pending, plug_after_hook)

    local minor = {
        set = function(repeater, action)
            vim.keymap.set(mode, prefix .. repeater, plug_before_hook .. action .. plug_pending)
            vim.keymap.set(mode, plug_pending .. repeater, action .. plug_pending)
        end,

        set_multi = function (params)
            for _, param in pairs(params) do
                local repeater = param[1]
                local action = param[2]
                vim.keymap.set(mode, prefix .. repeater, plug_before_hook .. action .. plug_pending)
                vim.keymap.set(mode, plug_pending .. repeater, action .. plug_pending)
            end
        end,
    }

    return minor
end

return M


-- local M = {}

-- function M.create(namespace, prefix, mode, beforehook, afterhook)
--     local plug_pending = ("<Plug>(m-p-%s)"):format(namespace)
--     local plug_before_hook = ("<Plug>(m-b-%s)"):format(namespace)
--     local plug_after_hook = ("<Plug>(mr-a-%s)"):format(namespace)
--     local timeoutlen

--     if beforehook == nil then
--         beforehook = function()
--             timeoutlen = vim.opt.timeoutlen
--             vim.opt.timeoutlen = 10000
--             print("-- MODE:" .. namespace .. " --")
--         end
--     end

--     if mode == nil then
--         mode = 'n'
--     end

--     if afterhook == nil then
--         afterhook = function()
--             vim.opt.timeoutlen = timeoutlen
--             print("exit minor mode")
--         end
--     end

--     vim.keymap.set(mode, plug_before_hook, beforehook)
--     vim.keymap.set(mode, plug_after_hook, afterhook)
--     vim.keymap.set(mode, plug_pending, plug_after_hook)

--     local minor = {
--         set = function(repeater, action)
--             vim.keymap.set(mode, prefix .. repeater, plug_before_hook .. action .. plug_pending)
--             vim.keymap.set(mode, plug_pending .. repeater, action .. plug_pending)
--         end,

--         set_multi = function (params)
--             for _, param in pairs(params) do
--                 local repeater = param[1]
--                 local action = param[2]
--                 vim.keymap.set(mode, prefix .. repeater, plug_before_hook .. action .. plug_pending)
--                 vim.keymap.set(mode, plug_pending .. repeater, action .. plug_pending)
--             end
--         end,
--     }

--     return minor
-- end

-- return M



-- minor_mode.lua
-- local M = {}

-- function M.create(namespace, prefix, mode, beforehook, afterhook)
--     local plug_pending = ("<Plug>(m-p-%s)"):format(namespace)
--     local plug_before_hook = ("<Plug>(m-b-%s)"):format(namespace)
--     local plug_after_hook = ("<Plug>(mr-a-%s)"):format(namespace)
--     local timeoutlen

--     -- モード指定のデフォルト値
--     if mode == nil then
--         mode = 'n'
--     end

--     -- モードの配列対応
--     local modes = type(mode) == "table" and mode or {mode}

--     if beforehook == nil then
--         beforehook = function()
--             timeoutlen = vim.opt.timeoutlen
--             vim.opt.timeoutlen = 10000
--             print("-- MODE:" .. namespace .. " --")
--         end
--     end

--     if afterhook == nil then
--         afterhook = function()
--             vim.opt.timeoutlen = timeoutlen
--             print("exit minor mode")
--         end
--     end

--     -- 各モードに対してマッピングを設定
--     for _, m in ipairs(modes) do
--         vim.keymap.set(m, plug_before_hook, beforehook)
--         vim.keymap.set(m, plug_after_hook, afterhook)
--         vim.keymap.set(m, plug_pending, plug_after_hook)
--     end

--     local minor = {
--         set = function(repeater, action, desc)
--             -- 各モードに対してマッピングを設定
--             for _, m in ipairs(modes) do
--                 vim.keymap.set(m, prefix .. repeater, plug_before_hook .. action .. plug_pending)
--                 vim.keymap.set(m, plug_pending .. repeater, action .. plug_pending)
--             end
--         end,

--         set_multi = function(mappings)
--             for _, mapping in ipairs(mappings) do
--                 local repeater = mapping[1]
--                 local action = mapping[2]
--                 -- 各モードに対してマッピングを設定
--                 for _, m in ipairs(modes) do
--                     vim.keymap.set(m, prefix .. repeater, plug_before_hook .. action .. plug_pending)
--                     vim.keymap.set(m, plug_pending .. repeater, action .. plug_pending)
--                 end
--             end
--         end,
--     }

--     return minor
-- end

-- return M
