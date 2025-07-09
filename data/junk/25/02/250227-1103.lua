-- check_icons.lua
local output_file = vim.fn.expand('~/icon_debug.txt')
local file = io.open(output_file, "w")

-- ヘッダー情報を書き込み
file:write("=== NEOVIM ICON DEBUG INFO ===\n\n")
file:write("Neovim Version: " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch .. "\n")
file:write("OS: " .. vim.loop.os_uname().sysname .. "\n")
file:write("IS_WSL: " .. tostring(vim.fn.has('wsl') == 1) .. "\n")
file:write("gui: " .. tostring(vim.fn.has('gui_running') == 1) .. "\n\n")

-- フォント・エンコーディング関連
file:write("=== FONT & ENCODING SETTINGS ===\n")
file:write("ambiwidth: " .. vim.opt.ambiwidth:get() .. "\n")
file:write("encoding: " .. vim.opt.encoding:get() .. "\n")
file:write("fileencoding: " .. vim.opt.fileencoding:get() .. "\n")
file:write("termguicolors: " .. tostring(vim.opt.termguicolors:get()) .. "\n")
if vim.g.guifont then
    file:write("guifont: " .. vim.g.guifont .. "\n")
end
file:write("\n")

-- nvim-web-devicons の設定
file:write("=== WEB DEVICONS CONFIG ===\n")
local has_devicons, devicons = pcall(require, "nvim-web-devicons")
if has_devicons then
    file:write("nvim-web-devicons loaded: true\n")
    -- アイコン一覧を出力
    local sample_icons = devicons.get_icons()
    if sample_icons then
        file:write("Sample icons:\n")
        local count = 0
        for filetype, icon_data in pairs(sample_icons) do
            if count < 5 then  -- 最初の5つだけ出力
                file:write(string.format("  %s: icon='%s', codepoint=U+%X\n",
                    filetype, icon_data.icon, utf8.codepoint(icon_data.icon)))
                count = count + 1
            end
        end
    end
else
    file:write("nvim-web-devicons loaded: false\n")
end
file:write("\n")

-- lualine の設定
file:write("=== LUALINE CONFIG ===\n")
local has_lualine, lualine = pcall(require, "lualine")
if has_lualine then
    file:write("lualine loaded: true\n")
    local config = require("lualine").get_config()
    if config then
        file:write("icons_enabled: " .. tostring(config.options.icons_enabled) .. "\n")
        file:write("component_separators: left='" .. (config.options.component_separators.left or "") ..
                  "', right='" .. (config.options.component_separators.right or "") .. "'\n")
        file:write("section_separators: left='" .. (config.options.section_separators.left or "") ..
                  "', right='" .. (config.options.section_separators.right or "") .. "'\n")

        -- 診断アイコンを出力
        if config.sections and config.sections.lualine_b then
            for _, component in ipairs(config.sections.lualine_b) do
                if type(component) == "table" and component[1] == "diagnostics" then
                    file:write("Diagnostic icons:\n")
                    if component.symbols then
                        for severity, icon in pairs(component.symbols) do
                            file:write(string.format("  %s: '%s'\n", severity, icon))
                        end
                    else
                        file:write("  No custom symbols defined\n")
                    end
                    break
                end
            end
        end
    end
else
    file:write("lualine loaded: false\n")
end
file:write("\n")
