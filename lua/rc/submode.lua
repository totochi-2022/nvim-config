-- submode 相当の機能を提供する。
--
-- vim.keymap.set("n", "s+", "<C-w>+<Plug>(vimrc-enter-pending)")
-- vim.keymap.set("n", "<Plug>(vimrc-enter-pending)+", "<C-w>+<Plug>(vimrc-enter-pending)")
-- vim.keymap.set("n", "<Plug>(vimrc-enter-pending)", "<Nop>")
-- （Lua では <SID> が使えないので <Plug> で代用。

local M = {}

function M.create_mode(namespace, prefix, beforehook, afterhook)
    local plug_pending = ("<Plug>(submode-p-%s)"):format(namespace)
    local plug_before_hook = ("<Plug>(submode-b-%s)"):format(namespace)
    local plug_after_hook = ("<Plug>(submode-a-%s)"):format(namespace)
    local mode = 'n'
    local timeoutlen

    if beforehook == nil then
        beforehook = function()
            timeoutlen = vim.opt.timeoutlen
            vim.opt.timeoutlen = 10000
            print("++MODE:[" .. namespace .. "]++")
        end
    end

    if afterhook == nil then
        afterhook = function()
            vim.opt.timeoutlen = timeoutlen
            print("Exit Submode")
        end
    end

    vim.keymap.set(mode, plug_before_hook, beforehook)
    vim.keymap.set(mode, plug_after_hook, afterhook)
    vim.keymap.set(mode, plug_pending, plug_after_hook)

    local submode = {
        register_mapping = function(repeater, action)
            vim.keymap.set(mode, prefix .. repeater, plug_before_hook .. action .. plug_pending)
            vim.keymap.set(mode, plug_pending .. repeater, action .. plug_pending)
        end,

        register_mapping_multi = function (maps)
            for _, map in pairs(maps) do
                local repeater = map[1]
                local action = map[2]
                vim.keymap.set(mode, prefix .. repeater, plug_before_hook .. action .. plug_pending)
                vim.keymap.set(mode, plug_pending .. repeater, action .. plug_pending)
            end
        end,
    }

    return submode
end

return M
