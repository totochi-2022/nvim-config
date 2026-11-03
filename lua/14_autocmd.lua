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

        -- flash.nvim: ラベル(ジャンプ文字)と一致箇所が同色にならないよう固定色で上書き。
        -- ランダムスキーム(RandomScheme)でデフォルトのリンク先(Substitute/Search)が
        -- 似た色になり区別できなくなるのを防ぐ。
        hl(0, 'FlashLabel', { fg = '#ffffff', bg = '#ff007c', bold = true }) -- ジャンプ文字: ピンク背景
        hl(0, 'FlashMatch', { fg = '#000000', bg = '#00dfff' })             -- 一致箇所: シアン背景
        hl(0, 'FlashCurrent', { fg = '#000000', bg = '#ffd700' })           -- 現在の一致: 金背景
        hl(0, 'FlashBackdrop', { fg = '#777777' })                          -- 背景(減光)

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

-- クリップボード連携をVeryLazyで遅延設定（02_option.luaから移動）
-- 起動時に設定するとyankyのinit_history(VimEnter)が+レジスタ=クリップボードを読み、
-- WSL2のXWayland初回接続で約166ms起動が遅延するため。VeryLazyに遅らせて回避。
autocmd('User', {
    pattern = 'VeryLazy',
    once = true,
    callback = function()
        local is_win = vim.fn.has('win64') == 1
        vim.opt.clipboard = is_win and { 'unnamed' } or { 'unnamedplus', 'unnamed' }
    end,
    desc = 'クリップボード連携を遅延設定（起動高速化）',
})

-- vimdoc-jaのhelptags生成物 doc/tags-ja を HEAD に戻す
-- （lazyは doc/tags のみ自動クリーンするため、tags-jaが残ると Lazy update が衝突で失敗する）
-- 起動時(VeryLazy)と更新直前(LazyUpdatePre/LazySyncPre)に実行し、更新フローを常にクリーンに迎える
autocmd('User', {
    pattern = { 'VeryLazy', 'LazyUpdatePre', 'LazySyncPre' },
    callback = function()
        local dir = vim.fn.stdpath('data') .. '/lazy/vimdoc-ja'
        if vim.fn.isdirectory(dir .. '/.git') == 1 then
            -- LazySyncPreではこの直後にlazyがdirtyチェックするため同期実行(:wait)が必須
            vim.system({ 'git', 'checkout', '--', 'doc/tags-ja' }, { cwd = dir }):wait()
        end
    end,
    desc = 'Reset vimdoc-ja doc/tags-ja to avoid Lazy update conflicts',
})

-- markdownファイルで診断を無効化（バッファ単位）
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
    pattern = { "*.md", "*.markdown", "markdown" },
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        -- バッファ単位で診断のみ無効化（LSPクライアントは停止しない）
        vim.diagnostic.enable(false, { bufnr = bufnr })
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

-- 外部(AI)の書き換えを undo 履歴に載せる{{{
-- Claude 等がディスク上のファイルを書き換えると、従来はバッファが古いまま取り残され、
-- 気づいた頃には undo で AI 前に戻れなかった。'undoreload'(02_option.lua)が
-- 「リロード前の全文」を undo 1 ノードとして積むので、取り込みさえすれば
-- 「前に見たときから今までの変更」がまとめて u 一発で戻せる。
local ai_undo = vim.api.nvim_create_augroup("ai_undo", { clear = true })

-- 外部優先。自分が未保存でもディスク(AI)の方を採る。
-- 捨てた未保存の編集も undo に積まれるので u で戻せる(#2 AI → #1 未保存 → #0 元)。
-- Post 側で v:fcs_reason が読めないので、Shell 側で控えておく(通知の文面を変えるため)
local ai_undo_reason = {}

autocmd("FileChangedShell", {
    group = ai_undo,
    callback = function(a)
        local r = vim.v.fcs_reason
        ai_undo_reason[a.buf] = r -- Post 側の通知文のために控える
        if r == "changed" or r == "conflict" then
            vim.v.fcs_choice = "reload"
        elseif r == "deleted" then
            vim.v.fcs_choice = "ask" -- 消えた時だけは黙って捨てない
        else
            vim.v.fcs_choice = "" -- mode/time だけの変化は何もしない
        end
    end,
    desc = "外部で書き換わったファイルは AI 側(ディスク)を優先して取り込む",
})

-- 取り込みの引き金。Claude は nvim の端末の中にいるので FocusGained は発火しない。
-- :checktime は autocmd の中から呼ぶと「副作用が無害な時まで延期」されて流れてしまうため、
-- vim.schedule で autocmd の外に出す(:help :checktime)。
autocmd({ "CursorHold", "CursorHoldI", "BufEnter", "WinEnter", "TermLeave", "FocusGained" }, {
    group = ai_undo,
    callback = function()
        if vim.bo.buftype == "" and vim.fn.getcmdwintype() == "" then
            vim.schedule(function() pcall(vim.cmd, "checktime") end)
        end
    end,
    desc = "外部の書き換えをバッファに取り込む(updatetime=500 なので手を止めて 0.5 秒)",
})

-- undofile のハッシュ検査は「いまのバッファの本文」に対して行われる。土台が合えば読めるので、
-- 下の open 時の復元に使う「最後に undofile と辻褄が合っていた本文」を影コピーとして取っておく。
-- undofile と同じ流儀のパス。undofile 同様 nvim は消さないので、要らなくなったら自分で消す
local shadow_dir = vim.fn.stdpath("state") .. "/undoshadow"
local function shadow_path(name)
    return shadow_dir .. "/" .. name:gsub("[/\\:]", "%%")
end
local function save_shadow(buf)
    if not vim.bo[buf].undofile or vim.bo[buf].buftype ~= "" then return end
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then return end
    vim.fn.mkdir(shadow_dir, "p")
    pcall(vim.fn.writefile, vim.api.nvim_buf_get_lines(buf, 0, -1, false), shadow_path(name))
end

-- 取り込んだ直後に undofile の土台を貼り替える。undofile は「書いた時の本文」と
-- ハッシュが合わないと読まれない(File contents changed, cannot use undo info)ので、
-- ここで書き直しておかないと nvim を開き直した時点で履歴が消える。
-- 中身は変わっていないので :w ではなく :wundo!(ファイルの mtime を動かさない)。
autocmd("FileChangedShellPost", {
    group = ai_undo,
    callback = function(a)
        if not vim.bo[a.buf].undofile or vim.bo[a.buf].buftype ~= "" then return end
        local name = vim.api.nvim_buf_get_name(a.buf)
        if name == "" then return end
        vim.api.nvim_buf_call(a.buf, function()
            pcall(vim.cmd, "silent! wundo! " .. vim.fn.fnameescape(vim.fn.undofile(name)))
        end)
        save_shadow(a.buf)
        -- 「置き換わったこと」を知らせる。hit-enter にならないよう vim.notify(noice のトースト)で出す
        local r = ai_undo_reason[a.buf]
        ai_undo_reason[a.buf] = nil
        local tail = vim.fn.fnamemodify(name, ":t")
        if r == "conflict" then
            vim.notify(tail .. ": 外部の変更で置き換えました（未保存の編集は u で戻せます）", vim.log.levels.WARN)
        else
            vim.notify(tail .. ": 外部の変更を取り込みました（u で戻せます）", vim.log.levels.INFO)
        end
    end,
    desc = "取り込み後に undofile を書き直し、再起動後も AI 前に戻れるようにする",
})

autocmd("BufWritePost", {
    group = ai_undo,
    callback = function(a) save_shadow(a.buf) end,
    desc = "保存した本文を影コピーに控える(open 時の復元用)",
})

-- nvim を閉じている間に AI が書き換えた場合。開いた時点でディスクは AI 版なので undofile の
-- ハッシュが合わず、履歴が丸ごと読めない。そこで「いったん保存時の本文に戻す → :rundo →
-- AI 版に戻す」で土台を合わせに行く。最後の差し替えが AI の編集ぶんの undo ノードになる。
--   u 1回 → 自分が最後に保存した版 / もう 1 回 → 閉じる前の履歴
-- 影コピーが古い等で :rundo が失敗したら、何もしなかった状態(履歴なし)に戻すだけ。
local function restore_from_shadow(buf)
    if not vim.bo[buf].undofile or vim.bo[buf].buftype ~= "" then return end
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then return end
    local uf, sp = vim.fn.undofile(name), shadow_path(name)
    if vim.fn.filereadable(uf) ~= 1 or vim.fn.filereadable(sp) ~= 1 then return end
    vim.api.nvim_buf_call(buf, function()
        if vim.fn.undotree().seq_last > 0 then return end -- 普通に読めている
        local now = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local saved = vim.fn.readfile(sp)
        if vim.deep_equal(now, saved) then return end -- 閉じている間に変わっていない
        local ul = vim.bo[buf].undolevels
        vim.bo[buf].undolevels = -1 -- 土台戻しは履歴に残さない
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, saved)
        vim.bo[buf].undolevels = ul
        -- :rundo は成功すると "Finished reading undo file ..." を出し、他のメッセージと
        -- 重なると hit-enter プロンプトになって起動のたびに Enter を要求される。
        -- silent! で黙らせる代わりに、成否は pcall ではなく seq_last で見る
        vim.cmd("silent! rundo " .. vim.fn.fnameescape(uf))
        if vim.fn.undotree().seq_last > 0 then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, now) -- これが AI ぶんの undo ノード
        else
            vim.bo[buf].undolevels = -1
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, now)
            vim.bo[buf].undolevels = ul
        end
        vim.bo[buf].modified = false
        local tail = vim.fn.fnamemodify(name, ":t")
        vim.schedule(function()
            vim.notify(tail .. ": 閉じている間に外部で変更されていました（u で戻せます）", vim.log.levels.INFO)
        end)
    end)
end

autocmd("BufReadPost", {
    group = ai_undo,
    callback = function(a) restore_from_shadow(a.buf) end,
    desc = "閉じている間の外部編集を undo ノードとして復元する",
})

-- 保険。この行が走る時点ですでに読み込まれているバッファを 1 回ぶん拾う。
-- (init.lua で設定を遅延ロードすると、コマンドラインで渡したファイルの BufReadPost は
--  上の登録より先に終わってしまう。いまは遅延していないので通常は空振りする)
for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
        pcall(restore_from_shadow, b)
    end
end
--}}}
