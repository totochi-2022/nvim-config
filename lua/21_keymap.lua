--- local value{{{
local noremap = { noremap = true, desc = nil }
local remap = { remap = true, desc = nil } -- remapに変更
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
keymap('', 's', '', noremap)
-- 1. mのデフォルトマッピングを解除
keymap('n', 'm', '', noremap)
-- }}}

--- set leader, localleader{{{
vim.g.mapleader = 's'
vim.g.maplocalleader = ' '
-- }}}

-- which-key設定は新しいAPIに移行予定
-- local wk = require("which-key")
-- wk.register({
--     s = { name = "ウィンドウ・バッファ操作" },
--     m = { name = "LSP・診断関連" },
--     z = { name = "フォールド操作" },
-- })

-- wk.register({
--     ["<localleader>"] = {
--         b = { name = "バッファ操作" },
--         c = { name = "コメント操作" },
--         v = { name = "ウィンドウ分割" },
--         j = { name = "領域拡張" },
--     }
-- })

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

--- window{{{
minor_mode.create('Disp', '<Leader>s').set_multi(
    {
        { '-', '<C-w>-', '横幅を縮小' },
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
minor_mode.create('Tab', '<LocalLeader>').set('t', 'gt', '次のタブへ移動')
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
keymap('', '<Leader>r', ':Telescope registers<CR>', { noremap = true, desc = 'レジスタ一覧' })
keymap('', '<Leader>k', ':Telescope keymaps<CR>', { noremap = true, desc = 'キーマップ一覧' })
keymap('', '<Leader><F1>', ':Telescope help_tags<CR>', { noremap = true, desc = 'ヘルプタグ検索' })
keymap('', '<Leader><F2>', ':Telescope man_pages<CR>', { noremap = true, desc = 'マニュアルページ検索' })
keymap('', '<Leader>m', ':Telescope marks', { noremap = true, desc = 'マーク一覧' })
keymap('', '<Leader>A', ':Telescope lsp_<Tab>', { noremap = true, desc = 'LSP機能一覧' })
keymap('', '<Leader>g', ':Telescope live_grep<CR>', { noremap = true, desc = 'テキスト検索（Grep）' })
keymap('', '<Leader>q', ':Telescope quickfix<CR>', { noremap = true, desc = 'クイックフィックス一覧' })
keymap('', '<Leader>Q', ':Telescope quickfixhistory<CR>', { noremap = true, desc = 'クイックフィックス履歴' })
keymap('', '<Leader>i', ':Telescope ghq list<CR>', { noremap = true, desc = 'ghqリポジトリ一覧' })
keymap('', '<Leader>d', ':Telescope diagnostics<CR>', { noremap = true, desc = '診断一覧' })
keymap('', '<Leader>f', ':Telescope fd<CR>', { noremap = true, desc = 'ファイル検索' })
keymap('', '<Leader>e', ':Telescope file_browser path=%:p:h<CR>', { noremap = true, desc = 'ファイルブラウザ（現在のディレクトリ）' })
keymap('', '<Leader>J', ':Telescope jumplist<CR>', { noremap = true, desc = 'ジャンプリスト' })
keymap('', '<Leader>S', ':SearchSession<CR>', { noremap = true, desc = 'セッション検索' })
keymap('n', '<Leader>u', ':MundoToggle<CR>', { noremap = true, desc = '変更履歴（UNDO）表示' })
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

-- WhichKey 関連
vim.keymap.set('n', '<Leader>?w', ':WhichKey "<C-w>"<CR>', { noremap = true, desc = 'ウィンドウ操作のヘルプ' })
vim.keymap.set('n', '<Leader>?c', ':WhichKey "C-"<CR>', { noremap = true, desc = 'Ctrlキーのヘルプ' })
vim.keymap.set('n', '<Leader>?a', ':WhichKey "M-"<CR>', { noremap = true, desc = 'Altキーのヘルプ' })
vim.keymap.set('n', '<Leader>?', ':WhichKey<CR>', { noremap = true, desc = '全キーマップのヘルプ' })

-- カレントディレクトリ関連
keymap('n', '<F8>E', ':!explorer.exe .<CR>', { noremap = true, desc = 'エクスプローラでカレントディレクトリを開く' })
keymap('n', '<F8>e', ':!tabe<CR>', { noremap = true, desc = '新しいタブで開く' })
keymap('n', '<F8>x', ':<C-u>TerminalCurrentDir<CR><CR>', { noremap = true, desc = 'ターミナルでカレントディレクトリを開く' })
keymap('n', '<F8>s', ':PackerSync<CR>', { noremap = true, desc = 'プラグイン同期' })
keymap('n', '<F8>c', ':PackerCompile<CR>', { noremap = true, desc = 'プラグインコンパイル' })
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
keymap('x', '<LocalLeader>t', ':Translate<CR>', { noremap = true, desc = '選択テキストを翻訳' })
keymap('n', '<LocalLeader>t', ':Translate<CR>', { noremap = true, desc = 'カーソル下の単語を翻訳' })

-- EasyAlign
keymap('', 'ga', '<plug>(EasyAlign)', { remap = true, desc = 'テキスト整列' })

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

-- JumpToLine
keymap('n', 'mo', ':<C-u>JumpToLine<CR>', { noremap = true, desc = '指定行へジャンプ' })

-- トグル関連
keymap('n', '<LocalLeader>0', ':set readonly!<CR>', { noremap = true, desc = '読み取り専用モードトグル' })
keymap('n', '<LocalLeader>9', '<cmd>lua ToggleAutoHover()<CR>', { noremap = true, desc = '自動ホバートグル' })
keymap('n', '<LocalLeader>8', ':<C-u>MigemoToggle<CR>', { noremap = true, desc = 'Migemoトグル' })
keymap('n', '<LocalLeader>7', ':ColorizerToggle<CR>', { noremap = true, desc = 'カラー表示トグル' })
keymap('n', '<LocalLeader>2', ':ToggleJumpMode<CR>', { noremap = true, desc = 'ジャンプモード切替（ファイル内⇔グローバル）' })
minor_mode.create("ToggleDiagDisp", "<LocalLeader>").set("`", "<cmd>lua ToggleDiagDisp(true)<CR>", "診断表示モード切替")

-- 構文情報
keymap('x', '<LocalLeader>1', ':SyntaxInfo<CR>', { noremap = true, desc = '構文情報表示' })

-- その他設定
keymap('n', '<LocalLeader>6', ':set paste!<CR>', { noremap = true, desc = 'ペーストモードトグル' })
keymap('n', '<LocalLeader>5', ':QuickScopeToggle<CR>', { noremap = true, desc = 'QuickScopeトグル' })
keymap('n', '<Leader><Space>', '<C-W>p', { noremap = true, desc = '前のウィンドウに移動' })

-- ナビゲーション
keymap('n', '<C-,>', '<Plug>(milfeulle-prev)', { noremap = true, desc = '前の位置に移動' })
keymap('n', '<C-.>', '<Plug>(milfeulle-next)', { noremap = true, desc = '次の位置に移動' })
keymap('', '<C-j>', '<Plug>(edgemotion-j)', { desc = '下の空行へ移動' })
keymap('', '<C-k>', '<Plug>(edgemotion-k)', { desc = '上の空行へ移動' })

-- TreeSitter関連
keymap('o', 'iu', ':<c-u>lua require"treesitter-unit".select()<CR>', { noremap = true, desc = 'TS:ユニット内選択（操作）' })
keymap('o', 'au', ':<c-u>lua require"treesitter-unit".select(true)<CR>', { noremap = true, desc = 'TS:ユニット全体選択（操作）' })

-- LSPコマンド
keymap('n', 'md', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, desc = '定義にジャンプ' })
keymap('n', 'mD', '<cmd>lua vim.lsp.buf.declaration()<CR>', { noremap = true, desc = '宣言にジャンプ' })
keymap('n', 'mi', '<cmd>lua vim.lsp.buf.implementation()<CR>', { noremap = true, desc = '実装にジャンプ' })
keymap('n', 'mt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', { noremap = true, desc = '型定義にジャンプ' })
keymap('n', '<C-Space>', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, desc = 'ホバー情報表示' })
keymap('n', 'mh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { noremap = true, desc = '関数シグネチャ表示' })
keymap('n', 'mr', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, desc = 'リネーム' })
keymap('n', 'mca', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, desc = 'コードアクション' })
keymap('n', 'mf', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { noremap = true, desc = 'コードフォーマット' })
keymap('n', 'mrf', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, desc = '参照検索' })

-- ワークスペース関連
keymap('n', 'mwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', { noremap = true, desc = 'ワークスペースフォルダ追加' })
keymap('n', 'mwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', { noremap = true, desc = 'ワークスペースフォルダ削除' })
keymap('n', 'mwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    { noremap = true, desc = 'ワークスペースフォルダ一覧' })

-- 診断表示
keymap('n', 'me', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, desc = '診断情報を表示' })
keymap('n', 'mq', '<cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, desc = '診断をloclistに表示' })

-- 診断移動用のminor_mode
minor_mode.create('DiagnosticJump', 'm').set_multi({
    -- 全ての診断
    { ']', '<cmd>lua vim.diagnostic.goto_next()<CR>zz', '次の診断へ' },
    { '[', '<cmd>lua vim.diagnostic.goto_prev()<CR>zz', '前の診断へ' },

    -- エラーのみ
    { 'e]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>', '次のエラーへ' },
    { 'e[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>', '前のエラーへ' },

    -- 警告のみ
    { 'w]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})<CR>', '次の警告へ' },
    { 'w[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})<CR>', '前の警告へ' },

    -- 情報のみ
    { 'i]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.INFO})<CR>', '次の情報へ' },
    { 'i[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.INFO})<CR>', '前の情報へ' },

    -- ヒントのみ
    { 'h]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.HINT})<CR>', '次のヒントへ' },
    { 'h[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.HINT})<CR>', '前のヒントへ' },
})

-- 単語置換関連
keymap('n', 'ciy', 'ciw<C-R>0<ESC><Right>', { noremap = true, desc = '単語をヤンク内容に置換' })
keymap('n', 'ciY', 'ciW<C-R>0<ESC><Right>', { noremap = true, desc = '大きな単語をヤンク内容に置換' })

-- 日本語入力関連
keymap('n', 'あ', 'a', { noremap = true, desc = '後に挿入（日本語）' })
keymap('n', 'い', 'i', { noremap = true, desc = '前に挿入（日本語）' })

-- 追加キーマップ
minor_mode.create("ModeConvertCase", "<LocalLeader>").set("k", ":ConvertCaseLoop<CR>", "文字列の大文字小文字変換")

-- レジスタ関連
keymap('', '<LocalLeader>y', ':let @q = @*<CR>', { noremap = true, desc = 'クリップボードをレジスタqにコピー' })

-- ターミナル関連
if is_windows then
    -- PowerShell用の設定
    keymap('t', '<Esc>', [[<C-\><C-n>]], { desc = 'ノーマルモードへ' })
    keymap('t', '<C-w>', [[<C-\><C-n><C-w>]], { desc = 'ウィンドウ操作' })
end

-- アウトライン表示
keymap('n', '<Leader>o', ':SymbolsOutline<CR>', { noremap = true, desc = 'アウトライン表示トグル' })

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
minor_mode.create('Debugger', '<F7>','n',{persistent = true}).set_multi({
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

-- LSPコマンド
keymap('n', 'md', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, desc = '定義にジャンプ' })
keymap('n', 'mD', '<cmd>lua vim.lsp.buf.declaration()<CR>', { noremap = true, desc = '宣言にジャンプ' })
keymap('n', 'mi', '<cmd>lua vim.lsp.buf.implementation()<CR>', { noremap = true, desc = '実装にジャンプ' })
keymap('n', 'mt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', { noremap = true, desc = '型定義にジャンプ' })
keymap('n', '<C-Space>', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, desc = 'ホバー情報表示' })
keymap('n', 'mh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { noremap = true, desc = '関数シグネチャ表示' })
keymap('n', 'mr', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, desc = 'リネーム' })
keymap('n', 'mca', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, desc = 'コードアクション' })
keymap('n', 'mf', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { noremap = true, desc = 'コードフォーマット' })
keymap('n', 'mrf', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, desc = '参照検索' })

-- ワークスペース関連
keymap('n', 'mwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', { noremap = true, desc = 'ワークスペースフォルダ追加' })
keymap('n', 'mwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', { noremap = true, desc = 'ワークスペースフォルダ削除' })
keymap('n', 'mwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    { noremap = true, desc = 'ワークスペースフォルダ一覧' })

-- 診断表示
keymap('n', 'me', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, desc = '診断情報を表示' })
keymap('n', 'mq', '<cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, desc = '診断をloclistに表示' })

-- 診断移動用のminor_mode
minor_mode.create('DiagnosticJump', 'm').set_multi({
    -- 全ての診断
    { ']', '<cmd>lua vim.diagnostic.goto_next()<CR>zz', '次の診断へ' },
    { '[', '<cmd>lua vim.diagnostic.goto_prev()<CR>zz', '前の診断へ' },

    -- エラーのみ
    { 'e]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>', '次のエラーへ' },
    { 'e[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>', '前のエラーへ' },

    -- 警告のみ
    { 'w]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})<CR>', '次の警告へ' },
    { 'w[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})<CR>', '前の警告へ' },

    -- 情報のみ
    { 'i]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.INFO})<CR>', '次の情報へ' },
    { 'i[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.INFO})<CR>', '前の情報へ' },

    -- ヒントのみ
    { 'h]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.HINT})<CR>', '次のヒントへ' },
    { 'h[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.HINT})<CR>', '前のヒントへ' },
})



-- プレフィックスキーの明示的な登録（新しいAPIに移行予定）
-- local wk = require("which-key")

-- -- リーダーキー 's' の登録 - 完全なリスト形式
-- wk.register({
--     { "s", name = "ウィンドウ・バッファ操作" },
--     { "sb", ":Telescope buffers<CR>", "バッファ一覧" },
--     { "sh", ":Telescope frecency<CR>", "履歴関連" },
--     { "sg", ":Telescope live_grep<CR>", "検索関連" },
-- })

-- -- 'm' プレフィックスの登録
-- wk.register({
--     { "m", name = "LSP・診断関連" },
--     { "md", "<cmd>lua vim.lsp.buf.definition()<CR>", "定義へ移動" },
--     { "mD", "<cmd>lua vim.lsp.buf.declaration()<CR>", "宣言へ移動" },
--     { "mi", "<cmd>lua vim.lsp.buf.implementation()<CR>", "実装へ移動" },
--     { "mr", "<cmd>lua vim.lsp.buf.rename()<CR>", "リネーム" },
--     { "me", "<cmd>lua vim.diagnostic.open_float()<CR>", "診断表示" },
--     { "m<Space>", "<cmd>lua vim.lsp.buf.hover()<CR>", "ホバー情報表示" },
--     { "m]", "<cmd>lua vim.diagnostic.goto_next()<CR>", "次の診断へ" },
--     { "m[", "<cmd>lua vim.diagnostic.goto_prev()<CR>", "前の診断へ" },
--     { "me]", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>", "次のエラーへ" },
--     { "me[", "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>", "前のエラーへ" },
-- })

-- -- ローカルリーダー設定（スペースキー）
-- wk.register({
--     { "<Space>", name = "ローカルリーダー" },
--     { "<Space>b", name = "バッファ操作" },
--     { "<Space>c", name = "コメント操作" },
--     { "<Space>t", ":Translate<CR>", "翻訳" },
--     { "<Space>j", name = "領域拡張" },
--     { "<Space>v", name = "ウィンドウ分割" },
--     { "<Space>d", ":lua require('dapui').toggle()<CR>", "デバッグUIトグル" },
--     { "<Space>o", ":SymbolsOutline<CR>", "アウトライン表示" },
-- })

-- -- zキー（フォールド）
-- wk.register({
--     { "z", name = "フォールド操作" },
--     { "za", "za", "現在のフォールドをトグル" },
--     { "zR", "zR", "すべてのフォールドを開く" },
--     { "zM", "zM", "すべてのフォールドを閉じる" },
-- })


-- WhichKeyのトリガーを自動的に更新する関数（新しいAPIに移行予定）
-- _G.update_which_key_triggers = function()
--     -- 基本プレフィックス
--     local prefixes = { "<leader>", "<localleader>" }

--     -- 一般的に使用されるプレフィックスを追加
--     local known_prefixes = { "s", "m", "z", "g", "f", "d", "c", "y", "v" }

--     for _, prefix in ipairs(known_prefixes) do
--         table.insert(prefixes, prefix)
--     end

--     -- minor_modeで使用している可能性のあるプレフィックスも収集
--     for _, mode in ipairs({ "n", "v", "x", "s", "o", "i", "c", "t" }) do
--         local mode_maps = vim.api.nvim_get_keymap(mode)
--         for _, mapping in ipairs(mode_maps) do
--             local lhs = mapping.lhs
--             -- 単一キーのみ対象
--             if #lhs == 1 and not vim.tbl_contains(prefixes, lhs) then
--                 table.insert(prefixes, lhs)
--             end
--         end
--     end

--     -- 重複排除
--     prefixes = vim.fn.uniq(prefixes)

--     -- WhichKeyの設定を更新
--     local status_ok, which_key = pcall(require, "which-key")
--     if status_ok then
--         which_key.setup({ triggers = prefixes })
--         -- print("WhichKey triggers updated: " .. table.concat(prefixes, ", "))
--     end
-- end

-- -- キーマップがすべて設定された後に実行
-- vim.defer_fn(function()
--     if _G.update_which_key_triggers then
--         _G.update_which_key_triggers()
--     end
-- end, 10) -- 100ms遅延させて実行



-- -- キーを押したときに手動でWhichKeyを呼び出す
-- vim.keymap.set('n', 's', function()
--     require("which-key").show("s", { mode = "n", auto = true })
-- end, { noremap = true })

-- vim.keymap.set('n', 'm', function()
--     require("which-key").show("m", { mode = "n", auto = true })
-- end, { noremap = true })
