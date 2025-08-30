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
-- fishファイル用のフォーマット設定は lua/21_keymap.lua に移動

-- auto_hover機能は13_lsp.luaでLSP標準機能として実装

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

-- markdownファイルで診断を無効化（バッファ単位）
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
    pattern = { "*.md", "*.markdown", "markdown" },
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        -- バッファ単位で診断のみ無効化（LSPクライアントは停止しない）
        vim.diagnostic.disable(bufnr)
    end,
    desc = "Disable diagnostics in markdown files"
})

-- LSPホバーウィンドウ自動ボーダー設定
--
-- 概要：
-- - BufWinEnterイベントでフローティングウィンドウを監視
-- - LSPホバーは zindex 45/60 で識別可能
-- - zindex 45: 毎回2個のウィンドウが作られるため、pos=(0,2)の最初のウィンドウのみに適用
-- - zindex 60: 通常1個のウィンドウなので、すべて対象
-- - 対象はrelative='win'のウィンドウのみ（relative='editor'は除外）
-- - 手動ホバー（K、m<Space>）、自動ホバー（CursorHold）共に対応
local function setup_lsp_hover_border_hook()
    -- デバッグモードフラグ（必要に応じて true に変更）
    local debug_mode = false -- true にするとウィンドウ情報を出力

    local check_floating_windows = function(event_name)
        return function()
            vim.defer_fn(function()
                -- 全ウィンドウをチェック
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    local ok, config = pcall(vim.api.nvim_win_get_config, win)

                    if ok and config.relative ~= '' then
                        -- デバッグ出力（フローティングウィンドウの詳細情報）
                        if debug_mode then
                            print(string.format(
                                "[%s] Float Win %d: zindex=%s, pos=(%d,%d), size=%dx%d, border=%s, relative=%s",
                                event_name, -- どのイベントで検出したか表示
                                win,
                                config.zindex or "nil",
                                config.row or -1,
                                config.col or -1,
                                config.width or 0,
                                config.height or 0,
                                vim.inspect(config.border):gsub("\n", ""),
                                config.relative
                            ))
                        end
                        -- zindex 45,(0,2)位置のウィンドウのみ
                        if config.relative == 'win' and
                            (config.zindex == 45 and config.row == 0 and config.col == 2) then
                            -- まだボーダーがない場合のみ設定
                            if not config.border or config.border == "none" then
                                -- zindex 45は角丸、zindex 60は四角
                                config.border = 'rounded'
                                pcall(vim.api.nvim_win_set_config, win, config)

                                if debug_mode then
                                    print("  → Border applied by " .. event_name .. " to window " .. win)
                                end
                            end
                        end

                        -- -- zindex 45の時は(0,2)位置のウィンドウのみ、zindex 60は全て対象
                        -- if config.relative == 'win' and
                        --    ((config.zindex == 45 and config.row == 0 and config.col == 2) or
                        --     config.zindex == 60) then
                        --     -- まだボーダーがない場合のみ設定
                        --     if not config.border or config.border == "none" then
                        --         -- zindex 45は角丸、zindex 60は四角
                        --         config.border = config.zindex == 45 and 'rounded' or 'single'
                        --         pcall(vim.api.nvim_win_set_config, win, config)
                        --
                        --         if debug_mode then
                        --             print("  → Border applied by " .. event_name .. " to window " .. win)
                        --         end
                        --     end
                        -- end
                    end
                end
            end, 10)
        end
    end

    -- BufWinEnterイベントでLSPホバーウィンドウを監視
    vim.api.nvim_create_autocmd("BufWinEnter", {
        group = vim.api.nvim_create_augroup("LSPHoverBorder", { clear = true }),
        callback = check_floating_windows("BufWinEnter"),
        desc = "LSPホバーウィンドウにボーダーを自動設定"
    })
end

-- フック設定を起動時に実行
setup_lsp_hover_border_hook()
