-- 環境判定
local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
local is_wsl = vim.fn.has('wsl') == 1
local is_nvim_qt = vim.g.GuiLoaded ~= nil

--- ウガンダ非表示
vim.opt.shortmess:append({ I = true }) -- 行番号表示
vim.opt.number = true
vim.opt.relativenumber = false

--- 現在行をハイライト
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
-- vim.opt.cursorcolumn = false

-- 編集中でもバッファを開く
vim.opt.hidden = true

-- コマンド履歴
vim.opt.history = 10000

-- 上下のスクロールしない高さ
vim.opt.scrolloff = 2
-- 長い行もちゃんと表示
vim.opt.display = 'lastline'


-- 仮想編集できるようにする
vim.opt.virtualedit:append({
    'block',
    'onemore',
})

-- 補完リストをEnterで選択、選択中は挿入されない
vim.opt.completeopt = {
    'menuone',
    'noinsert',
}

-- <BS>キーで全部(字下げや改行)消去できる。
vim.opt.backspace = {
    'indent',
    'eol',
    'start',
}

-- Beep音なし
vim.opt.errorbells = false

-- タブ入力でSpaceに置き換わる
vim.opt.expandtab = true

-- 自動シフトでのシフト量
vim.opt.shiftwidth = 4

-- タブのシフト量
vim.opt.tabstop = 4

-- ワイルドメニュー設定 コマンドラインモードでTAB補完
vim.opt.wildmenu = true
vim.opt.wildmode = {
    'list:longest',
    'full',
}

-- helpは日本語優先
vim.opt.helplang = {
    'ja',
    'en',
}

-- 補完ウィンドウの高さ
vim.opt.pumheight = 10

-- 改行時に前の行のインデントを継続する
vim.opt.autoindent = true

-- 対応する括弧のハイライト有効
vim.opt.showmatch = true

-- マッチする括弧のハイライト時間 *0.1sec
vim.opt.matchtime = 1

-- ファイルエンコーディングの設定
vim.opt.fileencodings = {
    'utf-8',
    'cp932',
    'euc-jp',
    'jis',
}


-- ファイルフォーマットの設定
vim.opt.fileformats = {
    'unix',
    'dos',
    'mac',
}

-- ステータスラインを常に表示２
vim.opt.laststatus = 2

-- runtimepathに行ディレクトリを追加
vim.opt.runtimepath:append(os.getenv('VIM'))


vim.opt.path:append('**')

-- Tab、行末の半角スペース(SpecialKey)の可視化
vim.opt.list = true
vim.opt.listchars = {
    -- tab = [[/^]],
    trail = '~',
    nbsp = '+',
}
--set listchars=tab:^\ ,trail:~

----- Color Syntax ---
-- 背景設定(シンタックス有効にする前)
vim.opt.background = 'dark'

-- True Color 有効
vim.opt.termguicolors = true

--- マウス ---
-- どのモードでもマウスを使えるようにする
vim.opt.mouse = 'a'

-- マウスの移動でフォーカスを自動的に切替えない
vim.opt.mousefocus = false

-- 入力時にマウスポインタを隠さない
vim.opt.mousehide = false
if is_nvim_qt then
    -- ドラッグ&ドロップ処理
    if is_windows then
        vim.cmd([[
            function! OnGuiDrop(files)
                for f in a:files
                    exe 'e ' .. fnamemodify(f, ':p')
                endfor
            endfunction

            command! -nargs=1 GuiDrop :call OnGuiDrop(split(<q-args>, '\n'))
        ]])

        vim.g.GuiDrop = 1
        vim.opt.guioptions = 'a'
    end
end
--- フォント ---
-- GUI用のフォント設定(CUIでは無効)
-- vim.opt.guifont = [[Cica\ 11]]
vim.opt.guifont = is_windows and "Cica:h11" or "Cica\\ 11"
vim.g.WebDevIconsUnicodeDecorateFolderNodes = 1

-- 行間隔の設定
vim.opt.linespace = 1

-- 全角文字の幅
-- vim.opt.ambiwidth = 'double'
vim.opt.ambiwidth = 'single'

-- 置換をインタラクティブに表示
vim.opt.inccommand = 'split'

-- 常にカレントバッファをルートに
vim.opt.autochdir = true

-- クリップボードと連携する
vim.opt.clipboard = is_windows and { 'unnamed' } or { 'unnamedplus', 'unnamed' }

vim.opt.swapfile = false


-- カーソル移動
vim.opt.whichwrap = 'bshl<>[]~]'
--  b - <BS>    ノーマルとビジュアル
--  s - <Space> ノーマルとビジュアル
--  < - <Left>  ノーマルとビジュアル
--  > - <Right> ノーマルとビジュアル
--  ~ - "~"     ノーマル
--  [ - <Left>  挿入と置換
--  ] - <Right> 挿入と置換
--
vim.opt.winblend = 0
vim.opt.pumblend = 0
vim.opt.termguicolors = true

vim.opt.autochdir = true

vim.opt.undofile = true
vim.opt.undolevels = 5000
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 対応括弧を追加
vim.opt.matchpairs:append({
    [[<:>]],
    [[':']],
    [[":"]],
    [[「:」]],
    [[『:』]],
    [[（:）]],
    [[【:】]],
    [[《:》]],
    [[〈:〉]],
    [[［:］]],
})

-- ファイルツリーの表示形式、1にするとls -laのような表示になります
vim.g.netrw_liststyle = 3
-- ヘッダを非表示にする
vim.g.netrw_banner = 1
-- サイズを(K,M,G)で表示する
vim.g.netrw_sizestyle = "H"
-- 日付フォーマットを yyyy/mm/dd(曜日) hh:mm:ss で表示する
vim.g.netrw_timefmt = "%Y/%m/%d %H:%M:%S"
-- プレビューウィンドウを垂直分割で表示する
vim.g.netrw_preview = 1

vim.opt.diffopt:append('vertical')

vim.opt.updatetime = 500
vim.g.incsearch_use_migemo = 0
vim.g.toggle_auto_hover = 0

if vim.g.GuiLoaded then
    -- Neovim-Qt固有の設定
    vim.cmd([[
        " ドラッグ&ドロップを明示的に有効化
        GuiDrop 1

        " ドロップハンドラーの登録
        function! HandleDrop(files)
            for file in a:files
                execute 'edit ' . fnameescape(file)
            endfor
        endfunction

        autocmd User GuiDropped call HandleDrop(deepcopy(v:argv))
    ]])
end

Colorschemes = {
    -- 'tokyonight',
    'tokyonight-moon',
    -- 'tokyonight-night',
    'nordfox',
    -- 'tokyonight-storm',
    'gruvbox',
    -- 'purify',
    'zephyr',
    'habamax',
}
if vim.g.neovide then
    -- フォント設定
    vim.o.guifont = "Cica:h12" -- サイズを少し大きくして見やすく

    -- ウィンドウ設定
    vim.o.lines = 60
    vim.o.columns = 160
    vim.g.neovide_remember_window_size = true

    -- レンダリング設定
    vim.g.neovide_refresh_rate = 60
    vim.g.neovide_refresh_rate_idle = 6

    vim.g.neovide_transparency = 0.9
    vim.g.neovide_scale_factor = 1.0

    -- カーソル設定
    vim.g.neovide_cursor_animation_length = 0.03
    vim.g.neovide_cursor_trail_length = 0.3
    vim.g.neovide_cursor_antialiasing = true

    -- パディング設定
    vim.g.neovide_padding_top = 0
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 0
    vim.g.neovide_padding_left = 0

    -- フォントのシャープネスとアンチエイリアス
    vim.g.neovide_font_hinting = "full"
    vim.g.neovide_font_subpixel_antialiasing = 1.0
    vim.g.neovide_cursor_vfx_mode = "railgun"        -- パーティクルモード
    vim.g.neovide_cursor_vfx_particle_lifetime = 0.5 -- パーティクルの寿命
    vim.g.neovide_cursor_vfx_particle_density = 10.0 -- パーティクルの密度

    -- -- 透明度
    -- vim.g.neovide_transparency = 0.95

    -- フローティングブラー（実験的）
    vim.g.neovide_floating_blur_amount_x = 2.0
    vim.g.neovide_floating_blur_amount_y = 2.0
    -- スクロールアニメーション
    vim.g.neovide_scroll_animation_length = 0.2
    -- フォントの線幅
    vim.g.neovide_cursor_trail_size = 0.8

    -- フォントシャープネス
    vim.g.neovide_font_hinting = "full"
    vim.g.neovide_font_subpixel_antialiasing = 1.0
    -- IMEの設定
    vim.g.neovide_input_ime = true
    vim.g.neovide_input_use_logo = false -- Windowsキーの挙動を制御
    vim.o.iminsert = 0
    vim.o.imsearch = -1

    -- ----------- fold -----------------
    -- vim.opt.foldmethod = 'marker'

    -- -- " 初期はカラムなし
    -- -- set foldcolumn=0

    -- -- カーソル移動以外ではだいたい折り畳みが自動で開くようにする
    -- vim.opt.foldopen = {
    --     'block',
    --     'hor',
    --     'mark',
    --     'percent',
    --     'quickfix',
    --     'search',
    --     'tag',
    --     'undo'
    -- }
    -- vim.opt.foldcolumn = '10'


    -- Treesitterフォールディング関連
    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.opt.foldenable = false -- 起動時はフォールドを開いた状態に
    vim.opt.foldlevel = 99     -- 深いレベルまで開く
    -- fold開く条件
    vim.opt.foldopen = {
        'block',
        'hor',
        'mark',
        'percent',
        'quickfix',
        'search',
        'tag',
        'undo'
    }
end
