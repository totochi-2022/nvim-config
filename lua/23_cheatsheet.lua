-- Cheatsheet System
-- Markdownチートシートの管理と表示

local M = {}

-- チートシートのベースディレクトリ
local cheatsheet_dir = vim.fn.stdpath('config') .. '/lua/cheatsheets'

-- 利用可能なチートシート一覧
local cheatsheets = {
    { key = 'i', file = 'index.md', desc = 'インデックス' },
    { key = 'j', file = 'jump.md', desc = 'ジャンプ・移動' },
    { key = 'v', file = 'selection.md', desc = '選択・ビジュアル' },
    { key = 'f', file = 'fold.md', desc = 'フォールド' },
    { key = 'c', file = 'comment.md', desc = 'コメント操作' },
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

-- Glowでチートシートを表示
function M.show_cheatsheet(file)
    local filepath = cheatsheet_dir .. '/' .. file
    if vim.fn.filereadable(filepath) == 1 then
        vim.cmd('Glow ' .. filepath)
    else
        vim.notify('チートシートが見つかりません: ' .. file, vim.log.levels.WARN)
    end
end

-- チートシートメニューを表示
function M.show_menu()
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
    table.insert(lines, 'キーを押して選択 / ESC or q で終了')
    
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
            M.show_cheatsheet(sheet.file)
        end, { buffer = buf, silent = true })
    end
    
    -- 終了キー
    local close = function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end
    
    vim.keymap.set('n', 'q', close, { buffer = buf, silent = true })
    vim.keymap.set('n', '<ESC>', close, { buffer = buf, silent = true })
end

-- Telescopeでチートシートを検索（オプション）
function M.telescope_cheatsheets()
    local ok, telescope = pcall(require, 'telescope.builtin')
    if not ok then
        vim.notify('Telescopeが見つかりません', vim.log.levels.WARN)
        return
    end
    
    telescope.find_files({
        prompt_title = 'Cheatsheets',
        cwd = cheatsheet_dir,
        previewer = true,
        layout_config = {
            width = 0.9,
            height = 0.9,
        },
    })
end

return M