--- local value{{{
local noremap = { noremap = true, desc = nil }
-- local remap = { remap = true, desc = nil } -- remapに変更
local keymap = vim.keymap.set

local minor_mode = require('rc/minor_mode')
-- }}}


-- 21_keymap.luaファイルの先頭付近に追加
local notify_level = vim.log.levels.WARN
-- vim.notify = function(msg, level, opts)
--     -- which-keyの特定のワーニングメッセージをフィルタリング
--     if level == notify_level and msg:match("which%-key") then
--         return
--     end
--     -- 元の通知関数を呼び出す
--     require("vim.notify")(msg, level, opts)
-- end


--- initialize{{{
-- keymap('', 's', '', noremap)  -- which-keyで管理するのでコメントアウト
-- 1. mのデフォルトマッピングを解除
keymap('n', 'm', '', noremap)
-- }}}

--- set leader, localleader{{{
vim.g.mapleader = 's'
vim.g.maplocalleader = ' '
-- }}}

-- which-key設定は plugins/which-key-spec.lua に移行済み

--- split window{{{
keymap('n', '<LocalLeader>vs', ':<C-u>sp<CR>', { noremap = true, desc = '画面を水平分割' })
keymap('n', '<LocalLeader>vv', ':<C-u>vs<CR>', { noremap = true, desc = '画面を垂直分割' })
-- }}}

--- undo{{{
keymap('n', '<LocalLeader>u', 'U', { noremap = true, desc = '行の変更を元に戻す' })
keymap('n', 'U', 'g+', { noremap = true, desc = '新しい変更に進む' })
keymap('n', 'u', 'g-', { noremap = true, desc = '前の変更に戻る' })
keymap('', '<A-;>', ':', { noremap = true, desc = 'コマンドラインモード' })
-- }}}

--- Windows path conversion (now handled by toggle library){{{
-- keymap('n', '<LocalLeader>3', '<cmd>lua ToggleAutoWindowsPathMode()<CR>',
--     { noremap = true, desc = '自動Windowsパス変換モードをトグル' })
-- Moved to toggle library
-- }}}

--- window{{{
minor_mode.create('Disp', '<Leader>s').set_multi(
    {
        -- { '-', '<C-w>-', '横幅を縮小' },  -- 71行目と重複（正しくは高さを縮小）のため削除
        { '|', '<C-w>|', '最大幅にする' },
        { 'x', '<C-w>x', 'カレントと次のウィンドウを入れ替え' },
        { 'w', '<C-w>w', '次のウィンドウへ移動' },
        { 'h', '<C-w>h', '左のウィンドウへ移動' },
        { 'j', '<C-w>j', '下のウィンドウへ移動' },
        { 'k', '<C-w>k', '上のウィンドウへ移動' },
        { 'l', '<C-w>l', '右のウィンドウへ移動' },
        { 'H', '<C-w>H', 'ウィンドウを左に移動' },
        { 'J', '<C-w>J', 'ウィンドウを下に移動' },
        { 'K', '<C-w>K', 'ウィンドウを上に移動' },
        { 'L', '<C-w>L', 'ウィンドウを右に移動' },
        { '>', '<C-w>>', '横幅を拡大' },
        { '<', '<C-w><', '横幅を縮小' },
        { '+', '<C-w>+', '高さを拡大' },
        { '-', '<C-w>-', '高さを縮小' },
        { 'c', '<C-w>c', 'ウィンドウを閉じる' },
        { 'o', '<C-w>o', '他のウィンドウを閉じる' },
        { 'r', '<C-w>r', 'ウィンドウを下向きに回転' },
        { 'R', '<C-w>R', 'ウィンドウを上向きに回転' },
        { 't', 'gt', '次のタブへ移動' },
        { 'T', '<C-w>T', 'ウィンドウを新しいタブに移動' },
        { '=', '<C-w>=', 'ウィンドウの高さと幅を均等にする' },
        { 'b', ':bp<CR>', '前のバッファへ移動' },
        { 'B', ':bn<CR>', '次のバッファへ移動' },
        -- { 's', ':Telescope buffers<CR>', 'バッファ一覧' },
    }
)
-- }}}

--- buffer{{{
minor_mode.create('Buf', '<LocalLeader>').set_multi(
    {
        { 'b', ':bp<CR>', '前のバッファへ移動' },
        { 'B', ':bn<CR>', '次のバッファへ移動' },
        -- { 's', ':Telescope buffers<CR>', 'バッファ一覧' },
    }
)
-- }}}

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
keymap('', '<Leader>S', ':SearchSession<CR>', { noremap = true, desc = 'セッション検索' })
keymap('n', '<Leader>u', ':Telescope undo<CR>', { noremap = true, desc = '変更履歴（Telescope）' })
keymap('n', '<Leader>t', ':terminal<CR>', { noremap = true, desc = 'ターミナル起動' })

--- inc dec
keymap('n', '-', '<C-X>', { noremap = true, desc = '数値デクリメント' })
keymap('n', '+', '<C-A>', { noremap = true, desc = '数値インクリメント' })

--- save, quit, reload ---{{{
keymap('', '<LocalLeader>w', ':w<CR>', { noremap = true, desc = '上書き保存' })
keymap('', '<LocalLeader>W', ':w!<CR>', { noremap = true, desc = '強制上書き保存' })
keymap('', '<LocalLeader>q', ':q<CR>', { noremap = true, desc = '終了' })
keymap('', '<LocalLeader>Q', ':q!<CR>', { noremap = true, desc = '強制終了' })
keymap('', '<LocalLeader>e', ':e!<CR>', { noremap = true, desc = '再読み込み' })
keymap('', '<LocalLeader>E', ':e .<CR>', { noremap = true, desc = 'カレントディレクトリを開く' })
-- }}}

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
keymap('n', '<F8>r', '<cmd>lua RandomScheme()<CR>', { noremap = true, desc = 'ランダムカラースキーム' })

-- LSP関連
keymap('n', 'm<Space>', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, desc = 'ホバー情報表示' })

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
minor_mode.create("ModeConvertCase", "<LocalLeader>").set("k", ":ConvertCaseLoop<CR>", "文字列の大文字小文字変換")

-- テキスト領域拡張モード
minor_mode.create('ModeExpandRegion', '<LocalLeader>').set('j', '<Plug>(expand_region_expand)', 'テキスト選択範囲を広げる')
minor_mode.create('ModeExpandRegion', '<LocalLeader>', 'x').set_multi({
    { 'j', '<Plug>(expand_region_expand)', '選択範囲を広げる' },
    { 'J', '<Plug>(expand_region_shrink)', '選択範囲を狭める' },
    { 'k', '<Plug>(expand_region_shrink)', '選択範囲を狭める' },
})

-- 翻訳
keymap('x', '<LocalLeader>t', '<cmd>Translate<CR>', { noremap = true, desc = '選択テキストを翻訳' })
keymap('n', '<LocalLeader>t', '<cmd>Translate<CR>', { noremap = true, desc = 'カーソル下の単語を翻訳' })

-- EasyAlign
keymap('', 'ga', '<plug>(EasyAlign)', { remap = true, desc = 'テキスト整列' })

-- Dropbar（パンくずリスト）
keymap('n', '<F2>', function()
    require('dropbar.api').pick()
end, { noremap = true, desc = 'パンくずリストメニューを開く' })

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
-- keymap('n', '<LocalLeader><Space>', '<Plug>(jumpcursor-jump)', { noremap = true, desc = '2文字で画面内ジャンプ' })
-- keymap('x', '<LocalLeader><Space>', '<Plug>(jumpcursor-jump)', { noremap = true, desc = '2文字でジャンプ' })

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
keymap('n', '<Leader>j', ':<C-u>OpenJunkfile<CR>', { noremap = true, desc = 'Junkファイルを開く' })

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

-- Markdown Preview
keymap('n', 'mp', '<Plug>MarkdownPreviewToggle', { noremap = false, desc = 'Markdownプレビュートグル' })

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
minor_mode.create('GitHunk', 'mg').set_multi({
    { 'j', ':Gitsigns next_hunk<CR>', '次のHunkへ' },
    { 'k', ':Gitsigns prev_hunk<CR>', '前のHunkへ' },
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
keymap('n', 'mnk', ':call quickrun#session#sweep()<CR>', { noremap = true, desc = 'QuickRunセッション終了' })

-- エラージャンプモード（新しいdefine_complete_mode使用）
local minor_mode = require('rc/minor_mode')

-- フック関数：モード開始時に全エラー表示に切り替え
local function diag_mode_enter()
    vim.diagnostic.config({
        virtual_text = {
            prefix = "●",
            source = "if_many",
            spacing = 2,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
    })
    -- tiny-inline-diagnosticを無効化
    local ok, tiny = pcall(require, "tiny-inline-diagnostic")
    if ok then
        tiny.disable()
    end
    print("-- DIAGNOSTIC MODE: 全エラー表示 --")
end

-- フック関数：モード終了時に元の表示に戻す
local function diag_mode_exit()
    -- トグル設定を復元（単純に診断トグルの現在状態を再適用）
    local ok, toggle = pcall(require, '12_toggle')
    if ok and toggle then
        -- 現在の診断トグル状態を取得
        local current_state = toggle.get_state('diagnostics')
        if current_state then
            -- 状態に応じて適切な診断設定を復元
            if current_state == 'cursor_only' then
                -- tiny-inline-diagnosticに戻す
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = true,
                    underline = false,
                    update_in_insert = false,
                    severity_sort = true,
                })
                local tiny_ok, tiny = pcall(require, "tiny-inline-diagnostic")
                if tiny_ok then
                    tiny.enable()
                end
            elseif current_state == 'full_with_underline' then
                -- 全表示（既に設定済みなので何もしない）
            elseif current_state == 'signs_only' then
                -- サインのみに戻す
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = true,
                    underline = false,
                    update_in_insert = false,
                    severity_sort = true,
                })
                local tiny_ok, tiny = pcall(require, "tiny-inline-diagnostic")
                if tiny_ok then
                    tiny.disable()
                end
            end
        end
    end
    print("診断表示を元に戻しました")
end

-- 新しいdefine_complete_modeを使用
minor_mode.define_complete_mode({
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
        enter = diag_mode_enter,
        exit = diag_mode_exit
    },
    options = {
        persistent = true
        -- exit_keys は デフォルトで {'<Esc>', 'q'} が設定される
        -- show_help_key は デフォルトで '?' が設定される
    }
})


-- トグル関連 (now handled by toggle library)
-- Moved to toggle library
-- keymap('n', '<LocalLeader>0', ':set readonly!<CR>', { noremap = true, desc = '読み取り専用モードトグル' })
-- keymap('n', '<LocalLeader>9', '<cmd>lua ToggleAutoHover()<CR>', { noremap = true, desc = '自動ホバートグル' })
-- keymap('n', '<LocalLeader>8', ':<C-u>MigemoToggle<CR>', { noremap = true, desc = 'Migemoトグル' })
-- keymap('n', '<LocalLeader>7', ':ColorizerToggle<CR>', { noremap = true, desc = 'カラー表示トグル' })
-- keymap('n', '<LocalLeader>2', ':ToggleJumpMode<CR>', { noremap = true, desc = 'ジャンプモード切替（ファイル内⇔グローバル）' })
-- minor_mode.create("ToggleDiagDisp", "<LocalLeader>").set("`", "<cmd>lua ToggleDiagDisp(true, true)<CR>", "診断表示モード切替")

-- 構文情報
keymap('x', '<LocalLeader>1', ':SyntaxInfo<CR>', { noremap = true, desc = '構文情報表示' })

-- その他設定
-- Moved to toggle library
-- keymap('n', '<LocalLeader>6', ':set paste!<CR>', { noremap = true, desc = 'ペーストモードトグル' })
-- keymap('n', '<LocalLeader>5', ':QuickScopeToggle<CR>', { noremap = true, desc = 'QuickScopeトグル' })
keymap('n', '<Leader><Space>', '<C-W>p', { noremap = true, desc = '前のウィンドウに移動' })

--- Toggle Library Integration{{{
-- Load toggle configuration (automatically registers minor_mode mappings)
-- require('12_toggle') -- 番号順で自動読み込みされるのでコメントアウト

-- 追加の管理機能キーマップ
keymap('n', '<LocalLeader>0l', '<cmd>lua require("rc.toggle").list_toggles()<CR>', { noremap = true, desc = 'トグル一覧表示' })
keymap('n', '<LocalLeader>0L', ':ToggleLualineSelect<CR>', { noremap = true, desc = 'lualine表示切り替え' })
keymap('n', '<LocalLeader>0s', '<cmd>lua require("rc.toggle").save_states()<CR>', { noremap = true, desc = 'トグル状態保存' })
keymap('n', '<LocalLeader>0o', '<cmd>lua require("rc.toggle").load_states()<CR>', { noremap = true, desc = 'トグル状態読み込み' })
-- }}}

-- ナビゲーション
keymap('n', '<C-,>', '<Plug>(milfeulle-prev)', { noremap = true, desc = '前の位置に移動' })
keymap('n', '<C-.>', '<Plug>(milfeulle-next)', { noremap = true, desc = '次の位置に移動' })
keymap('', '<C-j>', '<Plug>(edgemotion-j)', { desc = '下の空行へ移動' })
keymap('', '<C-k>', '<Plug>(edgemotion-k)', { desc = '上の空行へ移動' })

-- TreeSitter関連
keymap('o', 'iu', ':<c-u>lua require"treesitter-unit".select()<CR>', { noremap = true, desc = 'TS:ユニット内選択（操作）' })
keymap('o', 'au', ':<c-u>lua require"treesitter-unit".select(true)<CR>', { noremap = true, desc = 'TS:ユニット全体選択（操作）' })

-- LSPコマンド
-- LSP基本ナビゲーション（Telescope版）
keymap('n', 'md', '<cmd>Telescope lsp_definitions<CR>', { noremap = true, desc = '定義一覧（Telescope）' })
keymap('n', 'mD', '<cmd>Telescope lsp_declarations<CR>', { noremap = true, desc = '宣言一覧（Telescope）' })
keymap('n', 'mt', '<cmd>Telescope lsp_type_definitions<CR>', { noremap = true, desc = '型定義一覧（Telescope）' })
keymap('n', '<C-Space>', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, desc = 'ホバー情報表示' })
keymap('n', 'mh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { noremap = true, desc = '関数シグネチャ表示' })

-- mrシリーズ（grシリーズのm版）
keymap('n', 'mrr', '<cmd>Telescope lsp_references<CR>', { noremap = true, desc = '参照一覧（Telescope）' })
keymap('n', 'mra', '<cmd>Telescope lsp_code_actions<CR>', { noremap = true, desc = 'コードアクション（Telescope）' })
keymap('n', 'mrn', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, desc = 'リネーム' })
keymap('n', 'mri', '<cmd>Telescope lsp_implementations<CR>', { noremap = true, desc = '実装一覧（Telescope）' })

-- シンボル検索（gO, gSのm版）
keymap('n', 'mO', '<cmd>Telescope lsp_document_symbols<CR>', { noremap = true, desc = 'ドキュメントシンボル（Telescope）' })
keymap('n', 'mS', '<cmd>Telescope lsp_workspace_symbols<CR>', { noremap = true, desc = 'ワークスペースシンボル（Telescope）' })

-- その他
keymap('n', 'mf', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { noremap = true, desc = 'コードフォーマット' })

-- ワークスペース関連
keymap('n', 'mwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', { noremap = true, desc = 'ワークスペースフォルダ追加' })
keymap('n', 'mwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', { noremap = true, desc = 'ワークスペースフォルダ削除' })
keymap('n', 'mwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    { noremap = true, desc = 'ワークスペースフォルダ一覧' })

-- 診断表示
keymap('n', 'me', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, desc = '診断情報を表示' })
keymap('n', 'mq', '<cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, desc = '診断をloclistに表示' })

-- 診断移動は上記のDIAGNOSTICモードで統一（削除）

-- 単語置換関連
keymap('n', 'ciy', 'ciw<C-R>0<ESC><Right>', { noremap = true, desc = '単語をヤンク内容に置換' })
keymap('n', 'ciY', 'ciW<C-R>0<ESC><Right>', { noremap = true, desc = '大きな単語をヤンク内容に置換' })

-- 日本語入力関連
keymap('n', 'あ', 'a', { noremap = true, desc = '後に挿入（日本語）' })
keymap('n', 'い', 'i', { noremap = true, desc = '前に挿入（日本語）' })

-- 追加キーマップ
-- minor_mode.create("ModeConvertCase", "<LocalLeader>").set("k", ":ConvertCaseLoop<CR>", "文字列の大文字小文字変換")  -- 215行目と重複のため削除

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
minor_mode.create('Fold', 'z').set_multi({
    { 'a', 'za', '現在のフォールドをトグル' },
    { 'R', 'zR', 'すべてのフォールドを開く' },
    { 'M', 'zM', 'すべてのフォールドを閉じる' },
    { 'r', 'zr', 'フォールドレベルを1段階開く' },
    { 'm', 'zm', 'フォールドレベルを1段階閉じる' },
    { 'j', 'zj', '次のフォールドへ' },
    { 'k', 'zk', '前のフォールドへ' },
    { 'x', 'zx', 'フォールドを更新して再適用' },
    { '0', '<cmd>lua SetFoldLevel(0)<CR>', 'フォールドレベル0に設定' },
    { '1', '<cmd>lua SetFoldLevel(1)<CR>', 'フォールドレベル1に設定' },
    { '2', '<cmd>lua SetFoldLevel(2)<CR>', 'フォールドレベル2に設定' },
    { '3', '<cmd>lua SetFoldLevel(3)<CR>', 'フォールドレベル3に設定' },
    { '4', '<cmd>lua SetFoldLevel(4)<CR>', 'フォールドレベル4に設定' },
})


keymap('o', '<LocalLeader>s', ':<C-U>lua require("tsht").nodes()<CR>', {})
keymap('x', '<LocalLeader>s', ':lua require("tsht").nodes()<CR>', noremap)
keymap('n', '<LocalLeader>s', 'v:lua require("tsht").nodes()<CR>', noremap)


-- デバッグ用のキーマップ（F7をプレフィックスとして使用）
minor_mode.create('Debugger', '<F7>', 'n', { persistent = true }).set_multi({
    { 'b', '<cmd>lua require("dap").toggle_breakpoint()<CR>', 'ブレークポイントをトグル' },
    { 'B', '<cmd>lua require("dap").set_breakpoint(vim.fn.input("条件付きブレークポイント: "))<CR>', '条件付きブレークポイント設定' },
    { 'c', '<cmd>lua require("dap").continue()<CR>', '実行継続' },
    { 'i', '<cmd>lua require("dap").step_into()<CR>', 'ステップイン' },
    { 'o', '<cmd>lua require("dap").step_over()<CR>', 'ステップオーバー' },
    { 'O', '<cmd>lua require("dap").step_out()<CR>', 'ステップアウト' },
    { 'r', '<cmd>lua require("dap").repl.open()<CR>', 'REPL表示' },
    { 'l', '<cmd>lua require("dap").run_last()<CR>', '最後の実行を再開' },
    { 'u', '<cmd>lua require("dapui").toggle()<CR>', 'デバッグUIトグル' },
    { 't', '<cmd>lua require("dap").terminate()<CR>', '終了' },
    { 'w', '<cmd>lua require("dap.ui.widgets").hover()<CR>', '変数情報表示' },
    { 's', '<cmd>lua local widgets=require("dap.ui.widgets");widgets.centered_float(widgets.scopes)<CR>', 'スコープ表示' },
})

-- 言語別のデバッグ用キーマップ
-- Python用
minor_mode.create('PythonDebug', '<F7>p').set_multi({
    { 'r', '<cmd>lua require("dap").run_last()<CR>', '最後の実行を再開' },
    { 'd', '<cmd>lua require("dap-python").debug_selection()<CR>', '選択範囲をデバッグ' },
    { 't', '<cmd>lua require("dap-python").test_method()<CR>', 'テストメソッド実行' },
    { 'c', '<cmd>lua require("dap-python").test_class()<CR>', 'テストクラス実行' },
})

-- Rust用
minor_mode.create('RustDebug', '<F7>r').set_multi({
    { 'r', '<cmd>lua require("dap").run_last()<CR>', '最後の実行を再開' },
    { 'm', '<cmd>lua require("dap").run_to_cursor()<CR>', 'カーソル位置まで実行' },
})

-- 起動時処理は31_startup.luaに移動
