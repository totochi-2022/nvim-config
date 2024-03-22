---- Lua Function
--- ToggleDiagDisp   diagnostic 表示のトグル{{{
function ToggleDiagDisp(toggle)
    local state = vim.g.diag_toggle_state
    if toggle then
        state = state + 1
    else
        state = 1
    end
    if state > 3 then
        state = 1
    end
    if state == 1 then
        vim.diagnostic.config({
            virtual_text = false,
            virtual_lines = false,
        })
    elseif state == 2 then
        vim.diagnostic.config({
            virtual_text = false,
            virtual_lines = true,
        })
    elseif state == 3 then
        vim.diagnostic.config({
            virtual_text = true,
            virtual_lines = false,
        })
    end
    vim.g.diag_toggle_state = state
end

ToggleDiagDisp(false)

--}}}
--- ToggleAutoHover   cmpの自動ホバー表示のトグル{{{
function ToggleAutoHover()
    if vim.g.toggle_auto_hover == 1 then
        vim.g.toggle_auto_hover = 0
        print 'autohover off'
    else
        vim.g.toggle_auto_hover = 1
        print 'autohover on'
    end
end -- }}}

function RandomScheme()
    local col_sh = Colorschemes[math.random(table.maxn(Colorschemes))]
    vim.cmd('colorscheme ' .. col_sh)
    print(col_sh)
end

---- VimL Function
--- OpenJunkfile{{{
vim.cmd [[
function! s:open_junkfile()
  let l:junk_dir = g:dir_setting['junk'] . strftime('/%y/%m')
  if !isdirectory(l:junk_dir)
    call mkdir(l:junk_dir, 'p')
  endif
  let l:filename = input('junk code: ', l:junk_dir.strftime('/%y%m%d-%H%M.'))
  if l:filename != ''
    execute 'edit ' . l:filename
  endif
endfunction
command! OpenJunkfile call s:open_junkfile()
]]
--}}}
--- VmodeToggle{{{
vim.cmd [[
function! s:vmode_toggle()
  let s:vmode_now = visualmode()
    if s:vmode_now ==# "v"
      call feedkeys("gvV", "n")
    elseif s:vmode_now ==# "V"
      call feedkeys("gv", "n")
    elseif s:vmode_now == ""
      call feedkeys("gvv", "n")
    endif
endfunction
command! VmodeToggle call s:vmode_toggle()
]]
--}}}
--- MigemoToggle {{{
vim.cmd [[
function! s:migemo_mapping(verbose)
  if g:incsearch_use_migemo == 0
    map ?  <Plug>(incsearch-backward)
    map /  <Plug>(incsearch-forward)
    if a:verbose
      echo 'incsearch no use migemo.'
    end
  else
    map ?  <Plug>(incsearch-migemo-?)
    map /  <Plug>(incsearch-migemo-/)
    if a:verbose
       echo 'incsearch use migemo.'
    end
  endif
endfunction

function! s:migemo_toggle()
  let g:incsearch_use_migemo = (g:incsearch_use_migemo == 0 ? 1 : 0)
    call s:migemo_mapping(1)
  endfunction
call s:migemo_mapping(0)
command! MigemoToggle call s:migemo_toggle()
]]
--}}}
--- SynaxInfo  カーソル位置のsyntax情報の表示{{{
-- https://cohama.hateblo.jp/entry/2013/08/11/020849
vim.cmd [[
function! s:get_syn_id(transparent)
  let synid = synID(line("."), col("."), 1)
  if a:transparent
    return synIDtrans(synid)
  else
    return synid
  endif
endfunction
function! s:get_syn_attr(synid)
  let name = synIDattr(a:synid, "name")
  let ctermfg = synIDattr(a:synid, "fg", "cterm")
  let ctermbg = synIDattr(a:synid, "bg", "cterm")
  let guifg = synIDattr(a:synid, "fg", "gui")
  let guibg = synIDattr(a:synid, "bg", "gui")
  return {
        \ "name": name,
        \ "ctermfg": ctermfg,
        \ "ctermbg": ctermbg,
        \ "guifg": guifg,
        \ "guibg": guibg}
endfunction
function! s:get_syn_info()
  let baseSyn = s:get_syn_attr(s:get_syn_id(0))
  echo "name: " . baseSyn.name .
        \ " ctermfg: " . baseSyn.ctermfg .
        \ " ctermbg: " . baseSyn.ctermbg .
        \ " guifg: " . baseSyn.guifg .
        \ " guibg: " . baseSyn.guibg
  let linkedSyn = s:get_syn_attr(s:get_syn_id(1))
  echo "link to"
  echo "name: " . linkedSyn.name .
        \ " ctermfg: " . linkedSyn.ctermfg .
        \ " ctermbg: " . linkedSyn.ctermbg .
        \ " guifg: " . linkedSyn.guifg .
        \ " guibg: " . linkedSyn.guibg
endfunction
command! SyntaxInfo call s:get_syn_info()
]] -- }}}
--- SweepQuickrunProcess{{{
vim.cmd [[
function! s:sweep_quickrun_process() "
  if quickrun#is_running() == 0
    echo 'quickrun: no process running.'
  else
    call quickrun#sweep_sessions()
    echo 'quickrun: try sweep.'
  endif
endfunction
command! SweepQuickrunProcesss call s:sweep_quickrun_processs()
]]
--}}}
--- FilerCurrentDir{{{
vim.cmd [[
function! s:filer_current_dir()
  if has("unix")
    execute "!nautilus --select %:p &"
  elseif has("win64")
    execute "!explorer %:h"
  endif
endfunction
command! FilerCurrentDir call s:filer_current_dir()
]]
--}}}
--- TerminalCurrentDir{{{
vim.cmd [[
function! s:terminal_current_dir()
  if has("unix")
    execute "!gnome-terminal --working-directory %:p:h"
  elseif has("win64")
    execute "!cmd %:h"
  endif
endfunction
command! TerminalCurrentDir call s:terminal_current_dir()
]]
--}}}


vim.cmd [[
function! s:get_syn_id(transparent)
  let synid = synID(line("."), col("."), 1)
  if a:transparent
    return synIDtrans(synid)
  else
    return synid
  endif
endfunction
function! s:get_syn_attr(synid)
  let name = synIDattr(a:synid, "name")
  let ctermfg = synIDattr(a:synid, "fg", "cterm")
  let ctermbg = synIDattr(a:synid, "bg", "cterm")
  let guifg = synIDattr(a:synid, "fg", "gui")
  let guibg = synIDattr(a:synid, "bg", "gui")
  return {
        \ "name": name,
        \ "ctermfg": ctermfg,
        \ "ctermbg": ctermbg,
        \ "guifg": guifg,
        \ "guibg": guibg}
endfunction
function! s:get_syn_info()
  let baseSyn = s:get_syn_attr(s:get_syn_id(0))
  echo "name: " . baseSyn.name .
        \ " ctermfg: " . baseSyn.ctermfg .
 ss       \ " ctermbg: " . baseSyn.ctermbg .
        \ " guifg: " . baseSyn.guifg .
        \ " guibg: " . baseSyn.guibg
  let linkedSyn = s:get_syn_attr(s:get_syn_id(1))
  echo "link to"
  echo "name: " . linkedSyn.name .
        \ " ctermfg: " . linkedSyn.ctermfg .
        \ " ctermbg: " . linkedSyn.ctermbg .
        \ " guifg: " . linkedSyn.guifg .
        \ " guibg: " . linkedSyn.guibg
endfunction
command! SyntaxInfo call s:get_syn_info()
]]


-- vim.cmd [[
--   autocmd!
--   autocmd InsertEnter * silent call chansend(v:stderr, '[<r')
--   autocmd InsertLeave * silent call chansend(v:stderr, '[<s[<0t')
--   autocmd VimLeave * silent call chansend(v:stderr, '0t[<s')
-- augroup END
-- ]]

--
-- "======== 変更点へジャンプ =================================={{{
--
-- " Submode:jump-modify{{{
-- " {Enter:} <localjeader>o, <LocalLeader>i
-- call submode#enter_with('jump-modify', 'n', '', '<LocalLeader>i', 'g,zvzz')
-- call submode#enter_with('jump-modify', 'n', '', '<LocalLeader>o', 'g;zvzz')
--
-- " {Leave}: <Space>
-- call submode#leave_with('jump-modify', 'n', '', '<LocalLeader>')
--
-- " {Toggle}: i, o
-- call submode#map('jump-modify', 'n', '', 'i', 'g,zvzz')
-- call submode#map('jump-modify', 'n', '', 'o', 'g;zvzz')
--
-- " {List(Denite)}: <Leader>
-- call submode#map('jump-modify', 'n', '', '<Leader>', '<CR>:Denite change<CR>')
-- "}}}
--
-- "}}}
-- "======== こじんまりしたkeybind =============================
-- " -- タイポ修正<Insert> --
-- xnoremap <C-T> <Esc><Left>"zx"zpa
-- nnoremap <C-T> <Left>"zx"pz
--
-- " -- 一単語をヤンクされた文字列を置きかえ<Normal> --
-- nnoremap ciy ciw<C-R>0<ESC><Right>
-- nnoremap ciY ciW<C-R>0<ESC><Right>
--
