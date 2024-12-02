-- local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

local hl = vim.api.nvim_set_hl
-- vim.api.nvim_create_autocmd("CursorMoved", {
--   pattern = "*",
--   callback = function()
--     require('fold-preview').close_preview()
--   end
-- })
autocmd('BufRead', {
    pattern = "*.nc",
    command = ":set filetype=nc",
})
-- vim.cmd[[
-- au BufRead,BufNewFile *.nc set filetype=nc
-- ]]
-- Remove whitespace on save{{{
autocmd("BufWritePre", {
    pattern = "*",
    command = ":%s/\\s\\+$//e",
})-- }}}

--- 改行時のオートコメントアウトをしない{{{
autocmd("bufenter", {
    pattern = "*",
    callback = function()
        vim.opt.formatoptions:remove('c')
        vim.opt.formatoptions:remove('r')
        vim.opt.formatoptions:remove('o')
    end
})
-- }}}

--- オープン時前回のカーソル位置に飛ぶ{{{
autocmd("bufreadpost", {
    pattern = "*",
    callback = function()
        local pre_line = vim.fn.line([['"]])
        if 0 < pre_line and pre_line <= vim.fn.line([[$]]) then
            vim.api.nvim_exec('silent! normal! g`"zv', false)
        end
    end,
})
-- }}}

--- カーソルホールドで自動的にlspホバー{{{
-- autocmd({ "CursorHold", "CursorHoldI" }, {
--     pattern = "*",
--     callback = function()
--         if vim.g.toggle_auto_hover == 1 then
--             vim.lsp.buf.hover()
--         else
--             vim.lsp.buf.document_highlight()
--         end
--     end
-- })

autocmd({ "CursorMoved", "CursorMovedI" }, {
    pattern = "*",
    callback = function()
        vim.lsp.buf.clear_references()
    end
})
-- }}}

--- カラースキーム読み込み時の再設定 {{{
autocmd('ColorScheme', {
    pattern = '*',
    callback = function()
        -- QuickScope
        hl(0, 'QuickScopePrimary', { fg = '#ffff00', underline = true })
        hl(0, 'QuickScopeSecondary', { fg = '#ff0000', underline = true })
        -- Foldcc
        hl(0, 'Folded', { fg = '#1090d0' })

        hl(0, 'CursorColumn', { link = 'CursorLine' })
        if vim.g.colors_name == 'zephyr' then
            hl(0, 'FoldColumn', { link = 'lineNr' })
        end

        if vim.g.colors_name == 'tokyonight' then
            hl(0, 'CursorLine', { bg = '#191e2e' })
        end

        if vim.g.colors_name == 'gruvbox' then
            hl(0, 'CursorLine', { bg = '#292523' })
            hl(0, 'Folded', { fg = '#999999' })
        end
    end
})
-- }}}
local function set_vb_filetype()
  vim.bo.filetype = "vb"
end

-- オートコマンドグループの作成
vim.api.nvim_create_augroup("VBSyntax", { clear = true })

-- .bas, .cls, .frm, .vb ファイル用のオートコマンド
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.bas", "*.cls", "*.frm", "*.vb"},
  group = "VBSyntax",
  callback = set_vb_filetype,
})

-- .QVB, .qvb, .Qvb ファイル用のオートコマンド
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.QVB", "*.qvb", "*.Qvb"},
  group = "VBSyntax",
  callback = set_vb_filetype,
})



