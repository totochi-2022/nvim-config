-- Simple Toggle System
-- シンプルなトグルシステム

local M = {}

-- 設定ファイルパス
local defaults_file = vim.fn.stdpath('config') .. '/data/setting/toggle/defaults.json'
local lualine_display_file = vim.fn.stdpath('config') .. '/data/setting/toggle/lualine_display.json'

-- lualine表示状態を保存・読み込み
local lualine_display_state = {}

local function load_lualine_display_state()
    local file = io.open(lualine_display_file, 'r')
    if file then
        local content = file:read('*a')
        file:close()
        local ok, data = pcall(vim.fn.json_decode, content)
        if ok and type(data) == 'table' then
            lualine_display_state = data
        end
    end
end

local function save_lualine_display_state()
    -- ディレクトリが存在しない場合は作成
    local dir = vim.fn.fnamemodify(lualine_display_file, ':h')
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, 'p')
    end
    
    local file = io.open(lualine_display_file, 'w')
    if file then
        file:write(vim.fn.json_encode(lualine_display_state))
        file:close()
    end
end

-- デフォルト状態を保存
local function save_defaults()
    local toggle_defs = require('22_toggle')
    local current_defaults = {}
    
    for key, def in pairs(toggle_defs.definitions) do
        local current_state = def.get_state()
        current_defaults[key] = current_state
    end
    
    -- ディレクトリが存在しない場合は作成
    local dir = vim.fn.fnamemodify(defaults_file, ':h')
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, 'p')
    end
    
    local file = io.open(defaults_file, 'w')
    if file then
        file:write(vim.fn.json_encode(current_defaults))
        file:close()
        print('✅ Current states saved as defaults!')
    end
end

-- フローティングウィンドウUI
function M.show_toggle_menu()
    local toggle_defs = require('22_toggle')
    
    -- 元のバッファを記憶
    local original_buf = vim.api.nvim_get_current_buf()
    local original_win = vim.api.nvim_get_current_win()
    
    -- ウィンドウを作成する関数
    local function create_window()
        local lines = {
            '🔀 Toggle & Display Control',
            '============================',
            '小文字=状態切替  大文字=lualine表示切替',
            ''
        }
        
        -- アルファベット順にソート
        local sorted_keys = {}
        for key, _ in pairs(toggle_defs.definitions) do
            table.insert(sorted_keys, key)
        end
        table.sort(sorted_keys)
        
        for _, key in ipairs(sorted_keys) do
            local def = toggle_defs.definitions[key]
            -- 常に最新の状態を取得
            local current_state = def.get_state()
            local state_index = 1
            
            -- 現在の状態のインデックスを取得
            for i, state in ipairs(def.states) do
                if state == current_state then
                    state_index = i
                    break
                end
            end
            
            -- 色を取得（背景色として使用）
            local color_name = def.colors[state_index] or 'Normal'
            
            -- lualine表示状態
            local lualine_status = lualine_display_state[key] and '[表示]' or '[非表示]'
            
            -- バッファごとの設定は変更不可であることを表示
            local buffer_only_toggles = {'r', 'p', 'c'}
            local is_buffer_only = vim.tbl_contains(buffer_only_toggles, key)
            local readonly_mark = is_buffer_only and ' (表示のみ)' or ''
            
            local line = string.format('%s  %s %-15s [%s]%s / %s %s',
                key, string.upper(key), def.desc, current_state, readonly_mark, string.upper(key), lualine_status)
            
            table.insert(lines, line)
        end
        
        table.insert(lines, '')
        table.insert(lines, 's=現状態を保存  ESC/q=終了')
        
        -- ウィンドウサイズを計算
        local width = 70
        local height = #lines + 2
        local col = math.floor((vim.o.columns - width) / 2)
        local row = math.floor((vim.o.lines - height) / 2)
        
        -- バッファを作成
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
        
        -- floating windowを作成
        local win = vim.api.nvim_open_win(buf, true, {
            relative = 'editor',
            width = width,
            height = height,
            col = col,
            row = row,
            style = 'minimal',
            border = 'rounded',
            title = ' Toggle Control ',
            title_pos = 'center',
            zindex = 50  -- lualineより低い優先度に設定
        })
        
        -- 色付け（シンプル版）
        local ns_id = vim.api.nvim_create_namespace('toggle_ui')
        for i, key in ipairs(sorted_keys) do
            local line_num = i + 3  -- ヘッダー行を考慮
            local def = toggle_defs.definitions[key]
            -- 常に最新の状態を取得
            local current_state = def.get_state()
            local state_index = 1
            
            for j, state in ipairs(def.states) do
                if state == current_state then
                    state_index = j
                    break
                end
            end
            
            -- 状態に応じた色を取得（動的ハイライト対応）
            local toggle_defs_module = require('22_toggle')
            local color_def = def.colors[state_index]
            local color_name
            
            if color_def then
                -- get_or_create_highlight関数を使用
                if toggle_defs_module.get_or_create_highlight then
                    color_name = toggle_defs_module.get_or_create_highlight(color_def, def.name, state_index)
                else
                    -- フォールバック
                    color_name = type(color_def) == 'string' and color_def or 'Normal'
                end
            else
                color_name = 'Normal'
            end
            
            -- 状態部分のみをハイライト（文字列の位置を正確に計算）
            local line_text = lines[line_num + 1]  -- linesは1-indexedだがline_numは0-indexed
            if line_text then
                local state_start = line_text:find('%[' .. vim.pesc(current_state) .. '%]')
                if state_start then
                    local state_end = state_start + #current_state + 1  -- []も含む
                    vim.api.nvim_buf_add_highlight(buf, ns_id, color_name, line_num, state_start - 1, state_end)
                end
            end
        end
        
        -- lualine を強制的に再描画
        vim.schedule(function()
            if pcall(require, 'lualine') then
                require('lualine').refresh()
            end
        end)
        
        return buf, win
    end
    
    -- キーマッピングを設定
    local function setup_keymaps(current_buf, current_win)
        -- 小文字キー（状態切り替え）
        for key, def in pairs(toggle_defs.definitions) do
            -- バッファごとの設定は変更不可（表示のみ）
            local buffer_only_toggles = {'r', 'p', 'c'}
            local is_buffer_only = vim.tbl_contains(buffer_only_toggles, key)
            
            if is_buffer_only then
                vim.keymap.set('n', key, function()
                    print(string.format("%s は表示のみです（バッファごとの設定のため変更不可）", def.desc))
                end, { buffer = current_buf, silent = true })
            else
                vim.keymap.set('n', key, function()
                    -- 次の状態に切り替え - 最新の状態を取得
                    local current_state = def.get_state()
                    local current_index = 1
                    for i, state in ipairs(def.states) do
                        if state == current_state then
                            current_index = i
                            break
                        end
                    end
                    
                    local next_index = current_index + 1
                    if next_index > #def.states then
                        next_index = 1
                    end
                    
                    local next_state = def.states[next_index]
                    
                    -- デバッグ情報
                    print(string.format("Toggle %s: %s → %s", key, current_state, next_state))
                    
                    -- 状態変更を実行
                    def.set_state(next_state)
                    
                    -- 状態変更後の確認
                    local after_state = def.get_state()
                    print(string.format("After set: %s", after_state))
                    
                    -- ウィンドウを更新
                    if vim.api.nvim_win_is_valid(current_win) then
                        vim.api.nvim_win_close(current_win, true)
                    end
                    local new_buf, new_win = create_window()
                    setup_keymaps(new_buf, new_win)
                end, { buffer = current_buf, silent = true })
            end
            
            -- 大文字キー（lualine表示切り替え）
            vim.keymap.set('n', string.upper(key), function()
                lualine_display_state[key] = not lualine_display_state[key]
                save_lualine_display_state()
                
                -- lualineを更新
                if pcall(require, 'lualine') then
                    require('lualine').refresh()
                end
                
                -- ウィンドウを更新
                if vim.api.nvim_win_is_valid(current_win) then
                    vim.api.nvim_win_close(current_win, true)
                end
                local new_buf, new_win = create_window()
                setup_keymaps(new_buf, new_win)
            end, { buffer = current_buf, silent = true })
        end
        
        -- 状態保存
        vim.keymap.set('n', 's', function()
            save_defaults()
            if vim.api.nvim_win_is_valid(current_win) then
                vim.api.nvim_win_close(current_win, true)
            end
        end, { buffer = current_buf, silent = true })
        
        -- 終了
        local function close_window()
            if vim.api.nvim_win_is_valid(current_win) then
                vim.api.nvim_win_close(current_win, true)
            end
        end
        
        vim.keymap.set('n', 'q', close_window, { buffer = current_buf, silent = true })
        vim.keymap.set('n', '<ESC>', close_window, { buffer = current_buf, silent = true })
    end
    
    -- 初期ウィンドウを作成
    local buf, win = create_window()
    setup_keymaps(buf, win)
end

-- 初期化
function M.setup()
    -- lualine表示状態を読み込み
    load_lualine_display_state()
    
    -- デフォルトでは全て非表示
    local toggle_defs = require('22_toggle')
    for key, _ in pairs(toggle_defs.definitions) do
        if lualine_display_state[key] == nil then
            lualine_display_state[key] = false
        end
    end
end

-- lualine用コンポーネント（色付きテキストを返す）
function M.get_lualine_component()
    return function()
        local toggle_defs = require('22_toggle')
        local parts = {}
        
        -- アルファベット順に並べる
        local sorted_keys = {}
        for key, _ in pairs(toggle_defs.definitions) do
            if lualine_display_state[key] then
                table.insert(sorted_keys, key)
            end
        end
        table.sort(sorted_keys)
        
        for _, key in ipairs(sorted_keys) do
            local def = toggle_defs.definitions[key]
            local current_state = def.get_state()
            local state_index = 1
            
            -- 現在の状態のインデックスを取得
            for i, state in ipairs(def.states) do
                if state == current_state then
                    state_index = i
                    break
                end
            end
            
            -- 状態に応じた色を取得（動的ハイライト対応）
            local color_def = def.colors[state_index]
            local color_name
            
            if color_def then
                -- get_or_create_highlight関数を使用
                if toggle_defs.get_or_create_highlight then
                    color_name = toggle_defs.get_or_create_highlight(color_def, def.name, state_index)
                else
                    -- フォールバック
                    color_name = type(color_def) == 'string' and color_def or 'Normal'
                end
            else
                color_name = 'Normal'
            end
            
            local text = string.upper(key)
            
            -- mainブランチ方式：%#ハイライトグループ#テキスト%#Normal#
            local colored_text = string.format('%%#%s#%s%%#Normal#', color_name, text)
            table.insert(parts, colored_text)
        end
        
        return table.concat(parts, '') -- スペースなしで連結
    end
end

-- デバッグ用: lualine状態確認
function M.debug_lualine()
    print("=== LuaLine Display States ===")
    for key, state in pairs(lualine_display_state) do
        print(string.format("%s: %s", key, tostring(state)))
    end
    
    print("\n=== Component Output ===")
    local components = M.get_lualine_components()
    print("Components:", vim.inspect(components))
end

return M