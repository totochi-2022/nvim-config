--- local value{{{
local noremap = { noremap = true }
local remap = { noremap = false }
-- local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap
local minor_mode = require('rc/minor_mode')
-- }}}
--- initialize{{{
keymap('', 's', '', noremap)
-- 1. mのデフォルトマッピングを解除
keymap('n', 'm', '', noremap)

-- 2. 特定のマークのみを許可
-- よく使うマークのみを設定
-- keymap('n', 'mz', 'mz', noremap)
-- keymap('n', 'mx', 'mx', noremap)
-- keymap('n', 'mc', 'mc', noremap)
-- マークへのジャンプも設定
-- keymap('n', "'z", "'z", noremap)
-- keymap('n', "'x", "'x", noremap)
-- keymap('n', "'c", "'c", noremap)
-- keymap('', ',', '', noremap)
-- keymap('', '#', '', noremap)
-- }}}
--- set leader, localleader{{{
-- require("which-key").register({
--     ["s"] = { name = "Leader" },  -- sキーをLeaderとして認識
-- })
vim.g.mapleader = 's'
vim.g.maplocalleader = ' '
-- }}}
--- split window{{{
keymap('n', '<LocalLeader>vs', ':<C-u>sp<CR>', noremap) --horizontal split
keymap('n', '<LocalLeader>vv', ':<C-u>vs<CR>', noremap) --vertical split
-- }}}
--- undo{{{
keymap('n', '<LocalLeader>u', 'U', noremap)
keymap('n', 'U', 'g+', noremap)
keymap('n', 'u', 'g-', noremap)
keymap('', '<A-;>', ':', noremap)
-- }}}
--- window{{{
minor_mode.create('Disp', '<Leader>s').set_multi(
    {
        { '-', '<C-w>-' },                 -- 左のウィンドウへ移動
        { '|', '<C-w>|' },                 -- 左のウィンドウへ移動
        { 'x', '<C-w>x' },                 -- 左のウィンドウへ移動
        { 'w', '<C-w>w' },                 -- 左のウィンドウへ移動
        { 'h', '<C-w>h' },                 -- 左のウィンドウへ移動
        { 'j', '<C-w>j' },                 -- 上のウィンドウへ移動
        { 'k', '<C-w>k' },                 -- 下のウィンドウへ移動
        { 'l', '<C-w>l' },                 -- 右のウィンドウへ移動
        { 'H', '<C-w>H' },                 -- カレントウィンドウを左に移動
        { 'J', '<C-w>J' },                 -- カレントウィンドウを上に移動
        { 'K', '<C-w>K' },                 -- カレントウィンドウを下に移動
        { 'L', '<C-w>L' },                 -- カレントウィンドウを右に移動
        { '>', '<C-w>>' },                 -- カレントウィンドウ幅を拡大
        { '<', '<C-w><' },                 -- カレントウィンドウ幅を縮小
        { '+', '<C-w>+' },                 -- カレントウィンドウ高さを拡大
        { '-', '<C-w>-' },                 -- カレントウィンドウ高さを縮小
        { 'c', '<C-w>c' },                 -- カレントウィンドウを閉じる
        { 'o', '<C-w>o' },                 -- 他のウィンドウを閉じる
        { 'r', '<C-w>r' },                 -- ウィンドウ配置を下向きに回転
        { 'R', '<C-w>R' },                 -- ウィンドウ配置を上向きに回転
        { 't', 'gt' },                     -- 次のタブに移動
        { 'T', '<C-w>T' },                 -- カレントウィンドウを新しいタブに移す
        { '=', '<C-w>=' },                 -- すべてのウィンドウの大きさをそろえる
        { 'b', ':bp<CR>' },                -- 左のウィンドウへ移動
        { 'B', ':bn<CR>' },                -- 左のウィンドウへ移動
        { 's', ':Telescope buffers<CR>' }, -- 左のウィンドウへ移動
    }
)

-- }}}
--- buffer{{{
minor_mode.create('Buf', '<LocalLeader>').set_multi(
    {
        { 'b', ':bp<CR>' },                -- 左のウィンドウへ移動
        { 'B', ':bn<CR>' },                -- 左のウィンドウへ移動
        { 's', ':Telescope buffers<CR>' }, -- 左のウィンドウへ移動
    }
)
-- }}}
--- tab{{{
minor_mode.create('Tab', '<LocalLeader>').set('t', 'gt') -- 次のタブへ移動
keymap('', '<LocalLeader>T', '<C-W>T', noremap)
-- }}}
-- NERDCommenter{{{
keymap('n', '<LocalLeader>c', '<Plug>NERDCommenterToggle', noremap)
keymap('x', '<LocalLeader>c', '<Plug>NERDCommenterToggle', noremap)
keymap('n', '<LocalLeader>Cn', '<Plug>NERDCommenterNested', noremap)
keymap('x', '<LocalLeader>Cn', '<Plug>NERDCommenterNested', noremap)
keymap('n', '<LocalLeader>Cu', '<Plug>NERDCommenterUncomment', noremap)
keymap('x', '<LocalLeader>Cu', '<Plug>NERDCommenterUncomment', noremap)
keymap('n', '<LocalLeader>CC', '<Plug>NERDCommenterComment', noremap)
keymap('x', '<LocalLeader>CC', '<Plug>NERDCommenterComment', noremap)
keymap('x', '<LocalLeader>Cs', '<Plug>NERDCommenterInvert', noremap)
keymap('n', '<LocalLeader>Ci', '<Plug>NERDCommenterToEOL', noremap)
keymap('n', '<LocalLeader>CA', '<Plug>NERDCommenterAppend', noremap)
keymap('x', '<LocalLeader>CA', '<Plug>NERDCommenterAppend', noremap)
keymap('n', '<LocalLeader>Cy', '<Plug>NERDCommenterYank', noremap)
keymap('x', '<LocalLeader>Cy', '<Plug>NERDCommenterYank', noremap)
keymap('n', '<LocalLeader>Cp', '<Plug>NERDCommenterAppend <ESC> p', noremap)
-- }}}


--- [;] [:] replace ---{{{
keymap('', ':', ';', noremap)
keymap('n', '<Leader>;', ':', noremap)
keymap('n', 'q;', 'q:', noremap)
keymap('n', '<LocalLeader>;', ':<C-u>Capture :', noremap)
keymap('n', ';', '<cmd>FineCmdline<CR>', noremap)
keymap('x', ';', [[:<C-u>FineCmdline '<,'><CR>]], noremap)

-- }}}
--- <Leader>{{{
keymap('', '<Leader>b', ':Telescope buffers<CR>', noremap)
keymap('', '<F3>', ':Telescope command_palette<CR>', noremap)
keymap('', '<Leader>h', ':Telescope frecency<CR>', noremap)
keymap('', '<Leader>H', ':Telescope oldfiles<CR>', noremap)
keymap('', '<Leader>r', ':Telescope registers<CR>', noremap)
keymap('', '<Leader>k', ':Telescope keymaps<CR>', noremap)
keymap('', '<Leader><F1>', ':Telescope help_tags<CR>', noremap)
keymap('', '<Leader><F2>', ':Telescope man_pages<CR>', noremap)
keymap('', '<Leader>m', ':Telescope marks', noremap)
-- keymap('', '<Leader>a', ':Telescope <CR>', noremap)
keymap('', '<Leader>A', ':Telescope lsp_<Tab>', noremap)
keymap('', '<Leader>g', ':Telescope live_grep<CR>', noremap)
keymap('', '<Leader>q', ':Telescope quickfix<CR>', noremap)
keymap('', '<Leader>Q', ':Telescope quickfixhistory<CR>', noremap)
keymap('', '<Leader>i', ':Telescope ghq list<CR>', noremap)
keymap('', '<Leader>d', ':Telescope diagnostics<CR>', noremap)
keymap('', '<Leader>f', ':Telescope fd<CR>', noremap)
keymap('', '<Leader>e', ':Telescope file_browser<CR>', noremap)
keymap('', '<Leader>J', ':Telescope jumplist<CR>', noremap)
keymap('', '<Leader>S', ':SearchSession<CR>', noremap) -- }}}
keymap('n', '<Leader>u', ':MundoToggle<CR>', noremap)
-- keymap('n', '<Leader>u', require('undotree').toggle, noremap)

keymap('n', '<Leader>t', ':terminal<CR>', noremap)
--- inc dec ---{{{
keymap('n', '-', '<C-X>', noremap)
keymap('n', '+', '<C-A>', noremap)
-- }}}
--- save, quit, reload ---{{{
keymap('', '<LocalLeader>w', ':w<CR>', noremap)
keymap('', '<LocalLeader>W', ':w!<CR>', noremap)
keymap('', '<LocalLeader>q', ':q<CR>', noremap)
keymap('', '<LocalLeader>Q', ':q!<CR>', noremap)
keymap('', '<LocalLeader>e', ':e!<CR>', noremap)
keymap('', '<LocalLeader>E', ':e .<CR>', noremap) -- }}}


-- 21_keymap.lua または設定ファイル

-- 特定の特殊キーのヘルプを表示するマッピング
vim.keymap.set('n', '<Leader>?w', ':WhichKey "<C-w>"<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>?c', ':WhichKey "C-"<CR>', { noremap = true }) -- Ctrlキーのマッピングすべて
vim.keymap.set('n', '<Leader>?a', ':WhichKey "M-"<CR>', { noremap = true }) -- Altキーのマッピングすべて

-- すべてのマッピングを表示
vim.keymap.set('n', '<Leader>?', ':WhichKey<CR>', { noremap = true })


--- カレントディレクトリでのファイラ、ターミナル起動
-- keymap('n', '<F8>e', ':<C-u>FilerCurrentDir<CR><CR>', noremap)
keymap('n', '<F8>E', ':!explorer.exe .<CR>', noremap)
keymap('n', '<F8>e', ':!tabe<CR>', noremap)
keymap('n', '<F8>x', ':<C-u>TerminalCurrentDir<CR><CR>', noremap)
keymap('n', '<F8>s', ':PackerSync<CR>', noremap)
keymap('n', '<F8>c', ':PackerCompile<CR>', noremap)
keymap('n', '<F8>m', ':Mason<CR>', noremap)
keymap('n', '<F8>t', ':TSUpdate<CR>', noremap)
keymap('n', '<F8>r', '<cmd>lua RandomScheme()<CR>', noremap)

keymap('n', 'm<Space>', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap)

keymap('', '<LocalLeader>h', '^', noremap)
keymap('', '<LocalLeader>l', '$', noremap)
keymap('', '<LocalLeader>y', ':let @q = @*<CR>', noremap)
keymap('', '<LocalLeader>p', '"qp', noremap)
keymap('', '<LocalLeader>P', '"qP', noremap)
keymap('', '<LocalLeader>/', '<Plug>(asterisk-z*)', noremap)
keymap('', [[<LocalLeader>']], '%', noremap)

keymap("t", "<Esc>", [[<C-\><C-n>]], {})
-- other leader

-- 改行コード強制変更
keymap('n', 'ml', [[:%s/\r//g<CR>]], noremap)
keymap('v', 'ml', [[:s/\r//g]], noremap)

--- 行ごと移動(VisualModeでは複数行まとめて)
keymap('n', '<C-Down>', [["zdd"zp]], noremap)
keymap('n', '<C-Up>', [["zdd<Up>"zP]], noremap)
keymap('x', '<C-Up>', '"zx<Up>"zP`[V`]', noremap)
keymap('x', '<C-Down>', '"zx"zp`[V`]', noremap)
keymap('n', '<LocalLeader>d', ':lua require("dapui").toggle()<CR>', noremap)

keymap('', '<LocalLeader>r', ':RooterToggle<CR>', noremap)

-- keymap('n', '<Leader>9', [[ddx -name=search%`bufnr('%')`<CR>']], noremap)
--- expand region ---
-- keymap('', '<LocalLeader>j', '<Plug>(expand_region_expand)', noremap)
-- keymap('', '<LocalLeader>k', '<Plug>(expand_region_shrink)', noremap)
minor_mode.create("ModeConvertCase", "<LocalLeader>").set("k", ":ConvertCaseLoop<CR>")

-- -- 初回のexpand（ノーマルモードから）
-- keymap('n', '<LocalLeader>j', '<Plug>(expand_region_expand)', noremap)

-- -- ビジュアルモードでの操作
-- keymap('v', '<LocalLeader>j', '<Plug>(expand_region_expand)', noremap)
-- keymap('v', '<LocalLeader>J', '<Plug>(expand_region_shrink)', noremap)


-- 最初のエントリー（ノーマルモードでexpand開始）
minor_mode.create('ModeExpandRegion', '<LocalLeader>').set('j', '<Plug>(expand_region_expand)')

-- 続きのコマンド（ビジュアルモードで操作）
minor_mode.create('ModeExpandRegion', '<LocalLeader>', 'x').set_multi({
    { 'j', '<Plug>(expand_region_expand)' },
    { 'J', '<Plug>(expand_region_shrink)' },
    { 'k', '<Plug>(expand_region_shrink)' },
})

minor_mode.create("ModeConvertCase", "<LocalLeader>").set("k", ":ConvertCaseLoop<CR>")
--- translate ---
keymap('x', '<LocalLeader>t', ':Translate<CR>', noremap)
keymap('n', '<LocalLeader>t', ':Translate<CR>', noremap)

--- easy align --
keymap('', 'ga', '<plug>(EasyAlign)', remap)

-- easy jump --
keymap('n', '<LocalLeader><Space>', '<Plug>(easymotion-overwin-f2)', noremap)
keymap('x', '<LocalLeader><Space>', '<Plug>(easymotion-bd-f2)', noremap)

-- --- accelated jk ---
-- keymap('n', 'j', '<Plug>(accelerated_jk_gj)', noremap)
-- keymap('n', 'k', '<Plug>(accelerated_jk_gk)', noremap)

--- visualmode togle
keymap('v', 'v', ':<C-u>VmodeToggle<CR>', noremap)

--- Shift + 矢印で領域選択 ---{{{
keymap('n', '<S-Up>', 'v<Up>', noremap)
keymap('n', '<S-Down>', 'v<Down>', noremap)
keymap('n', '<S-Left>', 'v<Left>', noremap)
keymap('n', '<S-Right>', 'v<Right>', noremap)
keymap('x', '<S-Up>', '<Up>', noremap)
keymap('x', '<S-Down>', '<Down>', noremap)
keymap('x', '<S-Left>', '<Left>', noremap)
keymap('x', '<S-Right>', '<Right>', noremap)
keymap('n', '<Leader>j', ':<C-u>OpenJunkfile<CR>', noremap)
-- }}}
--- yank ---{{{
keymap('n', 'p', '<Plug>(YankyPutAfter)', noremap)
keymap('n', 'P', '<Plug>(YankyPutBefore)', noremap)
keymap('n', 'gp', '<Plug>(YankyGPutAfter)', noremap)
keymap('n', 'gP', '<Plug>(YankyGPutBefore)', noremap)
keymap('n', '<c-n>', '<Plug>(YankyCycleForward)', noremap)
keymap('n', '<c-p>', '<Plug>(YankyCycleBackward)', noremap)
-- }}}
--- * ---{{{
keymap('', '*', '<Plug>(asterisk-z*)', remap)
keymap('', 'g*', '<Plug>(asterisk-gz*)', remap)
keymap('', 'g#', '<Plug>(asterisk-gz#)', remap)
-- }}}
-- Markdown Preview --
keymap('n', 'mp', '<Plug>MarkdownPreviewToggle', {noremap = false})
keymap('n', '<LocalLeader>x', '<Plug>(quickhl-manual-this)', noremap)
keymap('n', '<LocalLeader>X', '<Plug>(quickhl-manual-reset)', noremap)
keymap('x', '<LocalLeader>x', '<Plug>(quickhl-manual-this)', noremap)
keymap('x', '<LocalLeader>X', '<Plug>(quickhl-manual-reset)', noremap)
keymap('i', '<c-s>', '<c-v>', noremap)
keymap('i', '<s-CR>', '<br>', noremap)
keymap('n', '<LocalLeader>m', ':<C-u>MarksToggleSigns<CR>', noremap)
keymap('n', 'mm', '<Plug>(Marks-toggle)', noremap)
keymap('n', 'mA', '<Plug>(openbrowser-smart-search)', noremap)
keymap('x', 'mA', '<Plug>(openbrowser-smart-search)', noremap)

keymap('n', 'ma', '<Plug>(openbrowser-open)', noremap)
keymap('x', 'ma', '<Plug>(openbrowser-open)', noremap)

keymap('n', 'ms', ':ISwapWith<CR>', noremap)
keymap('n', 'mS', ':ISwap<CR>', noremap)


--- quick runner ---
keymap('n', 'mnn', ':Jaq<CR>', noremap)
keymap('n', 'mnf', ':Jaq float<CR>', noremap)
keymap('n', 'mnb', ':Jaq bang<CR>', noremap)
keymap('n', 'mnq', ':Jaq quickfix<CR>', noremap)
keymap('n', 'mnt', ':Jaq terminal<CR>', noremap)
keymap('n', 'mnr', ':QuickRun<CR>', noremap)
keymap('n', 'mnk', ':call quickrun#session#sweep()<CR>', noremap)

keymap('n', 'mo', ':<C-u>JumpToLine<CR>', noremap)

-- keymap('x', '<LocalLeader>9', '<plug>(QuickScopeToggle)', noremap)
keymap('n', '<LocalLeader>0', ':set readonly!<CR>', noremap)
keymap('n', '<LocalLeader>9', '<cmd>lua ToggleAutoHover()<CR>', noremap)
keymap('n', '<LocalLeader>8', ':<C-u>MigemoToggle<CR>', noremap)
keymap('n', '<LocalLeader>7', ':ColorizerToggle<CR>', noremap)
minor_mode.create("ToggleDiagDisp", "<LocalLeader>").set("`", "<cmd>lua ToggleDiagDisp(true)<CR>")

-- keymap('n', '<LocalLeader>`', '<cmd>lua ToggleDiagDisp(true)<CR>', noremap)
keymap('x', '<LocalLeader>1', ':SyntaxInfoCR>', noremap)
-- keymap("", "<LocalLeaper>`", '<cmd>lua require("lsp_lines").toggle()<CR>', noremap)
keymap('n', '<LocalLeader>6', ':set paste!<CR>', noremap)
keymap('n', '<LocalLeader>5', ':QuickScopeToggle<CR>', noremap)
keymap('n', '<Leader><Space>', '<C-W>p', noremap) -- 前にアクセスしたウィンドウに移動


keymap('n', '<C-,>', '<Plug>(milfeulle-prev)', noremap)
keymap('n', '<C-.>', '<Plug>(milfeulle-next)', noremap)
keymap('', '<C-j>', '<Plug>(edgemotion-j)', {})
keymap('', '<C-k>', '<Plug>(edgemotion-k)', {})

keymap('o', '<LocalLeader>s', ':<C-U>lua require("tsht").nodes()<CR>', {})
keymap('x', '<LocalLeader>s', ':lua require("tsht").nodes()<CR>', noremap)
keymap('n', '<LocalLeader>s', 'v:lua require("tsht").nodes()<CR>', noremap)
keymap('x', 'iu', ':lua require"treesitter-unit".select()<CR>', { noremap = true })
keymap('x', 'au', ':lua require"treesitter-unit".select(true)<CR>', { noremap = true })
keymap('o', 'iu', ':<c-u>lua require"treesitter-unit".select()<CR>', { noremap = true })
keymap('o', 'au', ':<c-u>lua require"treesitter-unit".select(true)<CR>', { noremap = true })

--
-- LSPコマンドをラップする関数を作成
-- 基本的なLSPコマンド
keymap('n', 'md', '<cmd>lua vim.lsp.buf.definition()<CR>', noremap)
keymap('n', 'mD', '<cmd>lua vim.lsp.buf.declaration()<CR>', noremap)
keymap('n', 'mi', '<cmd>lua vim.lsp.buf.implementation()<CR>', noremap)
keymap('n', 'mt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', noremap)
keymap('n', '<C-Space>', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap)
keymap('n', 'mh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', noremap)
keymap('n', 'mr', '<cmd>lua vim.lsp.buf.rename()<CR>', noremap)
keymap('n', 'mca', '<cmd>lua vim.lsp.buf.code_action()<CR>', noremap)
keymap('n', 'mf', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', noremap)
keymap('n', 'mrf', '<cmd>lua vim.lsp.buf.references()<CR>', noremap)

-- ワークスペース関連
keymap('n', 'mwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', noremap)
keymap('n', 'mwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', noremap)
keymap('n', 'mwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', noremap)

-- 診断表示
keymap('n', 'me', '<cmd>lua vim.diagnostic.open_float()<CR>', noremap)
keymap('n', 'mq', '<cmd>lua vim.diagnostic.setloclist()<CR>', noremap)

-- 診断移動用のminor_mode
minor_mode.create('DiagnosticJump', 'm').set_multi({
    -- 全ての診断
    { ']',  '<cmd>lua vim.diagnostic.goto_next()<CR>zz' },
    { '[',  '<cmd>lua vim.diagnostic.goto_prev()<CR>zz' },

    -- エラーのみ
    { 'e]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>' },
    { 'e[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>' },

    -- 警告のみ
    { 'w]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})<CR>' },
    { 'w[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})<CR>' },

    -- 情報のみ
    { 'i]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.INFO})<CR>' },
    { 'i[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.INFO})<CR>' },

    -- ヒントのみ
    { 'h]', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.HINT})<CR>' },
    { 'h[', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.HINT})<CR>' },
})

-- -- 診断移動の初期アクション付きマッピング
-- keymap('n', 'm]', '<cmd>lua vim.diagnostic.goto_next()<CR><cmd>lua require("which-key")<CR>', noremap)
-- keymap('n', 'm[', '<cmd>lua vim.diagnostic.goto_prev()<CR><cmd>lua require("which-key")<CR>', noremap)

-- -- エラーへの直接ジャンプ用ショートカット
-- keymap('n', 'me]',
--     '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR><cmd>lua require("which-key").show("DiagnosticJump")<CR>',
--     noremap)
-- keymap('n', 'me[',
--     '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR><cmd>lua require("which-key").show("DiagnosticJump")<CR>',
--     noremap)
-- キーマップ設定
-- vim.keymap.set('n', 'mD', safe_lsp_call(vim.lsp.buf.declaration), { noremap = true })
-- vim.keymap.set('n', 'md', safe_lsp_call(vim.lsp.buf.definition), { noremap = true })
-- vim.keymap.set('n', '<C-Space>', safe_lsp_call(vim.lsp.buf.hover), { noremap = true })
-- vim.keymap.set('n', 'mi', safe_lsp_call(vim.lsp.buf.implementation), { noremap = true })
-- vim.keymap.set('n', 'mwa', safe_lsp_call(vim.lsp.buf.add_workspace_folder), { noremap = true })
-- vim.keymap.set('n', 'mwr', safe_lsp_call(vim.lsp.buf.remove_workspace_folder), { noremap = true })
-- vim.keymap.set('n', 'mr', safe_lsp_call(vim.lsp.buf.rename), { noremap = true })
-- vim.keymap.set('n', 'mca', safe_lsp_call(vim.lsp.buf.code_action), { noremap = true })
-- vim.keymap.set('n', 'mf', safe_lsp_call(vim.lsp.buf.formatting), { noremap = true })

-- keymap('n', 'mD', '<cmd>lua vim.lsp.buf.declaration()<CR>', noremap)
-- keymap('n', 'md', '<cmd>lua vim.lsp.buf.definition()<CR>', noremap)
-- keymap('n', '<C-Space>', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap)
-- keymap('n', '<F9>', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap)
-- -- keymap('n', 'mm', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap)
-- keymap('n', 'mi', '<cmd>lua vim.lsp.buf.implementation()<CR>', noremap)
-- -- keymap('n', '<C-k>', '<cmd>lua m.lsp.buf.signature_help()<CR>', noremap)
-- keymap('n', 'mwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', noremap)
-- keymap('n', 'mwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', noremap)
-- keymap('n', 'mwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', noremap)
-- keymap('n', 'mD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', noremap)
-- keymap('n', 'mr', '<cmd>lua vim.lsp.buf.rename()<CR>', noremap)
-- keymap('n', 'mca', '<cmd>lua vim.lsp.buf.code_action()<CR>', noremap)
-- keymap('n', 'mr', '<cmd>lua vim.lsp.buf.references()<CR>', noremap)
-- keymap('n', 'me', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', noremap)
-- keymap('n', 'mk', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', noremap)
-- keymap('n', 'mj', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', noremap)
-- keymap('n', 'mq', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', noremap)
-- keymap('n', 'mf', '<cmd>lua vim.lsp.buf.format({async = true})<CR>', noremap)

-- 一単語をヤンクされた文字列を置きかえ<Normal>
keymap('n', 'ciy', 'ciw<C-R>0<ESC><Right>', noremap)
keymap('n', 'ciY', 'ciW<C-R>0<ESC><Right>', noremap)

keymap('i', 'jj', '<ESC>', noremap)
keymap('i', 'ｊｊ', '<ESC>', noremap)
keymap('n', 'あ', 'a', noremap)
keymap('n', 'い', 'i', noremap)
-- " -- タイポ修正<Insert> --21
-- xnoremap <C-T> <Esc><Left>"zx"zpa
-- nnoremap <C-T> <Left>"zx"pz
--

minor_mode.create("ModeConvertCase", "<LocalLeader>").set("k", ":ConvertCaseLoop<CR>")

keymap('', '<LocalLeader>y', ':let @q = @*<CR>', noremap)

if is_windows then
    -- PowerShell用の設定
    keymap('t', '<Esc>', [[<C-\><C-n>]], {})
    keymap('t', '<C-w>', [[<C-\><C-n><C-w>]], {})
end

-- アウトライン表示のトグル
keymap('n', '<Leader>o', ':SymbolsOutline<CR>', noremap)

-- フォールディング関連のキーマップ
minor_mode.create('Fold', 'z').set_multi({
    { 'a', 'za' }, -- 現在のフォールドをトグル
    { 'R', 'zR' }, -- すべてのフォールドを開く
    { 'M', 'zM' }, -- すべてのフォールドを閉じる
    { 'r', 'zr' }, -- フォールドレベルを1段階開く
    { 'm', 'zm' }, -- フォールドレベルを1段階閉じる
    { 'j', 'zj' }, -- 次のフォールドへ
    { 'k', 'zk' }, -- 前のフォールドへ
})



-- vim.cmd [[
-- function! G_callback(selected) abort
--     echo a:selected
-- endfunction
-- ]]
-- vim.cmd [[
-- let g:list = ['aaa', 'bbb', 'ccc', 'ddd', 'eee']
-- call popup_menu#open(g:list))
-- ]]

-- vim.cmd [[
--     call ddc#custom#patch_global('completionMenu', 'pum.vim')
-- ]]

-- vim.cmd [[
--     call ddc#custom#patch_global('sources', [
--      \ 'around',
--      \ 'vim-lsp',
--      \ 'file'
--      \ ])
-- ]]
-- vim.cmd [[
--     call ddc#custom#patch_global('sourceOptions', {
--      \ '_': {
--      \   'matchers': ['matcher_head'],
--      \   'sorters': ['sorter_rank'],
--      \   'converters': ['converter_remove_overlap'],
--      \ },
--      \ 'around': {'mark': 'Around'},
--      \ 'vim-lsp': {
--      \   'mark': 'LSP',
--      \   'matchers': ['matcher_head'],
--      \   'forceCompletionPattern': '\.|:|->|"\w+/*'
--      \ },
--      \ 'file': {
--      \   'mark': 'file',
--      \   'isVolatile': v:true,
--      \   'forceCompletionPattern': '\S/\S*'
--      \ }})
-- ]]
-- vim.cmd [[
--     inoremap <Tab> <Cmd>call pum#map#insert_relative(+1)<CR>
-- ]]
-- vim.cmd [[
--     inoremap <S-Tab> <Cmd>call pum#map#insert_relative(-1)<CR>
-- ]]

-- vim.cmd [[
--     call ddc#enable()
-- ]]



minor_mode.create('Fold', 'z').set_multi({
    -- 基本的なfold操作
    { 'a', 'za' }, -- 現在のfoldをトグル
    { 'R', 'zR' }, -- すべてのfoldを開く
    { 'M', 'zM' }, -- すべてのfoldを閉じる
    { 'x', 'zx' }, -- foldを更新して再適用
    -- レベル設定（関数を直接呼び出すのではなく、コマンドとして実行）
    { '0', '<cmd>lua SetFoldLevel(0)<CR>' },
    { '1', '<cmd>lua SetFoldLevel(1)<CR>' },
    { '2', '<cmd>lua SetFoldLevel(2)<CR>' },
    { '3', '<cmd>lua SetFoldLevel(3)<CR>' },
    { '4', '<cmd>lua SetFoldLevel(4)<CR>' },

})


