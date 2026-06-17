---- Lua Function
--- ToggleDiagDisp   diagnostic 表示のトグル（lsp_lines無し版）{{{
-- NOTE: This function has been replaced by the toggle library
-- The functionality is now handled in toggle_config.lua
-- Keeping this for backward compatibility if needed

-- Legacy function - redirects to new toggle library
function ToggleDiagDisp(toggle, show_message)
    -- Deprecated: Use new toggle system (<LocalLeader>0 → d)
    print("Use new toggle system: <LocalLeader>0 → d")
end

-- NOTE: Initialization is now handled in 22_toggle.lua

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
-- NOTE: This function has been replaced by the toggle library
-- Legacy function - redirects to new toggle library
function ToggleAutoHover()
    -- Deprecated: Use new toggle system (<LocalLeader>0 → h)
    print("Use new toggle system: <LocalLeader>0 → h")
end

function RandomScheme(silent)
    -- Colorschemes変数の存在確認
    if not Colorschemes or type(Colorschemes) ~= 'table' or #Colorschemes == 0 then
        if not silent then
            print("Error: No colorschemes available!")
        end
        return
    end

    -- プロセスIDとメモリアドレスを組み合わせたユニークなシード
    local pid = vim.fn.getpid()
    local addr = tostring({}):match("0x(%w+)") or "0"
    local hrtime = vim.loop.hrtime()
    local seed = pid + tonumber(addr, 16) + hrtime % 1000000

    math.randomseed(seed)

    local random_num = math.random(#Colorschemes)
    local col_sh = Colorschemes[random_num]

    vim.cmd('colorscheme ' .. col_sh)

    -- フローティングウィンドウの背景色を本体と同じに設定
    vim.defer_fn(function()
        local normal_bg = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'bg')
        if normal_bg == '' then
            normal_bg = 'NONE'
        end

        -- FloatBorderの背景色のみを調整（線の色はそのまま）
        local current_float_border = vim.api.nvim_get_hl(0, { name = 'FloatBorder' })
        vim.api.nvim_set_hl(0, 'FloatBorder', {
            fg = current_float_border.fg, -- 線の色はそのまま維持
            bg = normal_bg,               -- 背景色のみを本体と同じにする
        })

        -- フローティングウィンドウ内容の背景色も調整
        vim.api.nvim_set_hl(0, 'NormalFloat', {
            bg = normal_bg, -- フローティング内容の背景色
        })
    end, 50)                -- カラースキーム適用後に少し遅延して実行

    if not silent then
        print(col_sh)
    end
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
--- VmodeToggle (Lua版){{{
local function vmode_toggle()
    local current_mode = vim.fn.visualmode()

    if current_mode == "v" then
        -- 文字ビジュアル → 行ビジュアル
        vim.fn.feedkeys("gvV", "n")
    elseif current_mode == "V" then
        -- 行ビジュアル → 矩形ビジュアル
        vim.fn.feedkeys("gv\022", "n") -- \022 は <C-v>
    elseif current_mode == "\022" then -- <C-v> (矩形ビジュアル)
        -- 矩形ビジュアル → 文字ビジュアル
        vim.fn.feedkeys("gvv", "n")
    end
end

-- グローバル関数として公開
_G.VmodeToggle = vmode_toggle

-- コマンド定義
vim.api.nvim_create_user_command("VmodeToggle", function()
    vmode_toggle()
end, { desc = "ビジュアルモードの種類を切り替え" })
--}}}

--- FileLocalJumpList ファイル内ジャンプ履歴{{{
-- ファイル内のジャンプ履歴を管理する
vim.cmd [[
" ファイル内ジャンプ履歴の実装
let g:file_local_jumplist = {}

function! s:add_to_file_jumplist()
  let l:bufnr = bufnr('%')
  let l:pos = [line('.'), col('.')]

  " バッファごとの履歴を初期化
  if !has_key(g:file_local_jumplist, l:bufnr)
    let g:file_local_jumplist[l:bufnr] = {'list': [], 'current': -1}
  endif

  let l:jumplist = g:file_local_jumplist[l:bufnr]

  " 同じ位置の場合は追加しない
  if len(l:jumplist.list) > 0 && l:jumplist.list[-1] == l:pos
    return
  endif

  " 現在位置より後の履歴を削除（新しいブランチ）
  if l:jumplist.current < len(l:jumplist.list) - 1
    let l:jumplist.list = l:jumplist.list[:l:jumplist.current]
  endif

  " 新しい位置を追加
  call add(l:jumplist.list, l:pos)
  let l:jumplist.current = len(l:jumplist.list) - 1

  " 履歴が長すぎる場合は古いものを削除
  if len(l:jumplist.list) > 100
    let l:jumplist.list = l:jumplist.list[1:]
    let l:jumplist.current -= 1
  endif
endfunction

function! s:file_jump_back()
  let l:bufnr = bufnr('%')
  if !has_key(g:file_local_jumplist, l:bufnr)
    echo "No file jump history"
    return
  endif

  let l:jumplist = g:file_local_jumplist[l:bufnr]
  if l:jumplist.current <= 0
    echo "Already at oldest position"
    return
  endif

  let l:jumplist.current -= 1
  let l:pos = l:jumplist.list[l:jumplist.current]
  call cursor(l:pos[0], l:pos[1])
  echo "File jump back (" . (l:jumplist.current + 1) . "/" . len(l:jumplist.list) . ")"
endfunction

function! s:file_jump_forward()
  let l:bufnr = bufnr('%')
  if !has_key(g:file_local_jumplist, l:bufnr)
    echo "No file jump history"
    return
  endif

  let l:jumplist = g:file_local_jumplist[l:bufnr]
  if l:jumplist.current >= len(l:jumplist.list) - 1
    echo "Already at newest position"
    return
  endif

  let l:jumplist.current += 1
  let l:pos = l:jumplist.list[l:jumplist.current]
  call cursor(l:pos[0], l:pos[1])
  echo "File jump forward (" . (l:jumplist.current + 1) . "/" . len(l:jumplist.list) . ")"
endfunction

" コマンド定義
command! FileJumpBack call s:file_jump_back()
command! FileJumpForward call s:file_jump_forward()

" 自動的に履歴に追加（大きなジャンプの時のみ）
augroup FileLocalJumpList
  autocmd!
  autocmd CursorMoved * if abs(line('.') - line("''")) > 5 | call s:add_to_file_jumplist() | endif
augroup END

" ジャンプモード切り替え（ファイル内 vs グローバル）
let g:jump_mode_file_local = 1

function! s:toggle_jump_mode()
  let g:jump_mode_file_local = !g:jump_mode_file_local
  if g:jump_mode_file_local
    echo "Jump Mode: File Local (Ctrl+O/Ctrl+I → ファイル内履歴)"
    " Ctrl+O/Ctrl+Iをファイル内版に変更
    nnoremap <C-o> :FileJumpBack<CR>
    nnoremap <C-i> :FileJumpForward<CR>
  else
    echo "Jump Mode: Global (Ctrl+O/Ctrl+I → グローバル履歴)"
    " 元のCtrl+O/Ctrl+Iに戻す
    nunmap <C-o>
    nunmap <C-i>
  endif
endfunction

" 起動時にファイル内モードを設定
augroup FileLocalJumpListInit
  autocmd!
  autocmd VimEnter * call s:toggle_jump_mode()
augroup END

command! ToggleJumpMode call s:toggle_jump_mode()
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

function! s:get_syn_info_enhanced()
  echo "=== 構文情報 ==="
  echo "Position: " . line('.') . ":" . col('.') . " | " . get(g:, 'colors_name', '(none)')
  echo ""

  " TreeSitter情報
  try
    let ts_info = luaeval('vim.treesitter.get_captures_at_cursor(0)')
    if !empty(ts_info)
      for capture in ts_info
        if capture == 'spell'
          continue  " spellは無視
        endif

        let hl_group = '@' . capture
        let hl_id = hlID(hl_group)

        " 直接の色
        let hl_fg = synIDattr(hl_id, 'fg', 'gui')
        let hl_bg = synIDattr(hl_id, 'bg', 'gui')

        " リンク先の色
        let link_to = synIDattr(synIDtrans(hl_id), 'name')
        if !empty(link_to) && link_to != hl_group
          let link_fg = synIDattr(hlID(link_to), 'fg', 'gui')
          let link_bg = synIDattr(hlID(link_to), 'bg', 'gui')

          if !empty(link_fg) || !empty(link_bg)
            echo capture . " → " . link_to . " | fg:" . (empty(link_fg) ? "default" : link_fg) . " bg:" . (empty(link_bg) ? "default" : link_bg)
          else
            echo capture . " → " . link_to . " | no colors"
          endif
        else
          if !empty(hl_fg) || !empty(hl_bg)
            echo capture . " | fg:" . (empty(hl_fg) ? "default" : hl_fg) . " bg:" . (empty(hl_bg) ? "default" : hl_bg)
          else
            echo capture . " | no colors"
          endif
        endif
      endfor
    else
      echo "No TreeSitter captures"
    endif
  catch
    echo "TreeSitter: not available"
  endtry
endfunction

command! SyntaxInfo call s:get_syn_info()
command! SyntaxInfoEnhanced call s:get_syn_info_enhanced()
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

-- Windows path to WSL path conversion
function ConvertWindowsPath(win_path)
    -- 外部コマンドでパス変換（将来的にカスタムスクリプトに置き換え可能）
    local converter_cmd = "wslpath" -- 将来的にはカスタムスクリプトのパスに変更可能

    local handle = io.popen(converter_cmd .. ' "' .. win_path .. '" 2>/dev/null')
    if handle then
        local wsl_path = handle:read("*a"):gsub("\n$", "")
        handle:close()

        -- 変換が成功した場合のみ変換結果を返す
        if wsl_path ~= "" then
            return wsl_path
        end
    end
    return win_path
end

-- グローバル変数: 自動パス変換モードの状態
vim.g.auto_windows_path_mode = false

-- ファイル存在チェック関数
function FileExists(path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == 'file'
end

-- Windowsパス判定関数
function IsWindowsPath(path)
    return path:match("^%a:[/\\]") or path:match("^\\\\")
end

-- Windows Terminalでは、ドラッグ&ドロップは単純なテキスト貼り付けとして処理される
-- そのため、InsertCharPreイベントなどで文字入力を監視する必要がある

-- autocmdのIDを保存する変数
local auto_path_autocmd_id = nil

-- 自動パス変換モードのトグル関数
-- NOTE: This function has been replaced by the toggle library
-- Legacy function - redirects to new toggle library
function ToggleAutoWindowsPathMode()
    -- Deprecated: Use new toggle system (<LocalLeader>0 → w)
    print("Use new toggle system: <LocalLeader>0 → w")
end

-- input()を使ったWindowsパス入力コマンド（存在チェック付き）
vim.api.nvim_create_user_command('Ew', function()
    local path = vim.fn.input('Windows path: ')
    if path and #path > 0 then
        local converted_path = ConvertWindowsPath(path)
        if FileExists(converted_path) then
            vim.cmd('edit ' .. vim.fn.fnameescape(converted_path))
        else
            vim.api.nvim_err_writeln("File does not exist: " .. converted_path)
        end
    end
end, {})

-- 小文字でも使えるようにabbreviation追加
vim.cmd('cnoreabbrev ew Ew')

if vim.g.neovide and vim.fn.executable('wslpath') == 1 then
    vim.api.nvim_create_autocmd({ "BufNewFile" }, {
        callback = function(ev)
            local file = ev.file
            if file and #file > 0 then
                if file:match("^\\\\wsl%.localhost\\[^\\]+\\") then
                    -- WSL UNCパスの場合は直接変換
                    local path = file:gsub("^\\\\wsl%.localhost\\[^\\]+\\", ""):gsub("\\", "/")
                    vim.cmd("bdelete")
                    vim.cmd("edit /" .. path)
                    vim.cmd("filetype detect") -- ファイルタイプを再判定
                elseif file:match("^%a:") or file:match("^\\\\[^\\]+\\") then
                    local handle = io.popen('wslpath "' .. file .. '"')
                    if handle then
                        local wsl_path = handle:read("*a"):gsub("\n$", "")
                        handle:close()
                        if wsl_path and wsl_path ~= file then
                            vim.cmd("bdelete")
                            vim.cmd("edit " .. wsl_path)
                            vim.cmd("filetype detect") -- ファイルタイプを再判定
                        end
                    end
                end
            end
        end
    })
end

-- 診断モード用フック関数
-- モード開始時に全エラー表示に切り替え
function DiagModeEnter()
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

-- minor-modeを使った連続削除のundo統合は21_keymap.luaで設定

-- 診断設定を適用するヘルパー関数
local function apply_diagnostic_config(show_underline)
    vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        underline = show_underline or false,
        update_in_insert = false,
        severity_sort = true,
    })
end


-- モード終了時に元の表示に戻す
function DiagModeExit()
    -- グローバル変数から診断状態を取得して復元
    local current_state = vim.g.toggle_diagnostic_state or 'signs_only'

    -- tiny-inline-diagnosticの制御
    local tiny_ok, tiny = pcall(require, "tiny-inline-diagnostic")

    -- 状態に応じて適切な診断設定を復元
    if current_state == 'signs_only' then
        apply_diagnostic_config(false)
        if tiny_ok then tiny.disable() end
    elseif current_state == 'cursor_only' then
        apply_diagnostic_config(false)
        if tiny_ok then tiny.enable() end
    elseif current_state == 'full_with_underline' then
        -- 全表示（既に設定済みなので何もしない）
    end
    print("診断表示を元に戻しました")
end

-- Jaq実行プロセスのキル関数（改造版jaq-nvim対応）
function JaqKill()
    local ok, jaq_nvim = pcall(require, 'jaq-nvim')
    if ok and jaq_nvim.kill_current then
        return jaq_nvim.kill_current()
    else
        print("jaq-nvim kill function not available")
    end
end

function JaqKillAll()
    local ok, jaq_nvim = pcall(require, 'jaq-nvim')
    if ok and jaq_nvim.kill_all then
        return jaq_nvim.kill_all()
    else
        print("jaq-nvim kill_all function not available")
    end
end

-- Jaqプロセス一覧表示関数
function JaqList()
    local ok, jaq_nvim = pcall(require, 'jaq-nvim')
    if ok and jaq_nvim.list_processes then
        return jaq_nvim.list_processes()
    else
        print("jaq-nvim list function not available")
    end
end

-- コマンド登録（改造版と重複しないように削除）
-- プラグイン側でコマンド登録されるため、ここでは関数のみ定義

-- ============================================================
-- draw.io連携（クリップボード貼り付け + 再編集）
-- ============================================================
-- non-Store版 draw.io desktop の実行ファイル
local DRAWIO_EXE = '/mnt/c/Program Files/draw.io/draw.io.exe'

-- [draw.io] クリップボードのSVG/XMLをassets/に保存しmarkdownに埋め込む（貼り付け）
-- 使い方: draw.ioで図を選択しコピー → markdownでカーソル位置にキー
function _G.PasteDrawio()
    local clip = vim.fn.getreg('+')
    if clip == nil or clip == '' then clip = vim.fn.getreg('*') end

    local is_svg = clip:match('<svg')
    local is_xml = clip:match('<mxfile') or clip:match('<mxGraphModel')
    if not is_svg and not is_xml then
        vim.notify('クリップボードにdraw.io/SVGデータが見つかりません', vim.log.levels.WARN)
        return
    end

    local base = vim.fn.expand('%:p:h')
    if base == '' or vim.bo.buftype ~= '' then
        vim.notify('保存先が不明です（名前付きで保存してから実行してください）', vim.log.levels.WARN)
        return
    end
    local dir = base .. '/assets'
    vim.fn.mkdir(dir, 'p')

    local ts = os.date('%Y%m%d-%H%M%S')
    local is_typst = vim.bo.filetype == 'typst' or vim.fn.expand('%:e') == 'typ'
    local fname, link
    if is_svg then
        -- Editable SVG: 表示も再編集も可能。画像として埋め込む
        fname = ts .. '.drawio.svg'
        if is_typst then
            link = '#image("assets/' .. fname .. '")'
        else
            link = '![](assets/' .. fname .. ')'
        end
    else
        -- XMLのみ: 再編集可能だが表示不可（リンク/コメントのみ）
        fname = ts .. '.drawio'
        if is_typst then
            link = '// drawio: assets/' .. fname
        else
            link = '[drawio diagram](assets/' .. fname .. ')'
        end
    end

    vim.fn.writefile(vim.split(clip, '\n', { plain = true }), dir .. '/' .. fname)
    vim.api.nvim_put({ link }, 'c', true, true)
    vim.notify('保存: assets/' .. fname .. (is_xml and '（XMLは表示不可。draw.ioで「Copy as SVG」推奨）' or ''),
        vim.log.levels.INFO)
end

-- [draw.io] カーソル下の .drawio(.svg) を draw.io で開く（再編集）
function _G.OpenDrawio()
    if vim.fn.executable(DRAWIO_EXE) == 0 then
        vim.notify('draw.io.exeが見つかりません: ' .. DRAWIO_EXE, vim.log.levels.ERROR)
        return
    end

    -- カーソル下のファイル名。なければ現在行から各記法でパスを抽出
    -- （markdown ](path) / typst #image("path") / コメント drawio: path）。
    local cfile = vim.fn.expand('<cfile>')
    cfile = cfile:gsub('^["\']', ''):gsub('["\']$', '') -- typstのクォート除去
    if cfile == '' then
        local line = vim.api.nvim_get_current_line()
        cfile = line:match('%]%(([^)]+)%)')
            or line:match('image%(%s*"([^"]+)"')
            or line:match('drawio:%s*(%S+)')
            or ''
    end
    if cfile == '' then
        vim.notify('カーソル下にファイルパスがありません', vim.log.levels.WARN)
        return
    end

    -- 相対パスは編集中ファイル基準で絶対化
    local path = cfile
    if not path:match('^[/~]') then
        path = vim.fn.expand('%:p:h') .. '/' .. cfile
    end
    path = vim.fn.fnamemodify(path, ':p')
    if vim.fn.filereadable(path) == 0 then
        vim.notify('ファイルが見つかりません: ' .. path, vim.log.levels.WARN)
        return
    end

    -- WSL → Windowsパスに変換して draw.io に渡す
    local winpath = vim.fn.system({ 'wslpath', '-w', path }):gsub('%s+$', '')
    vim.fn.jobstart({ DRAWIO_EXE, winpath }, { detach = true })
    vim.notify('draw.ioで開く: ' .. vim.fn.fnamemodify(path, ':t'), vim.log.levels.INFO)
end

-- [統一] クリップボードを判定して貼り付け
--   1. テキストがdraw.io(SVG/XML) → PasteDrawio
--   2. 画像データあり → PasteImage
--   3. どちらでもない → メッセージ表示
function _G.SmartPaste()
    local clip = vim.fn.getreg('+')
    if clip == nil or clip == '' then clip = vim.fn.getreg('*') end

    -- 1. draw.io（SVG/XML文字列）
    if clip:match('<svg') or clip:match('<mxfile') or clip:match('<mxGraphModel') then
        PasteDrawio()
        return
    end

    -- 2. 画像データ（img-clipの判定を使用。遅延ロードのためここでrequireするとロードされる）
    local ok, clipboard = pcall(require, 'img-clip.clipboard')
    if not ok then
        -- img-clip未ロードでもPasteImageコマンドがロードトリガになる
        clipboard = nil
    end
    if clipboard and clipboard.content_is_image() then
        vim.cmd('PasteImage')
        return
    end

    -- 3. どちらでもない
    vim.notify('クリップボードに画像もdraw.io図もありません', vim.log.levels.WARN)
end
