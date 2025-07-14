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
}) -- }}}

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
-- fishファイル用のフォーマット設定
vim.api.nvim_create_autocmd("FileType", {
    pattern = "fish",
    callback = function()
        -- フォーマットキーを設定
        vim.keymap.set('n', 'mf', function()
            vim.cmd('%!fish_indent')
        end, { buffer = true, noremap = true })
    end,
})

-- ホバー用のタイマー
local hover_timer = nil
-- カーソル停止時のイベント
-- autocmd("CursorHold", {
--     pattern = "*",
--     callback = function()
--         if vim.g.toggle_auto_hover == 1 then
--             if hover_timer then
--                 hover_timer:stop()
--             end
--             hover_timer = vim.defer_fn(function()
--                 vim.lsp.buf.hover()
--             end, 500)  -- 0.5秒後に表示
--         end
--     end
-- })

-- カーソル移動時のイベント
-- autocmd("CursorMoved", {
--     pattern = "*",
--     callback = function()
--         if hover_timer then
--             hover_timer:stop()
--         end
--         -- ホバーウィンドウをクリア
--         for _, winid in pairs(vim.api.nvim_list_wins()) do
--             if vim.api.nvim_win_get_config(winid).relative ~= '' then
--                 vim.api.nvim_win_close(winid, true)
--             end
--         end
--     end
-- })

-- 初期状態を設定
vim.g.toggle_auto_hover = 0

-- 起動時のランダムカラースキーム設定は21_keymap.luaで実行

-- autocmd('FileType', {
--     pattern = { 'python', 'lua', 'javascript', 'typescript' }, -- 必要な言語を指定
--     callback = function()
--         vim.cmd('SymbolsOutline')
--     end
-- })
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
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.bas", "*.cls", "*.frm", "*.vb" },
    group = "VBSyntax",
    callback = set_vb_filetype,
})

-- .QVB, .qvb, .Qvb ファイル用のオートコマンド
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.QVB", "*.qvb", "*.Qvb" },
    group = "VBSyntax",
    callback = set_vb_filetype,
})
