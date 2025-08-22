--- local value
local noremap = { noremap = true, desc = nil }
-- local remap = { remap = true, desc = nil } -- remapに変更
local keymap = vim.keymap.set

local minor_mode = require('minor-mode')


-- 21_keymap.luaファイルの先頭付近に追加
local notify_level = vim.log.levels.WARN

--- initialize
-- keymap('', 's', '', noremap)  -- which-keyで管理するのでコメントアウト
-- 1. mのデフォルトマッピングを解除
keymap('n', 'm', '', { noremap = true, desc = 'mキー無効化（LSP用に解放）' })

--- set leader, localleader
vim.g.mapleader = 's'
vim.g.maplocalleader = ' '


--- noice cmdline paste support
-- コマンドラインモードでの貼り付けを有効化
keymap('c', '<C-v>', '<C-r>+', { noremap = true, desc = 'コマンドラインで貼り付け' })
keymap('c', '<C-r><C-v>', '<C-r>+', { noremap = true, desc = 'コマンドラインで貼り付け' })
-- 右クリックで貼り付け（noiceコマンドライン用）
keymap('c', '<RightMouse>', '<C-r>+', { noremap = true, desc = '右クリックで貼り付け' })
keymap('c', '<MiddleMouse>', '<C-r>+', { noremap = true, desc = 'マウス中ボタンで貼り付け' })
--

--- split window
keymap('n', '<LocalLeader>vs', ':<C-u>sp<CR>', { noremap = true, desc = '画面を水平分割' })
keymap('n', '<LocalLeader>vv', ':<C-u>vs<CR>', { noremap = true, desc = '画面を垂直分割' })
--

--- undo
keymap('n', '<LocalLeader>u', 'U', { noremap = true, desc = '行の変更を元に戻す' })
keymap('n', 'U', 'g+', { noremap = true, desc = '新しい変更に進む' })
keymap('n', 'u', 'g-', { noremap = true, desc = '前の変更に戻る' })
--

keymap('', '<A-;>', ':', { noremap = true, desc = 'コマンドラインモード' })
--- Windows path conversion (now handled by toggle library)
-- keymap('n', '<LocalLeader>3', '<cmd>lua ToggleAutoWindowsPathMode()<CR>',
--     { noremap = true, desc = '自動Windowsパス変換モードをトグル' })
-- Moved to toggle library
--

--- window
minor_mode.define_mode({
    namespace = 'WindowManagement',
    entries = {
        { key = '<Leader>s', desc = 'ウィンドウ管理モード開始' }
    },
    actions = {
        { key = '|', action = '<C-w>|', desc = '最大幅にする' },
        { key = 'x', action = '<C-w>x', desc = 'カレントと次のウィンドウを入れ替え' },
        { key = 'w', action = '<C-w>w', desc = '次のウィンドウへ移動' },
        { key = 'h', action = '<C-w>h', desc = '左のウィンドウへ移動' },
        { key = 'j', action = '<C-w>j', desc = '下のウィンドウへ移動' },
        { key = 'k', action = '<C-w>k', desc = '上のウィンドウへ移動' },
        { key = 'l', action = '<C-w>l', desc = '右のウィンドウへ移動' },
        { key = 'H', action = '<C-w>H', desc = 'ウィンドウを左に移動' },
        { key = 'J', action = '<C-w>J', desc = 'ウィンドウを下に移動' },
        { key = 'K', action = '<C-w>K', desc = 'ウィンドウを上に移動' },
        { key = 'L', action = '<C-w>L', desc = 'ウィンドウを右に移動' },
        { key = '>', action = '<C-w>>', desc = '横幅を拡大' },
        { key = '<', action = '<C-w><', desc = '横幅を縮小' },
        { key = '+', action = '<C-w>+', desc = '高さを拡大' },
        { key = '-', action = '<C-w>-', desc = '高さを縮小' },
        { key = 'c', action = '<C-w>c', desc = 'ウィンドウを閉じる' },
        { key = 'o', action = '<C-w>o', desc = '他のウィンドウを閉じる' },
        { key = 'r', action = '<C-w>r', desc = 'ウィンドウを下向きに回転' },
        { key = 'R', action = '<C-w>R', desc = 'ウィンドウを上向きに回転' },
        { key = 't', action = 'gt', desc = '次のタブへ移動' },
        { key = 'T', action = '<C-w>T', desc = 'ウィンドウを新しいタブに移動' },
        { key = '=', action = '<C-w>=', desc = 'ウィンドウの高さと幅を均等にする' },
        { key = 'b', action = ':bp<CR>', desc = '前のバッファへ移動' },
        { key = 'B', action = ':bn<CR>', desc = '次のバッファへ移動' },
    }
})
--

--- buffer
minor_mode.define_mode({
    namespace = 'Buffer',
    entries = {
        { key = '<LocalLeader>b', action = ':bp<CR>', desc = '前のバッファへ移動+バッファモード開始' },
        { key = '<LocalLeader>B', action = ':bn<CR>', desc = '次のバッファへ移動+バッファモード開始' }
    },
    actions = {
        { key = 'b', action = ':bp<CR>', desc = '前のバッファへ移動' },
        { key = 'B', action = ':bn<CR>', desc = '次のバッファへ移動' },
    }
})
--

--- tab
-- minor_mode.create('Tab', '<LocalLeader>').set('t', 'gt', '次のタブへ移動')  -- 翻訳機能と競合するため削除
keymap('', '<LocalLeader>T', '<C-W>T', { noremap = true, desc = 'ウィンドウを新しいタブに移動' })

-- NERDCommenter
keymap('n', '<LocalLeader>c', '<Plug>NERDCommenterToggle', { noremap = true, desc = 'コメントのトグル' })
keymap('x', '<LocalLeader>c', '<Plug>NERDCommenterToggle', { noremap = true, desc = 'コメントのトグル' })
keymap('n', '<LocalLeader>Cn', '<Plug>NERDCommenterNested', { noremap = true, desc = 'ネストしたコメント' })
keymap('x', '<LocalLeader>Cn', '<Plug>NERDCommenterNested', { noremap = true, desc = 'ネストしたコメント' })
keymap('n', '<LocalLeader>Cu', '<Plug>NERDCommenterUncomment', { noremap = true, desc = 'コメント解除' })
keymap('x', '<LocalLeader>Cu', '<Plug>NERDCommenterUncomment', { noremap = true, desc = 'コメント解除' })
keymap('n', '<LocalLeader>CC', '<Plug>NERDCommenterComment', { noremap = true, desc = 'コメント追加' })
keymap('x', '<LocalLeader>CC', '<Plug>NERDCommenterComment', { noremap = true, desc = 'コメント追加' })
keymap('x', '<LocalLeader>Cs', '<Plug>NERDCommenterInvert', { noremap = true, desc = 'コメント反転' })
keymap('n', '<LocalLeader>Ci', '<Plug>NERDCommenterToEOL', { noremap = true, desc = '行末までコメント' })
keymap('n', '<LocalLeader>CA', '<Plug>NERDCommenterAppend', { noremap = true, desc = '行末にコメント追加' })
keymap('x', '<LocalLeader>CA', '<Plug>NERDCommenterAppend', { noremap = true, desc = '行末にコメント追加' })
keymap('n', '<LocalLeader>Cy', '<Plug>NERDCommenterYank', { noremap = true, desc = 'コメントをヤンク' })
keymap('x', '<LocalLeader>Cy', '<Plug>NERDCommenterYank', { noremap = true, desc = 'コメントをヤンク' })
keymap('n', '<LocalLeader>Cp', '<Plug>NERDCommenterAppend <ESC> p', { noremap = true, desc = 'コメント追加してペースト' })

--- [;] [:] replace
keymap('', ':', ';', { noremap = true, desc = 'セミコロン' })
keymap('n', '<Leader>;', ':', { noremap = true, desc = 'コマンド入力' })
keymap('n', 'q;', 'q:', { noremap = true, desc = 'コマンド履歴' })
keymap('n', '<LocalLeader>;', ':<C-u>Capture :', { noremap = true, desc = 'コマンド出力をキャプチャ' })
keymap('n', ';', '<cmd>FineCmdline<CR>', { noremap = true, desc = '洗練されたコマンドライン' })
keymap('x', ';', [[:<C-u>FineCmdline '<,'><CR>]], { noremap = true, desc = '選択範囲に対するコマンド' })

--- <Leader>
keymap('', '<Leader>b', ':Telescope buffers<CR>', { noremap = true, desc = 'バッファ一覧' })
keymap('', '<F3>', ':Telescope command_palette<CR>', { noremap = true, desc = 'コマンドパレット' })
keymap('', '<Leader>h', ':Telescope frecency<CR>', { noremap = true, desc = '最近使用したファイル（頻度順）' })
keymap('', '<Leader>H', ':Telescope oldfiles<CR>', { noremap = true, desc = '最近使用したファイル（時間順）' })
keymap('', '<Leader>R', ':Telescope registers<CR>', { noremap = true, desc = 'レジスタ一覧' })

-- grug-far.nvim 検索・置換
keymap('n', '<Leader>r', ':GrugFarCurrentBuffer<CR>', { noremap = true, desc = '現在のバッファで検索・置換' })
keymap('v', '<Leader>r', ':GrugFarCurrentWord<CR>', { noremap = true, desc = 'カーソル下の単語を現在のバッファで検索' })
keymap('', '<Leader>k', ':Telescope keymaps<CR>', { noremap = true, desc = 'キーマップ一覧' })
keymap('', '<Leader><F1>', ':Telescope help_tags<CR>', { noremap = true, desc = 'ヘルプタグ検索' })
keymap('', '<Leader><F2>', ':Telescope man_pages<CR>', { noremap = true, desc = 'マニュアルページ検索' })
keymap('', '<Leader>m', ':Telescope marks', { noremap = true, desc = 'マーク一覧' })
keymap('', '<Leader>A', ':Telescope lsp_<Tab>', { noremap = true, desc = 'LSP機能一覧' })
keymap('', '<Leader>g', ':Telescope egrepify<CR>', { noremap = true, desc = 'テキスト検索（正規表現）' })
keymap('', '<Leader>G', ':Telescope live_grep<CR>', { noremap = true, desc = 'テキスト検索（Grep）' })
keymap('', '<Leader>a', ':Telescope<CR>', { noremap = true, desc = 'Telescopeセレクタ' })
keymap('', '<Leader>q', ':Telescope quickfix<CR>', { noremap = true, desc = 'クイックフィックス一覧' })
keymap('', '<Leader>Q', ':Telescope quickfixhistory<CR>', { noremap = true, desc = 'クイックフィックス履歴' })
keymap('', '<Leader>i', ':Telescope ghq list<CR>', { noremap = true, desc = 'ghqリポジトリ一覧' })
keymap('', '<Leader>d', ':Telescope diagnostics<CR>', { noremap = true, desc = '診断一覧' })
keymap('', '<Leader>f', ':Telescope fd<CR>', { noremap = true, desc = 'ファイル検索' })
keymap('', '<Leader>e', ':Telescope file_browser path=%:p:h<CR>', { noremap = true, desc = 'ファイルブラウザ（現在のディレクトリ）' })
keymap('', '<Leader>J', ':Telescope jumplist<CR>', { noremap = true, desc = 'ジャンプリスト' })
keymap('', '<Leader>c', ':Telescope highlights<CR>', { noremap = true, desc = 'ハイライトグループ一覧' })
keymap('', '<Leader>S', ':SearchSession<CR>', { noremap = true, desc = 'セッション検索' })
keymap('n', '<Leader>u', ':Telescope undo<CR>', { noremap = true, desc = '変更履歴（Telescope）' })
keymap('n', '<Leader>t', ':terminal<CR>', { noremap = true, desc = 'ターミナル起動' })

--- inc dec
keymap('n', '-', '<C-X>', { noremap = true, desc = '数値デクリメント' })
keymap('n', '+', '<C-A>', { noremap = true, desc = '数値インクリメント' })

--- save, quit, reload ---
keymap('', '<LocalLeader>w', ':w<CR>', { noremap = true, desc = '上書き保存' })
keymap('', '<LocalLeader>W', ':w!<CR>', { noremap = true, desc = '強制上書き保存' })
keymap('', '<LocalLeader>q', ':q<CR>', { noremap = true, desc = '終了' })
keymap('', '<LocalLeader>Q', ':q!<CR>', { noremap = true, desc = '強制終了' })
keymap('', '<LocalLeader>e', ':e!<CR>', { noremap = true, desc = '再読み込み' })
keymap('', '<LocalLeader>E', ':e .<CR>', { noremap = true, desc = 'カレントディレクトリを開く' })
--

-- WhichKey 関連（<LocalLeader><F1>をヘルプキーとして使用）
keymap('n', '<LocalLeader><F1><F1>', ':WhichKey<CR>', { noremap = true, desc = '全キーマップのヘルプ' })
-- Ctrl/Altキーのヘルプ（初期検索語付き - 連続文字検索用）
keymap('n', '<LocalLeader><F1>c', '<cmd>Telescope keymaps<CR>i<C-u><C-', { noremap = true, desc = 'Ctrlキーのヘルプ（<C- 検索）' })
keymap('n', '<LocalLeader><F1>a', '<cmd>Telescope keymaps<CR>i<C-u><M-', { noremap = true, desc = 'Altキーのヘルプ（<M- 検索）' })
keymap('n', '<LocalLeader><F1>w', ':WhichKey "<C-w>"<CR>', { noremap = true, desc = 'ウィンドウ操作のヘルプ' })
keymap('n', '<LocalLeader><F1>s', ':WhichKey s<CR>', { noremap = true, desc = 'Leader(s)キーのヘルプ' })
keymap('n', '<LocalLeader><F1><Space>', ':WhichKey "<Space>"<CR>', { noremap = true, desc = 'LocalLeader(Space)キーのヘルプ' })

-- カレントディレクトリ関連
keymap('n', '<F8>E', ':!explorer.exe .<CR>', { noremap = true, desc = 'エクスプローラでカレントディレクトリを開く' })
keymap('n', '<F8>e', ':!tabe<CR>', { noremap = true, desc = '新しいタブで開く' })
keymap('n', '<F8>x', ':<C-u>TerminalCurrentDir<CR><CR>', { noremap = true, desc = 'ターミナルでカレントディレクトリを開く' })
keymap('n', '<F8>s', ':Lazy sync<CR>', { noremap = true, desc = 'プラグイン同期' })
keymap('n', '<F8>l', ':Lazy<CR>', { noremap = true, desc = 'Lazy起動' })
keymap('n', '<F8>c', ':Lazy clean<CR>', { noremap = true, desc = 'プラグインクリーン' })
keymap('n', '<F8>u', ':Lazy update<CR>', { noremap = true, desc = 'プラグイン更新' })
keymap('n', '<F8>m', ':Mason<CR>', { noremap = true, desc = 'Mason（LSP管理）を開く' })
keymap('n', '<F8>t', ':TSUpdate<CR>', { noremap = true, desc = 'Treesitter更新' })
-- カラースキーム変更のminor mode
minor_mode.define_mode({
    namespace = 'ColorScheme',
    entries = {
        { key = '<F8>r', action = '<cmd>lua RandomScheme()<CR>', desc = 'ランダムカラースキーム+カラーモード開始' }
    },
    actions = {
        { key = 'r', action = '<cmd>lua RandomScheme()<CR>', desc = 'ランダムカラースキーム' },
    }
})

-- LSP関連（ファイルタイプ固有セクションに移動）

-- 行移動関連
keymap('', '<LocalLeader>h', '^', { noremap = true, desc = '行の先頭へ' })
keymap('', '<LocalLeader>l', '$', { noremap = true, desc = '行の末尾へ' })

-- レジスタ関連
keymap('', '<LocalLeader>y', ':let @q = @*<CR>', { noremap = true, desc = 'クリップボードをレジスタqにコピー' })
keymap('', '<LocalLeader>p', '"qp', { noremap = true, desc = 'レジスタqをペースト（後）' })
keymap('', '<LocalLeader>P', '"qP', { noremap = true, desc = 'レジスタqをペースト（前）' })

-- 検索関連
keymap('', '<LocalLeader>/', '<Plug>(asterisk-z*)', { noremap = true, desc = 'カーソル位置の単語を検索' })
keymap('', [[<LocalLeader>']], '%', { noremap = true, desc = '対応する括弧へジャンプ' })

-- ターミナルモード
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = 'ノーマルモードへ' })

-- 改行コード変更
keymap('n', 'ml', [[:%s/\r//g<CR>]], { noremap = true, desc = 'CRを削除（改行コード変換）' })
keymap('v', 'ml', [[:s/\r//g]], { noremap = true, desc = '選択範囲のCRを削除' })

-- 行移動
keymap('n', '<C-Down>', [["zdd"zp]], { noremap = true, desc = '行を下に移動' })
keymap('n', '<C-Up>', [["zdd<Up>"zP]], { noremap = true, desc = '行を上に移動' })
keymap('x', '<C-Up>', '"zx<Up>"zP`[V`]', { noremap = true, desc = '選択行を上に移動' })
keymap('x', '<C-Down>', '"zx"zp`[V`]', { noremap = true, desc = '選択行を下に移動' })

-- デバッグUI関連
keymap('n', '<LocalLeader>d', ':lua require("dapui").toggle()<CR>', { noremap = true, desc = 'デバッグUIトグル' })

-- ディレクトリ関連
keymap('', '<LocalLeader>r', ':RooterToggle<CR>', { noremap = true, desc = 'プロジェクトルート自動変更トグル' })

-- 文字列変換
minor_mode.define_mode({
    namespace = 'ConvertCase',
    entries = {
        { key = '<LocalLeader>k', action = ':ConvertCaseLoop<CR>', desc = '文字列の大文字小文字変換' }
    },
    actions = {
        { key = 'k', action = ':ConvertCaseLoop<CR>', desc = '文字列の大文字小文字変換' },
    }
})

-- テキスト領域拡張モード
minor_mode.define_mode({
    namespace = 'ExpandRegion',
    entries = {
        { key = '<LocalLeader>j', action = '<Plug>(expand_region_expand)', desc = 'テキスト選択範囲を広げる' }
    },
    actions = {
        { key = 'j', action = '<Plug>(expand_region_expand)', desc = '選択範囲を広げる' },
        { key = 'J', action = '<Plug>(expand_region_shrink)', desc = '選択範囲を狭める' },
        { key = 'k', action = '<Plug>(expand_region_shrink)', desc = '選択範囲を狭める' },
    },
    options = {
        mode = { 'n', 'x' } -- ノーマルモードとビジュアルモード対応
    }
})

-- 翻訳
keymap('x', '<LocalLeader>t', '<cmd>Translate<CR>', { noremap = true, desc = '選択テキストを翻訳' })
keymap('n', '<LocalLeader>t', '<cmd>Translate<CR>', { noremap = true, desc = 'カーソル下の単語を翻訳' })

-- EasyAlign
keymap('', 'ga', '<plug>(EasyAlign)', { remap = true, desc = 'テキスト整列' })

keymap('n', '<Leader>j', ':<C-u>OpenJunkfile<CR>', { noremap = true, desc = 'Junkファイルを開く' })
-- Dial.nvim（数値・文字列増減）
keymap('n', '+', function()
    require("dial.map").manipulate("increment", "normal")
end, { noremap = true, desc = '数値・文字列を増加' })

keymap('n', '-', function()
    require("dial.map").manipulate("decrement", "normal")
end, { noremap = true, desc = '数値・文字列を減少' })

keymap('v', '+', function()
    require("dial.map").manipulate("increment", "visual")
end, { noremap = true, desc = '数値・文字列を増加（ビジュアル）' })

keymap('v', '-', function()
    require("dial.map").manipulate("decrement", "visual")
end, { noremap = true, desc = '数値・文字列を減少（ビジュアル）' })

keymap('v', 'g+', function()
    require("dial.map").manipulate("increment", "gvisual")
end, { noremap = true, desc = '数値・文字列を連続増加' })

keymap('v', 'g-', function()
    require("dial.map").manipulate("decrement", "gvisual")
end, { noremap = true, desc = '数値・文字列を連続減少' })

-- EasyMotion
keymap('n', '<LocalLeader><Space>', '<Plug>(easymotion-overwin-f2)', { noremap = true, desc = '2文字で画面内ジャンプ' })
keymap('x', '<LocalLeader><Space>', '<Plug>(easymotion-bd-f2)', { noremap = true, desc = '2文字でジャンプ' })

-- VisualModeトグル
keymap('v', 'v', ':<C-u>VmodeToggle<CR>', { noremap = true, desc = 'ビジュアルモード切替' })

-- Shift+矢印選択
keymap('n', '<S-Up>', 'v<Up>', { noremap = true, desc = '上に選択' })
keymap('n', '<S-Down>', 'v<Down>', { noremap = true, desc = '下に選択' })
keymap('n', '<S-Left>', 'v<Left>', { noremap = true, desc = '左に選択' })
keymap('n', '<S-Right>', 'v<Right>', { noremap = true, desc = '右に選択' })
keymap('x', '<S-Up>', '<Up>', { noremap = true, desc = '選択を上に拡張' })
keymap('x', '<S-Down>', '<Down>', { noremap = true, desc = '選択を下に拡張' })
keymap('x', '<S-Left>', '<Left>', { noremap = true, desc = '選択を左に拡張' })
keymap('x', '<S-Right>', '<Right>', { noremap = true, desc = '選択を右に拡張' })

-- Yanky
keymap('n', 'p', '<Plug>(YankyPutAfter)', { noremap = true, desc = 'ヤンク後にペースト' })
keymap('n', 'P', '<Plug>(YankyPutBefore)', { noremap = true, desc = 'ヤンク前にペースト' })
keymap('n', 'gp', '<Plug>(YankyGPutAfter)', { noremap = true, desc = 'ヤンク後にペースト＆カーソル移動' })
keymap('n', 'gP', '<Plug>(YankyGPutBefore)', { noremap = true, desc = 'ヤンク前にペースト＆カーソル移動' })
keymap('n', '<c-n>', '<Plug>(YankyCycleForward)', { noremap = true, desc = 'ヤンク履歴を次へ' })
keymap('n', '<c-p>', '<Plug>(YankyCycleBackward)', { noremap = true, desc = 'ヤンク履歴を前へ' })

-- Asterisk
keymap('', '*', '<Plug>(asterisk-z*)', { remap = true, desc = 'カーソル位置の単語を検索' })
keymap('', 'g*', '<Plug>(asterisk-gz*)', { remap = true, desc = '部分一致検索' })
keymap('', 'g#', '<Plug>(asterisk-gz#)', { remap = true, desc = '逆方向部分一致検索' })

-- Markdown Preview（ファイルタイプ固有セクションに移動）

-- Git操作
keymap('n', 'mgs', ':Git<CR>', { noremap = true, desc = 'Git status' })
keymap('n', 'mgd', ':Gdiffsplit<CR>', { noremap = true, desc = 'Git diff split' })
keymap('n', 'mgD', ':DiffviewFileHistory %<CR>', { noremap = true, desc = 'ファイル履歴' })
keymap('n', 'mgb', ':Git blame<CR>', { noremap = true, desc = 'Git blame' })
keymap('n', 'mgl', ':Git log --oneline<CR>', { noremap = true, desc = 'Git log' })
keymap('n', 'mgp', ':Gitsigns preview_hunk<CR>', { noremap = true, desc = 'Hunkプレビュー' })
keymap('n', 'mgr', ':Gitsigns reset_hunk<CR>', { noremap = true, desc = 'Hunkリセット' })
keymap('n', 'mgh', ':Gitsigns stage_hunk<CR>', { noremap = true, desc = 'Hunkステージ' })
keymap('n', 'mgc', ':Gitsigns toggle_current_line_blame<CR>', { noremap = true, desc = 'Blame表示トグル' })

-- Git Hunk移動（submode付き）
minor_mode.define_mode({
    namespace = 'GitHunk',
    entries = {
        { key = 'mgj', action = ':Gitsigns next_hunk<CR>', desc = '次のHunkへ+Hunkモード開始' },
        { key = 'mgk', action = ':Gitsigns prev_hunk<CR>', desc = '前のHunkへ+Hunkモード開始' }
    },
    actions = {
        { key = 'j', action = ':Gitsigns next_hunk<CR>', desc = '次のHunkへ' },
        { key = 'k', action = ':Gitsigns prev_hunk<CR>', desc = '前のHunkへ' },
    }
})

-- ハイライト
keymap('n', '<LocalLeader>x', '<Plug>(quickhl-manual-this)', { noremap = true, desc = 'カーソル位置の単語をハイライト' })
keymap('n', '<LocalLeader>X', '<Plug>(quickhl-manual-reset)', { noremap = true, desc = 'ハイライトをリセット' })
keymap('x', '<LocalLeader>x', '<Plug>(quickhl-manual-this)', { noremap = true, desc = '選択範囲をハイライト' })
keymap('x', '<LocalLeader>X', '<Plug>(quickhl-manual-reset)', { noremap = true, desc = 'ハイライトをリセット' })

-- Insert Mode
keymap('i', '<c-s>', '<c-v>', { noremap = true, desc = '文字コード入力' })
keymap('i', '<s-CR>', '<br>', { noremap = true, desc = 'HTML改行タグ' })
keymap('i', 'jj', '<ESC>', { noremap = true, desc = 'ESCショートカット' })
keymap('i', 'ｊｊ', '<ESC>', { noremap = true, desc = 'ESCショートカット（全角）' })

-- マーク関連
keymap('n', '<LocalLeader>m', ':<C-u>MarksToggleSigns<CR>', { noremap = true, desc = 'マーク表示切替' })
keymap('n', 'mm', '<Plug>(Marks-toggle)', { noremap = true, desc = 'マークをトグル' })

-- ブラウザ関連
keymap('n', 'mA', '<Plug>(openbrowser-smart-search)', { noremap = true, desc = 'ブラウザで検索' })
keymap('x', 'mA', '<Plug>(openbrowser-smart-search)', { noremap = true, desc = '選択テキストをブラウザで検索' })
keymap('n', 'ma', '<Plug>(openbrowser-open)', { noremap = true, desc = 'ブラウザでURLを開く' })
keymap('x', 'ma', '<Plug>(openbrowser-open)', { noremap = true, desc = '選択URLをブラウザで開く' })

-- ISwap
keymap('n', 'ms', ':ISwapWith<CR>', { noremap = true, desc = '引数/要素を交換' })
keymap('n', 'mS', ':ISwap<CR>', { noremap = true, desc = '引数/要素を選択して交換' })

-- QuickRun
keymap('n', 'mnn', ':Jaq<CR>', { noremap = true, desc = 'Jaq実行（デフォルト）' })
keymap('n', 'mnf', ':Jaq float<CR>', { noremap = true, desc = 'Jaq実行（フロート）' })
keymap('n', 'mnb', ':Jaq bang<CR>', { noremap = true, desc = 'Jaq実行（Bang）' })
keymap('n', 'mnq', ':Jaq quickfix<CR>', { noremap = true, desc = 'Jaq実行（クイックフィックス）' })
keymap('n', 'mnt', ':Jaq terminal<CR>', { noremap = true, desc = 'Jaq実行（ターミナル）' })
keymap('n', 'mnr', ':QuickRun<CR>', { noremap = true, desc = 'QuickRun実行' })

-- チートシート
keymap('n', '<LocalLeader>?', function()
    require('23_cheatsheet').show_menu()
end, { noremap = true, silent = true, desc = 'チートシートメニュー' })
keymap('n', 'mnk', ':call quickrun#session#sweep()<CR>', { noremap = true, desc = 'QuickRunセッション終了' })

-- エラージャンプモード（新しいdefine_complete_mode使用）
local minor_mode = require('minor-mode')

-- 新しいdefine_modeを使用
minor_mode.define_mode({
    namespace = 'DIAGNOSTIC',
    entries = {
        { key = 'mo', action = '<cmd>lua vim.diagnostic.goto_next()<CR>', desc = '次の診断へジャンプ+モード開始' },
        { key = 'mi', action = '<cmd>lua vim.diagnostic.goto_prev()<CR>', desc = '前の診断へジャンプ+モード開始' }
    },
    actions = {
        { key = 'o', action = '<cmd>lua vim.diagnostic.goto_next()<CR>', desc = '次の診断（全種類）' },
        { key = 'i', action = '<cmd>lua vim.diagnostic.goto_prev()<CR>', desc = '前の診断（全種類）' },
        { key = 'p', action = '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>', desc = '前のERROR' },
        { key = 'n', action = '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>', desc = '次のERROR' },
        { key = '<', action = '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.INFO})<CR>', desc = '前のINFO' },
        { key = '>', action = '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.INFO})<CR>', desc = '次のINFO' },
        { key = 'j', action = '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})<CR>', desc = '前のWARN' },
        { key = 'k', action = '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})<CR>', desc = '次のWARN' },
        { key = ',', action = '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.HINT})<CR>', desc = '前のHINT' },
        { key = '.', action = '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.HINT})<CR>', desc = '次のHINT' },
    },
    hooks = {
        enter = DiagModeEnter, -- 03_function.luaで定義されたグローバル関数を参照
        exit = DiagModeExit    -- 03_function.luaで定義されたグローバル関数を参照
    },
    options = {
        persistent = true
        -- exit_keys は デフォルトで {'<Esc>', 'q'} が設定される
        -- show_help_key は デフォルトで '?' が設定される
    }
})


-- 構文情報
keymap('n', '<LocalLeader>1', ':SyntaxInfoEnhanced<CR>', { noremap = true, desc = '詳細構文情報表示' })

-- その他設定
-- Moved to toggle library
keymap('n', '<Leader><Space>', '<C-W>p', { noremap = true, desc = '前のウィンドウに移動' })

--- Toggle Library Integration
-- Load toggle configuration (automatically registers minor_mode mappings)
-- require('12_toggle') -- 番号順で自動読み込みされるのでコメントアウト

-- トグル設定
-- <LocalLeader>0 でトグルメニュー
vim.keymap.set('n', '<LocalLeader>0', function()
    require("toggle-manager").show_toggle_menu()
end, { noremap = true, silent = true, desc = '統合トグルメニュー' })

--- Noice.nvim キーマップ
-- コマンドライン
keymap('', ';', ':', { noremap = true, desc = 'コマンドラインモード' })
keymap('n', '<LocalLeader>nn', '<cmd>Noice<CR>', { noremap = true, desc = 'Noice メイン画面' })
keymap('n', '<LocalLeader>nl', '<cmd>lua require("noice").cmd("last")<CR>', { noremap = true, desc = '最後のメッセージ表示' })
keymap('n', '<LocalLeader>nh', '<cmd>lua require("noice").cmd("history")<CR>', { noremap = true, desc = 'メッセージ履歴' })
keymap('n', '<LocalLeader>nd', '<cmd>lua require("noice").cmd("dismiss")<CR>', { noremap = true, desc = '通知を消す' })
keymap('n', '<LocalLeader>ne', '<cmd>lua require("noice").cmd("errors")<CR>', { noremap = true, desc = 'エラーメッセージ' })

--

--- Dropbar.nvim キーマップ
-- ドロップバーの選択
-- keymap('n', '<LocalLeader>1', '<cmd>lua require("dropbar.api").pick()<CR>', { noremap = true, desc = 'Dropbar 選択' })  -- dropbar無効化のためコメントアウト
-- Toggle menuの<LocalLeader>1は上部のトグル設定セクションに移動済み
--


-- ナビゲーション
keymap('n', '<C-,>', '<Plug>(milfeulle-prev)', { noremap = true, desc = '前の位置に移動' })
keymap('n', '<C-.>', '<Plug>(milfeulle-next)', { noremap = true, desc = '次の位置に移動' })
keymap('', '<C-j>', '<Plug>(edgemotion-j)', { desc = '下の空行へ移動' })
keymap('', '<C-k>', '<Plug>(edgemotion-k)', { desc = '上の空行へ移動' })

-- TreeSitter関連
keymap('o', 'iu', ':<c-u>lua require"treesitter-unit".select()<CR>', { noremap = true, desc = 'TS:ユニット内選択（操作）' })
keymap('o', 'au', ':<c-u>lua require"treesitter-unit".select(true)<CR>', { noremap = true, desc = 'TS:ユニット全体選択（操作）' })

-- LSPコマンド（LspAttachイベントでバッファローカルに設定するため移動）
-- Telescope版のLSPナビゲーション（全体で使用）
keymap('n', 'md', '<cmd>Telescope lsp_definitions<CR>', { noremap = true, desc = '定義一覧（Telescope）' })
keymap('n', 'mD', '<cmd>Telescope lsp_declarations<CR>', { noremap = true, desc = '宣言一覧（Telescope）' })
keymap('n', 'mt', '<cmd>Telescope lsp_type_definitions<CR>', { noremap = true, desc = '型定義一覧（Telescope）' })
keymap('n', 'mrr', '<cmd>Telescope lsp_references<CR>', { noremap = true, desc = '参照一覧（Telescope）' })
keymap('n', 'mra', '<cmd>Telescope lsp_code_actions<CR>', { noremap = true, desc = 'コードアクション（Telescope）' })
keymap('n', 'mri', '<cmd>Telescope lsp_implementations<CR>', { noremap = true, desc = '実装一覧（Telescope）' })
keymap('n', 'mO', '<cmd>Telescope lsp_document_symbols<CR>', { noremap = true, desc = 'ドキュメントシンボル（Telescope）' })
keymap('n', 'mS', '<cmd>Telescope lsp_workspace_symbols<CR>', { noremap = true, desc = 'ワークスペースシンボル（Telescope）' })

-- 診断移動は上記のDIAGNOSTICモードで統一（削除）

-- 単語置換関連
keymap('n', 'ciy', 'ciw<C-R>0<ESC><Right>', { noremap = true, desc = '単語をヤンク内容に置換' })
keymap('n', 'ciY', 'ciW<C-R>0<ESC><Right>', { noremap = true, desc = '大きな単語をヤンク内容に置換' })

-- 日本語入力関連
keymap('n', 'あ', 'a', { noremap = true, desc = '後に挿入（日本語）' })
keymap('n', 'い', 'i', { noremap = true, desc = '前に挿入（日本語）' })

-- 追加キーマップ

-- レジスタ関連
keymap('', '<LocalLeader>y', ':let @q = @*<CR>', { noremap = true, desc = 'クリップボードをレジスタqにコピー' })

-- ターミナル関連
if is_windows then
    -- PowerShell用の設定
    keymap('t', '<Esc>', [[<C-\><C-n>]], { desc = 'ノーマルモードへ' })
    keymap('t', '<C-w>', [[<C-\><C-n><C-w>]], { desc = 'ウィンドウ操作' })
end

-- アウトライン表示
keymap('n', '<Leader>o', ':Outline<CR>', { noremap = true, desc = 'アウトライン表示' })

-- フォールディング関連のキーマップ
minor_mode.define_mode({
    namespace = 'Fold',
    entries = {
        { key = 'za', action = 'za', desc = 'フォールドトグル+フォールドモード開始' }
    },
    actions = {
        { key = 'a', action = 'za', desc = '現在のフォールドをトグル' },
        { key = 'R', action = 'zR', desc = 'すべてのフォールドを開く' },
        { key = 'M', action = 'zM', desc = 'すべてのフォールドを閉じる' },
        { key = 'r', action = 'zr', desc = 'フォールドレベルを1段階開く' },
        { key = 'm', action = 'zm', desc = 'フォールドレベルを1段階閉じる' },
        { key = 'j', action = 'zj', desc = '次のフォールドへ' },
        { key = 'k', action = 'zk', desc = '前のフォールドへ' },
        { key = 'x', action = 'zx', desc = 'フォールドを更新して再適用' },
        { key = '0', action = '<cmd>lua SetFoldLevel(0)<CR>', desc = 'フォールドレベル0に設定' },
        { key = '1', action = '<cmd>lua SetFoldLevel(1)<CR>', desc = 'フォールドレベル1に設定' },
        { key = '2', action = '<cmd>lua SetFoldLevel(2)<CR>', desc = 'フォールドレベル2に設定' },
        { key = '3', action = '<cmd>lua SetFoldLevel(3)<CR>', desc = 'フォールドレベル3に設定' },
        { key = '4', action = '<cmd>lua SetFoldLevel(4)<CR>', desc = 'フォールドレベル4に設定' },
    }
})


-- 重複：TreeSitter Hopperはプラグイン用セクションで設定済み


-- デバッグ用のキーマップ（F7をプレフィックスとして使用）
minor_mode.define_mode({
    namespace = 'Debugger',
    entries = {
        { key = '<F7>', desc = 'デバッグモード開始' }
    },
    actions = {
        { key = 'b', action = '<cmd>lua require("dap").toggle_breakpoint()<CR>', desc = 'ブレークポイントをトグル' },
        { key = 'B', action = '<cmd>lua require("dap").set_breakpoint(vim.fn.input("条件付きブレークポイント: "))<CR>', desc = '条件付きブレークポイント設定' },
        { key = 'c', action = '<cmd>lua require("dap").continue()<CR>', desc = '実行継続' },
        { key = 'i', action = '<cmd>lua require("dap").step_into()<CR>', desc = 'ステップイン' },
        { key = 'o', action = '<cmd>lua require("dap").step_over()<CR>', desc = 'ステップオーバー' },
        { key = 'O', action = '<cmd>lua require("dap").step_out()<CR>', desc = 'ステップアウト' },
        { key = 'r', action = '<cmd>lua require("dap").repl.open()<CR>', desc = 'REPL表示' },
        { key = 'l', action = '<cmd>lua require("dap").run_last()<CR>', desc = '最後の実行を再開' },
        { key = 'u', action = '<cmd>lua require("dapui").toggle()<CR>', desc = 'デバッグUIトグル' },
        { key = 't', action = '<cmd>lua require("dap").terminate()<CR>', desc = '終了' },
        { key = 'w', action = '<cmd>lua require("dap.ui.widgets").hover()<CR>', desc = '変数情報表示' },
        { key = 's', action = '<cmd>lua local widgets=require("dap.ui.widgets");widgets.centered_float(widgets.scopes)<CR>', desc = 'スコープ表示' },
    }
})

-- 言語別のデバッグ用キーマップ
-- Python用
minor_mode.define_mode({
    namespace = 'PythonDebug',
    entries = {
        { key = '<F7>p', desc = 'Pythonデバッグモード開始' }
    },
    actions = {
        { key = 'r', action = '<cmd>lua require("dap").run_last()<CR>', desc = '最後の実行を再開' },
        { key = 'd', action = '<cmd>lua require("dap-python").debug_selection()<CR>', desc = '選択範囲をデバッグ' },
        { key = 't', action = '<cmd>lua require("dap-python").test_method()<CR>', desc = 'テストメソッド実行' },
        { key = 'c', action = '<cmd>lua require("dap-python").test_class()<CR>', desc = 'テストクラス実行' },
    }
})

-- Rust用
minor_mode.define_mode({
    namespace = 'RustDebug',
    entries = {
        { key = '<F7>r', desc = 'Rustデバッグモード開始' }
    },
    actions = {
        { key = 'r', action = '<cmd>lua require("dap").run_last()<CR>', desc = '最後の実行を再開' },
        { key = 'm', action = '<cmd>lua require("dap").run_to_cursor()<CR>', desc = 'カーソル位置まで実行' },
    }
})

--- プラグイン用キーマップ (遅延読み込み対応)
-- Claude Code
keymap('n', 'mz', '<cmd>ClaudeCode<cr>', { desc = "Toggle Claude" })
keymap('v', 'mx', '<cmd>ClaudeCodeSend<cr>', { desc = "Send to Claude" })

-- TreeSitter Hopper
keymap('o', '<LocalLeader>s', '<cmd>lua require("tsht").nodes()<CR>', { desc = "TreeSitter hop (operator)" })
keymap('x', '<LocalLeader>s', '<cmd>lua require("tsht").nodes()<CR>', { desc = "TreeSitter hop (visual)" })
keymap('n', '<LocalLeader>s', '<cmd>lua require("tsht").nodes()<CR>', { desc = "TreeSitter hop (normal)" })

-- which-key
keymap('n', '<leader>w', function()
    require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })
--

--- ファイルタイプ固有キーマップ

-- Markdown固有
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        keymap('n', 'mp', '<Plug>MarkdownPreviewToggle', { buffer = true, noremap = false, desc = 'Markdownプレビュートグル' })
    end,
})

-- Fish固有
vim.api.nvim_create_autocmd("FileType", {
    pattern = "fish",
    callback = function()
        keymap('n', 'mf', function()
            vim.cmd('%!fish_indent')
        end, { buffer = true, noremap = true, desc = 'Fishフォーマット' })
    end,
})

-- LSP有効時のキーマップ
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local opts = { buffer = event.buf, noremap = true }

        -- フォーマット（mfがFish用と重複するが、Fishファイルではfish_indentが優先される）
        keymap('n', 'mf', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>',
            vim.tbl_extend('force', opts, { desc = 'LSPフォーマット' }))

        -- その他のLSPキーマップ
        keymap('n', 'm<Space>', '<cmd>lua vim.lsp.buf.hover()<CR>',
            vim.tbl_extend('force', opts, { desc = 'ホバー情報表示' }))
        keymap('n', 'mh', '<cmd>lua vim.lsp.buf.signature_help()<CR>',
            vim.tbl_extend('force', opts, { desc = '関数シグネチャ表示' }))
        keymap('n', 'mrn', '<cmd>lua vim.lsp.buf.rename()<CR>',
            vim.tbl_extend('force', opts, { desc = 'リネーム' }))
        keymap('n', 'me', '<cmd>lua vim.diagnostic.open_float()<CR>',
            vim.tbl_extend('force', opts, { desc = '診断情報を表示' }))
        keymap('n', 'mq', '<cmd>lua vim.diagnostic.setloclist()<CR>',
            vim.tbl_extend('force', opts, { desc = '診断をloclistに表示' }))
        keymap('n', 'mwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
            vim.tbl_extend('force', opts, { desc = 'ワークスペースフォルダ追加' }))
        keymap('n', 'mwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
            vim.tbl_extend('force', opts, { desc = 'ワークスペースフォルダ削除' }))
        keymap('n', 'mwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
            vim.tbl_extend('force', opts, { desc = 'ワークスペースフォルダ一覧' }))
        keymap('n', '<C-Space>', '<cmd>lua vim.lsp.buf.hover()<CR>',
            vim.tbl_extend('force', opts, { desc = 'ホバー情報表示' }))
    end,
})
--

-- 起動時処理は31_startup.luaに移動
