-- Cheatsheet System
-- Markdownチートシートの管理と表示

-- チートシートのベースディレクトリ
local cheatsheet_dir = vim.fn.stdpath('config') .. '/lua/cheatsheets'

-- 利用可能なチートシート一覧
local cheatsheets = {
    { key = 'i', file = 'index.md', desc = 'インデックス' },
    { key = 'j', file = 'jump.md', desc = 'ジャンプ・移動' },
    { key = 'v', file = 'selection.md', desc = '選択・ビジュアル' },
    { key = 'f', file = 'fold.md', desc = 'フォールド' },
    { key = 'c', file = 'comment.md', desc = 'コメント操作' },
    { key = 'm', file = 'multicursor.md', desc = 'マルチカーソル' },
    -- 以下は未作成（将来作成予定）
    -- { key = 's', file = 'search.md', desc = '検索・置換' },
    -- { key = 'l', file = 'lsp.md', desc = 'LSP機能' },
    -- { key = 'g', file = 'git.md', desc = 'Git操作' },
    -- { key = 'd', file = 'debug.md', desc = 'デバッグ' },
    -- { key = 't', file = 'textobj.md', desc = 'テキストオブジェクト' },
    -- { key = 'w', file = 'window.md', desc = 'ウィンドウ・バッファ' },
    -- { key = 'T', file = 'terminal.md', desc = 'ターミナル' },
    -- { key = 'o', file = 'toggle.md', desc = 'トグル機能' },
    -- { key = 'p', file = 'plugins.md', desc = 'プラグイン' },
}

-- プレビュー方法の設定
local preview_method = 'glow'  -- 'glow' or 'markdown_preview'


-- チートシートを表示
local function show_cheatsheet(file)
    local filepath = cheatsheet_dir .. '/' .. file
    if vim.fn.filereadable(filepath) == 1 then
        if preview_method == 'markdown_preview' then
            -- MarkdownPreviewで表示
            vim.cmd('edit ' .. filepath)
            vim.cmd('MarkdownPreview')
        else
            -- Glowで表示（デフォルト）
            vim.cmd('Glow ' .. filepath)
        end
    else
        vim.notify('チートシートが見つかりません: ' .. file, vim.log.levels.WARN)
    end
end

-- チートシートメニューを表示
function ShowCheatsheetMenu()
    -- メニュー用のバッファを作成
    local buf = vim.api.nvim_create_buf(false, true)
    
    -- メニュー内容を構築
    local lines = {
        '📚 Neovim チートシート',
        '========================',
        '',
    }
    
    -- キーの最大長を計算（整列用）
    local max_key_len = 0
    for _, sheet in ipairs(cheatsheets) do
        if #sheet.key > max_key_len then
            max_key_len = #sheet.key
        end
    end
    
    for _, sheet in ipairs(cheatsheets) do
        local padding = string.rep(' ', max_key_len - #sheet.key)
        local line = string.format('  [%s]%s  %s', sheet.key, padding, sheet.desc)
        table.insert(lines, line)
    end
    
    table.insert(lines, '')
    table.insert(lines, '─────────────────────────────────')
    table.insert(lines, string.format('プレビュー: %s', preview_method))
    table.insert(lines, '[p] プレビュー方法切替 / ESC or q で終了')
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    
    -- ウィンドウサイズと位置を計算
    local width = 45  -- 少し広く
    local height = #lines + 2
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)
    
    -- フローティングウィンドウを作成
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = col,
        row = row,
        style = 'minimal',
        border = 'rounded',
        title = ' Cheatsheet Menu ',
        title_pos = 'center',
    })
    
    -- キーマッピングを設定
    for _, sheet in ipairs(cheatsheets) do
        vim.keymap.set('n', sheet.key, function()
            vim.api.nvim_win_close(win, true)
            show_cheatsheet(sheet.file)
        end, { buffer = buf, silent = true })
    end
    
    -- プレビュー方法切替
    vim.keymap.set('n', 'p', function()
        -- プレビュー方法を切り替え
        if preview_method == 'glow' then
            preview_method = 'markdown_preview'
            vim.notify('プレビュー方法: MarkdownPreview', vim.log.levels.INFO)
        else
            preview_method = 'glow'
            vim.notify('プレビュー方法: Glow', vim.log.levels.INFO)
        end
        
        -- メニューを再描画
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        ShowCheatsheetMenu()
    end, { buffer = buf, silent = true })
    
    -- 終了キー
    local close = function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end
    
    vim.keymap.set('n', 'q', close, { buffer = buf, silent = true })
    vim.keymap.set('n', '<ESC>', close, { buffer = buf, silent = true })
end

-- グローバル関数として公開（21_keymap.luaから呼び出し用）
_G.ShowCheatsheetMenu = ShowCheatsheetMenu