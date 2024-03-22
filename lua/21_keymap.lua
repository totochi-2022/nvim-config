--- local value{{{
local noremap = { noremap = true }
local remap = { noremap = false }
-- local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap
local minor_mode = require('rc/minor_mode')
-- }}}
--- initialize{{{
keymap('', 's', '', noremap)
-- keymap('', ',', '', noremap)
-- keymap('', '#', '', noremap)
-- }}}
--- set leader, localleader{{{
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
--- NERDCommenter{{{
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
keymap('', '<Leader>a', ':Telescope <CR>', noremap)
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

--- カレントディレクトリでのファイラ、ターミナル起動
keymap('n', '<F8>e', ':<C-u>FilerCurrentDir<CR><CR>', noremap)
keymap('n', '<F8>E', ':!explorer.exe .<CR>', noremap)
keymap('n', '<F8>x', ':<C-u>TerminalCurrentDir<CR><CR>', noremap)
keymap('n', '<F8>s', ':PackerSync<CR>', noremap)
keymap('n', '<F8>c', ':PackerCompile<CR>', noremap)
keymap('n', '<F8>m', ':Mason<CR>', noremap)
keymap('n', '<F8>t', ':TSUpdate<CR>', noremap)
keymap('n', '<F8>r', '<cmd>lua RandomScheme()<CR>', noremap)
keymap('n', '<F4>', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap)
keymap('n', 'm<Space>', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap)

keymap('', '<LocalLeader>y', ':let @q = @*<CR>', noremap)
keymap('', '<LocalLeader>h', '^', noremap)
keymap('', '<LocalLeader>l', '$', noremap)
keymap('', '<LocalLeader>y', ':let @q = @*<CR>', noremap)
keymap('', '<LocalLeader>p', '"qp', noremap)
keymap('', '<LocalLeader>P', '"qP', noremap)
keymap('', '<LocalLeader>/', '<Plug>(asterisk-z*)', noremap)
keymap('', [[<LocalLeader>']], '%', noremap)

keymap("t", "<Esc>", [[<C-\><C-n>]], {})
-- other leader

--- 行ごと移動(VisualModeでは複数行まとめて)
keymap('n', '<C-Down>', [["zdd"zp]], noremap)
keymap('n', '<C-Up>', [["zdd<Up>"zP]], noremap)
keymap('x', '<C-Up>', '"zx<Up>"zP`[V`]', noremap)
keymap('x', '<C-Down>', '"zx"zp`[V`]', noremap)


keymap('', '<LocalLeader>r', ':RooterToggle<CR>', noremap)

-- keymap('n', '<Leader>9', [[ddx -name=search%`bufnr('%')`<CR>']], noremap)
--- expand region ---
keymap('', 'L', '<Plug>(expand_region_expand)', noremap)
keymap('', 'H', '<Plug>(expand_region_shrink)', noremap)

--- translate ---
keymap('x', '<LocalLeader>t', ':Translate<CR>', noremap)
keymap('n', '<LocalLeader>t', ':Translate<CR>', noremap)

--- easy align --
keymap('', 'ga', '<plug>(EasyAlign)', remap)

-- easy jump --
keymap('n', '<LocalLeader><Space>', '<Plug>(easymotion-overwin-f2)', noremap)
keymap('x', '<LocalLeader><Space>', '<Plug>(easymotion-bd-f2)', noremap)

--- accelated jk ---
keymap('n', 'j', '<Plug>(accelerated_jk_gj)', noremap)
keymap('n', 'k', '<Plug>(accelerated_jk_gk)', noremap)

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
keymap('n', 'mp', '<Plug>MarkdownPreviewToggle', noremap)
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
keymap('x', '<LocalLeader>01', ':SyntaxInfoCR>', noremap)
-- keymap("", "<LocalLeaper>`", '<cmd>lua require("lsp_lines").toggle()<CR>', noremap)
keymap('n', '<LocalLeader>06', ':set paste!<CR>', noremap)
keymap('n', '<LocalLeader>05', ':QuickScopeToggle<CR>', noremap)
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
keymap('n', 'mD', '<cmd>lua vim.lsp.buf.declaration()<CR>', noremap)
keymap('n', 'md', '<cmd>lua vim.lsp.buf.definition()<CR>', noremap)
keymap('n', '<C-Space>', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap)
keymap('n', '<F9>', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap)
-- keymap('n', 'mm', '<cmd>lua vim.lsp.buf.hover()<CR>', noremap)
keymap('n', 'mi', '<cmd>lua vim.lsp.buf.implementation()<CR>', noremap)
-- keymap('n', '<C-k>', '<cmd>lua m.lsp.buf.signature_help()<CR>', noremap)
keymap('n', 'mwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', noremap)
keymap('n', 'mwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', noremap)
keymap('n', 'mwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', noremap)
keymap('n', 'mD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', noremap)
keymap('n', 'mr', '<cmd>lua vim.lsp.buf.rename()<CR>', noremap)
keymap('n', 'mca', '<cmd>lua vim.lsp.buf.code_action()<CR>', noremap)
keymap('n', 'mr', '<cmd>lua vim.lsp.buf.references()<CR>', noremap)
keymap('n', 'me', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', noremap)
keymap('n', 'mk', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', noremap)
keymap('n', 'mj', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', noremap)
keymap('n', 'mq', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', noremap)
keymap('n', 'mf', '<cmd>lua vim.lsp.buf.formatting()<CR>', noremap)

-- 一単語をヤンクされた文字列を置きかえ<Normal>
keymap('n', 'ciy', 'ciw<C-R>0<ESC><Right>', noremap)
keymap('n', 'ciY', 'ciW<C-R>0<ESC><Right>', noremap)

keymap('i', 'jj', '<ESC>', noremap)
keymap('n', 'あ', 'a', noremap)
keymap('n', 'い', 'i', noremap)
-- " -- タイポ修正<Insert> --21
-- xnoremap <C-T> <Esc><Left>"zx"zpa
-- nnoremap <C-T> <Left>"zx"pz
--

minor_mode.create("ModeConvertCase", "<LocalLeader>").set("k", ":ConvertCaseLoop<CR>")

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
