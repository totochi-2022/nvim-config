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
-- function ToggleAutoHover()
--     if vim.g.toggle_auto_hover == 1 then
--         vim.g.toggle_auto_hover = 0
--         print 'autohover off'
--     else
--         vim.g.toggle_auto_hover = 1
--         print 'autohover on'
--     end
-- end -- }}}

-- 03_function.lua
function ToggleAutoHover()
    -- 明示的に初期化
    if vim.g.toggle_auto_hover == nil then
        vim.g.toggle_auto_hover = 0
    end

    if vim.g.toggle_auto_hover == 1 then
        vim.g.toggle_auto_hover = 0
        -- 既存のホバーウィンドウをクリア
        vim.api.nvim_command('silent! lua vim.lsp.buf.clear_references()')
        for _, winid in pairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_config(winid).relative ~= '' then
                vim.api.nvim_win_close(winid, true)
            end
        end
        print('Auto hover: OFF')
    else
        vim.g.toggle_auto_hover = 1
        print('Auto hover: ON')
    end
end

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




-- 13_function.lua
-- グローバルな関数として定義
function SetFoldLevel(level)
    -- 現在のfoldingの状態を確認
    local current_foldenable = vim.opt.foldenable:get()

    -- foldingが無効なら有効にする
    if not current_foldenable then
        vim.opt.foldenable = true
    end

    -- foldlevelを設定
    vim.opt.foldlevel = level

    -- 必要に応じて現在のバッファを再描画
    vim.cmd('normal! zx')

    print(string.format("Fold level set to %d", level))
end

-- コマンドとして登録
vim.api.nvim_create_user_command('SetFoldLevel', function(opts)
    SetFoldLevel(tonumber(opts.args))
end, {
    nargs = 1,
    complete = function()
        return { '0', '1', '2', '3', '4', '5' }
    end
})



-- foldingの設定を動的に変更するコマンドを作成
-- vim.api.nvim_create_user_command('SetFoldLevel', function(opts)
--     vim.opt.foldlevel = tonumber(opts.args)
--     -- vim.opt.foldenable = true
-- end, {
--     nargs = 1,
--     complete = function()
--         return { '0', '1', '2', '3', '4', '5' }
--     end
-- })

-- vim.api.nvim_create_user_command('SetFoldNestMax', function(opts)
--     vim.opt.foldnestmax = tonumber(opts.args)
-- end, {
--     nargs = 1,
--     complete = function()
--         return { '1', '2', '3', '4', '5' }
--     end
-- })

-- vim.api.nvim_create_user_command('SetFoldMinLines', function(opts)
--     vim.opt.foldminlines = tonumber(opts.args)
-- end, {
--     nargs = 1,
--     complete = function()
--         return { '1', '2', '3', '4', '5' }
--     end
-- })
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
function ConversionMenu()
    local menu = require('popup_menu')
    local items = {
        {
            text = '[e]ncoding',
            key = 'e',
            submenus = {
                {
                    text = '[u]tf8',
                    key = 'u',
                    submenus = {
                        { text = '[n]ormal', key = 'n', cmd = 'set fileencoding=utf-8' },
                        { text = '[b]om',    key = 'b', cmd = 'set fileencoding=utf-8-bom' },
                        { text = '[c]heck',  key = 'c', cmd = 'set fileencoding?' },
                    }
                },
                {
                    text = '[j]apanese',
                    key = 'j',
                    submenus = {
                        { text = '[s]jis',  key = 's', cmd = 'set fileencoding=cp932' },
                        { text = '[e]ucjp', key = 'e', cmd = 'set fileencoding=euc-jp' },
                    }
                },
            }
        },
        {
            text = '[l]ine ending',
            key = 'l',
            submenus = {
                {
                    text = '[f]ormat',
                    key = 'f',
                    submenus = {
                        { text = '[w]indows', key = 'w', cmd = 'set fileformat=dos' },
                        { text = '[u]nix',    key = 'u', cmd = 'set fileformat=unix' },
                        { text = '[m]ac',     key = 'm', cmd = 'set fileformat=mac' },
                    }
                },
                {
                    text = '[c]onvert',
                    key = 'c',
                    submenus = {
                        { text = 'crlf to [l]f', key = 'l', cmd = '%s/\\r\\n/\\n/g' },
                        { text = '[r]emove cr',  key = 'r', cmd = '%s/\\r//g' },
                    }
                },
                { text = '[s]tatus', key = 's', cmd = 'set fileformat?' },
            }
        },
    }
    menu.open(items)
end



-- local function convert_windows_path_to_wsl_path(win_path)
--     local handle = io.popen("wslpath '" .. win_path:gsub("\\", "\\\\") .. "'")
--     local result = handle:read("*a")
--     handle:close()
--     return result:gsub("\n", "")
-- end

-- vim.api.nvim_create_autocmd("VimEnter", {
--     callback = function()
--         local files = vim.fn.argv()
--         for i, file in ipairs(files) do
--             files[i] = convert_windows_path_to_wsl_path(file)
--         end
--         vim.cmd("edit " .. table.concat(files, " "))
--     end,
-- })

if vim.g.neovide and vim.fn.executable('wslpath') == 1 then
  vim.api.nvim_create_autocmd({"BufNewFile"}, {
    callback = function(ev)
      local file = ev.file
      if file and #file > 0 then
        if file:match("^\\\\wsl%.localhost\\[^\\]+\\") then
          -- WSL UNCパスの場合は直接変換
          local path = file:gsub("^\\\\wsl%.localhost\\[^\\]+\\", ""):gsub("\\", "/")
          vim.cmd("bdelete")
          vim.cmd("edit /" .. path)
          vim.cmd("filetype detect")  -- ファイルタイプを再判定
        elseif file:match("^%a:") or file:match("^\\\\[^\\]+\\") then
          local handle = io.popen('wslpath "' .. file .. '"')
          if handle then
            local wsl_path = handle:read("*a"):gsub("\n$", "")
            handle:close()
            if wsl_path and wsl_path ~= file then
              vim.cmd("bdelete")
              vim.cmd("edit " .. wsl_path)
              vim.cmd("filetype detect")  -- ファイルタイプを再判定
            end
          end
        end
      end
    end
  })
end

