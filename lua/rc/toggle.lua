-- Toggle Library for Neovim
-- トグル機能の統一管理ライブラリ

local M = {}

-- 内部状態管理テーブル
M._states = {}
M._config = {
    persist_file = vim.fn.stdpath('config') .. '/toggle_states.json',
    save_state = false,
    restore_state = false,
    icons = {},
    colors = {},
    prefix_modes = {}
}

-- アイコンとカラーのデフォルト設定
local default_icons = {
    boolean = { '❌', '✅' },
    cycle = { '●', '◐', '○' },
    vim_option = { '📝', '🔒' }
}

local default_colors = {
    off = 'red',
    on = 'green',
    active = 'blue',
    inactive = 'gray'
}

-- 初期設定
function M.setup(options)
    options = options or {}
    M._config = vim.tbl_deep_extend('force', M._config, options)
    
    -- デフォルトアイコンを設定
    M._config.icons = vim.tbl_deep_extend('force', default_icons, M._config.icons or {})
    M._config.colors = vim.tbl_deep_extend('force', default_colors, M._config.colors or {})
    
    -- 保存された状態を復元
    if M._config.restore_state then
        M.load_states()
    end
    
    -- 終了時の自動保存設定
    if M._config.save_state then
        vim.api.nvim_create_autocmd('VimLeavePre', {
            callback = function()
                M.save_states()
            end
        })
    end
end

-- トグル関数を作成する基本メソッド
function M.create_toggle(name, options)
    options = options or {}
    
    -- デフォルト設定
    local config = {
        type = options.type or 'boolean',
        initial_state = options.initial_state,
        states = options.states or { false, true },
        messages = options.messages or {},
        callbacks = options.callbacks or {},
        keymap = options.keymap or nil,
        desc = options.desc or ("Toggle " .. name),
        silent = options.silent or false,
        icons = options.icons or M._config.icons[options.type or 'boolean'] or default_icons.boolean,
        colors = options.colors or {},
        vim_option = options.vim_option or nil
    }
    
    -- 初期状態を設定
    M._states[name] = {
        current_index = 1,
        config = config
    }
    
    -- 初期状態を設定された値に調整
    if config.initial_state ~= nil then
        for i, state in ipairs(config.states) do
            if state == config.initial_state then
                M._states[name].current_index = i
                break
            end
        end
    end
    
    -- トグル関数を生成
    local toggle_function = function()
        return M.toggle(name)
    end
    
    -- キーマップを設定
    if config.keymap then
        vim.keymap.set('n', config.keymap, toggle_function, {
            noremap = true,
            silent = config.silent,
            desc = config.desc
        })
    end
    
    -- 初期状態のコールバックを実行（defer_fnで遅延実行）
    if not options.skip_initial_callback then
        vim.defer_fn(function()
            local initial_index = M._states[name].current_index
            if config.callbacks[initial_index] then
                pcall(config.callbacks[initial_index], config.states[initial_index], 0)
            end
        end, 100)
    end
    
    return toggle_function
end

-- 指定されたトグルを実行
function M.toggle(name)
    local state_info = M._states[name]
    if not state_info then
        vim.api.nvim_err_writeln("Toggle '" .. name .. "' not found")
        return nil
    end
    
    local config = state_info.config
    local current_index = state_info.current_index
    
    -- 次の状態に移行
    local next_index = current_index + 1
    if next_index > #config.states then
        next_index = 1
    end
    
    M._states[name].current_index = next_index
    local new_state = config.states[next_index]
    
    -- コールバック実行
    if config.callbacks[next_index] then
        config.callbacks[next_index](new_state, current_index)
    end
    
    -- メッセージ表示
    if not config.silent and config.messages[next_index] then
        print(config.messages[next_index])
    end
    
    -- 自動保存
    if M._config.save_state then
        M.save_states()
    end
    
    return new_state
end

-- 現在の状態を取得
function M.get_state(name)
    local state_info = M._states[name]
    if not state_info then
        return nil
    end
    
    return state_info.config.states[state_info.current_index]
end

-- 状態を直接設定
function M.set_state(name, state)
    local state_info = M._states[name]
    if not state_info then
        vim.api.nvim_err_writeln("Toggle '" .. name .. "' not found")
        return false
    end
    
    for i, s in ipairs(state_info.config.states) do
        if s == state then
            local old_index = M._states[name].current_index
            M._states[name].current_index = i
            
            -- コールバック実行
            if state_info.config.callbacks[i] then
                state_info.config.callbacks[i](state, old_index)
            end
            
            -- 自動保存
            if M._config.save_state then
                M.save_states()
            end
            
            return true
        end
    end
    
    return false
end

-- アイコンを取得
function M.get_icon(name)
    local state_info = M._states[name]
    if not state_info then
        return '❓'
    end
    
    local config = state_info.config
    local current_index = state_info.current_index
    
    if config.icons and config.icons[current_index] then
        return config.icons[current_index]
    end
    
    return '●'
end

-- 色付きアイコンを取得
function M.get_colored_icon(name)
    local state_info = M._states[name]
    if not state_info then
        return '❓'
    end
    
    local config = state_info.config
    local current_index = state_info.current_index
    local icon = config.icons and config.icons[current_index] or '●'
    local color = config.colors and config.colors[current_index] or 'Normal'
    
    -- NonText（OFF状態）の場合はハイライトなし（lualineのベース色を使用）
    if color == 'NonText' then
        return icon
    end
    
    -- Visual（ON状態）の場合はハイライトグループを適用
    return string.format('%%#%s#%s%%#Normal#', color, icon)
end

-- lualine用のプレーンアイコン（色なし）
function M.get_plain_icon(name)
    local state_info = M._states[name]
    if not state_info then
        return '?'
    end
    
    local config = state_info.config
    local current_index = state_info.current_index
    return config.icons and config.icons[current_index] or '●'
end

-- 状態文字列を取得（アイコン+名前+状態）
function M.get_status_string(name)
    local state_info = M._states[name]
    if not state_info then
        return name .. ' (not found)'
    end
    
    local config = state_info.config
    local current_state = config.states[state_info.current_index]
    local icon = M.get_icon(name)
    
    return string.format('%s %s (%s)', icon, name, tostring(current_state))
end

-- 真偽値トグルのショートカット
function M.create_boolean_toggle(name, options)
    options = options or {}
    options.type = 'boolean'
    options.states = { false, true }
    
    return M.create_toggle(name, options)
end

-- 複数状態トグルのショートカット
function M.create_cycle_toggle(name, states, options)
    options = options or {}
    options.type = 'cycle'
    options.states = states
    
    return M.create_toggle(name, options)
end

-- Vim オプショントグルのヘルパー
function M.create_vim_option_toggle(name, option_name, options)
    options = options or {}
    options.type = 'vim_option'
    options.vim_option = option_name
    
    -- 現在のオプション値を取得
    local current_value = vim.opt[option_name]:get()
    
    if options.states then
        -- カスタム状態が指定されている場合
        options.callbacks = options.callbacks or {}
        for i, state in ipairs(options.states) do
            if not options.callbacks[i] then
                options.callbacks[i] = function(new_state)
                    vim.opt[option_name] = new_state
                end
            end
        end
    else
        -- デフォルトの真偽値トグル
        options.states = { false, true }
        options.initial_state = current_value
        options.callbacks = {
            function() vim.opt[option_name] = false end,
            function() vim.opt[option_name] = true end,
        }
    end
    
    return M.create_toggle(name, options)
end

-- 診断表示トグル（既存関数の置き換え）
function M.create_diagnostic_toggle(keymap)
    return M.create_cycle_toggle('diagnostics', {
        'off', 'underline', 'full'
    }, {
        keymap = keymap,
        desc = '診断表示モード切替',
        messages = {
            '診断表示: OFF',
            '診断表示: アンダーライン＋サイン', 
            '診断表示: フル表示（重複対応）'
        },
        icons = { '🚫', '⚠️', '🔍' },
        callbacks = {
            -- OFF
            function()
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = false,
                    underline = false,
                    update_in_insert = false,
                })
            end,
            -- アンダーラインのみ
            function()
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = true,
                    underline = true,
                    update_in_insert = false,
                })
            end,
            -- フル表示
            function()
                vim.diagnostic.config({
                    virtual_text = {
                        prefix = "●",
                        source = "if_many",
                        spacing = 2,
                        format = function(diagnostic)
                            local message = diagnostic.message
                            if #message > 50 then
                                message = message:sub(1, 47) .. "..."
                            end
                            local source = diagnostic.source and ("[" .. diagnostic.source .. "] ") or ""
                            return source .. message
                        end,
                    },
                    signs = { priority = 20 },
                    underline = true,
                    update_in_insert = false,
                    severity_sort = true,
                    float = {
                        border = "rounded",
                        source = "always",
                        header = "",
                        prefix = "",
                        format = function(diagnostic)
                            return diagnostic.message
                        end,
                    },
                })
            end
        }
    })
end

-- プレフィックスモードの設定
function M.setup_prefix_mode(prefix_key, mappings, options)
    options = options or {}
    
    local config = {
        keymap = prefix_key,
        mappings = mappings,
        title = options.title or "🔀 Toggle Mode",
        persistent = options.persistent ~= false,  -- デフォルトtrue
        timeout = options.timeout or 5000,
        show_current_state = options.show_current_state ~= false,
        show_icons = options.show_icons ~= false,
        footer = options.footer or "ESC: exit"
    }
    
    M._config.prefix_modes[prefix_key] = config
    
    -- minor_modeが利用可能かチェック
    local has_minor_mode, minor_mode = pcall(require, 'rc.minor_mode')
    if has_minor_mode then
        -- minor_modeで自動登録
        local toggle_mappings = {}
        
        for key, toggle_name in pairs(mappings) do
            local desc = string.format('%s %s', M.get_icon(toggle_name), toggle_name)
            local cmd = string.format('<cmd>lua require("rc.toggle").toggle("%s")<CR>', toggle_name)
            table.insert(toggle_mappings, { key, cmd, desc })
        end
        
        -- minor_modeで登録（persistentオプション付き）
        -- 新しいdefine_modeを使用してトグル操作を設定
        local toggle_actions = {}
        for key, toggle_name in pairs(mappings) do
            table.insert(toggle_actions, { 
                key = key, 
                action = '<cmd>lua require("rc.toggle").toggle("' .. toggle_name .. '")<CR>', 
                desc = 'Toggle ' .. toggle_name 
            })
        end
        
        minor_mode.define_mode({
            namespace = 'Toggle',
            entries = {
                { key = prefix_key, desc = 'トグルモード開始' }
            },
            actions = toggle_actions
        })
    else
        -- フォールバック: 通常のキーマップ設定
        vim.keymap.set('n', prefix_key, function()
            M.enter_prefix_mode(prefix_key)
        end, {
            noremap = true,
            silent = true,
            desc = config.title
        })
    end
end

-- プレフィックスモードに入る
function M.enter_prefix_mode(prefix_key)
    local config = M._config.prefix_modes[prefix_key]
    if not config then
        vim.api.nvim_err_writeln("Prefix mode '" .. prefix_key .. "' not found")
        return
    end
    
    -- which-keyが利用可能かチェック
    local has_which_key, wk = pcall(require, 'which-key')
    if not has_which_key then
        M.show_toggle_menu(config)
        return
    end
    
    -- バッファローカルキーマップを設定
    local temp_keys = {}
    
    for key, toggle_name in pairs(config.mappings) do
        vim.keymap.set('n', key, function()
            M.toggle(toggle_name)
            if config.persistent then
                -- 状態更新後に再度プレフィックスモードに入る
                vim.defer_fn(function()
                    M.enter_prefix_mode(prefix_key)
                end, 50)
            end
        end, { 
            buffer = true,
            silent = true,
            nowait = true,
            desc = string.format('%s %s', M.get_icon(toggle_name), toggle_name)
        })
        table.insert(temp_keys, key)
    end
    
    -- ESCで終了
    vim.keymap.set('n', '<ESC>', function()
        for _, k in ipairs(temp_keys) do
            pcall(vim.keymap.del, 'n', k, { buffer = true })
        end
        pcall(vim.keymap.del, 'n', '<ESC>', { buffer = true })
    end, { 
        buffer = true, 
        silent = true,
        desc = "Exit toggle mode"
    })
    table.insert(temp_keys, '<ESC>')
    
    -- which-keyで表示
    wk.show({ global = false })
end

-- which-keyなしの場合のフォールバック表示
function M.show_toggle_menu(config)
    local lines = { config.title or "Toggle Menu:" }
    
    for key, toggle_name in pairs(config.mappings) do
        local state = M.get_state(toggle_name)
        local colored_icon = M.get_colored_icon(toggle_name)
        local state_str = config.show_current_state and string.format(' (%s)', tostring(state)) or ''
        
        local desc = string.format('  %s: %s %s%s', key, colored_icon, toggle_name, state_str)
        table.insert(lines, desc)
    end
    
    table.insert(lines, "  ESC: Exit")
    
    -- 簡単なメニュー表示
    print(table.concat(lines, '\n'))
    
    -- 入力待ち
    local char = vim.fn.getchar()
    if char == 27 then -- ESC
        return
    end
    
    local key = vim.fn.nr2char(char)
    local toggle_name = config.mappings[key]
    
    if toggle_name then
        M.toggle(toggle_name)
        if config.persistent then
            -- 連続切り替えのため再帰呼び出し
            vim.defer_fn(function()
                M.show_toggle_menu(config)
            end, 50)
        end
    end
end

-- 状態の保存
function M.save_states()
    local states_to_save = {}
    
    for name, state_info in pairs(M._states) do
        states_to_save[name] = {
            current_index = state_info.current_index,
            current_state = state_info.config.states[state_info.current_index]
        }
    end
    
    -- ディレクトリが存在しない場合は作成
    local dir = vim.fn.fnamemodify(M._config.persist_file, ':h')
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, 'p')
    end
    
    local file = io.open(M._config.persist_file, 'w')
    if file then
        file:write(vim.fn.json_encode(states_to_save))
        file:close()
    end
end

-- 状態の読み込み
function M.load_states()
    local file = io.open(M._config.persist_file, 'r')
    if not file then
        return
    end
    
    local content = file:read('*a')
    file:close()
    
    local ok, saved_states = pcall(vim.fn.json_decode, content)
    if not ok or type(saved_states) ~= 'table' then
        return
    end
    
    for name, saved_data in pairs(saved_states) do
        if M._states[name] and saved_data.current_index then
            M._states[name].current_index = saved_data.current_index
        end
    end
end

-- 登録されているトグル一覧を表示
function M.list_toggles()
    print("Registered toggles:")
    for name, state_info in pairs(M._states) do
        local current_state = state_info.config.states[state_info.current_index]
        local icon = M.get_icon(name)
        print(string.format("  %s %s: %s", icon, name, tostring(current_state)))
    end
end

-- 一括トグル定義
function M.define_toggles(toggle_definitions)
    for _, definition in ipairs(toggle_definitions) do
        local name = definition.name
        local toggle_type = definition.type or 'boolean'
        
        if toggle_type == 'boolean' then
            M.create_boolean_toggle(name, definition)
        elseif toggle_type == 'cycle' then
            M.create_cycle_toggle(name, definition.states, definition)
        elseif toggle_type == 'vim_option' then
            M.create_vim_option_toggle(name, definition.option, definition)
        else
            M.create_toggle(name, definition)
        end
    end
end

-- lualine用関数
function M.get_lualine_component(toggle_names)
    return function()
        local parts = {}
        for _, name in ipairs(toggle_names) do
            if M._states[name] then
                -- 色付きアイコンを使用（Visual/NonTextハイライト）
                local colored_icon = M.get_colored_icon(name)
                table.insert(parts, colored_icon)
            end
        end
        return table.concat(parts, '')  -- スペースなしで連結
    end
end

-- 選択可能なlualine設定
function M.setup_lualine_selector()
    local available_toggles = {}
    for name, _ in pairs(M._states) do
        table.insert(available_toggles, name)
    end
    
    -- 設定保存用ファイル
    local config_file = vim.fn.stdpath('config') .. '/data/setting/toggle/lualine.json'
    
    -- 保存された設定を読み込み
    local function load_selected_toggles()
        local file = io.open(config_file, 'r')
        if file then
            local content = file:read('*a')
            file:close()
            local ok, data = pcall(vim.fn.json_decode, content)
            if ok and type(data) == 'table' then
                return data
            end
        end
        -- デフォルト選択
        return { 'readonly', 'paste_mode', 'auto_hover', 'diagnostics' }
    end
    
    -- 設定を保存
    local function save_selected_toggles(selected)
        -- ディレクトリが存在しない場合は作成
        local dir = vim.fn.fnamemodify(config_file, ':h')
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, 'p')
        end
        
        local file = io.open(config_file, 'w')
        if file then
            file:write(vim.fn.json_encode(selected))
            file:close()
        end
    end
    
    -- floating window版選択UI
    local function show_selector()
        local selected = load_selected_toggles()
        
        -- floating windowを作成
        local function create_float_window()
            local lines = {
                '🎛️ lualine Toggle Display Settings',
                '=====================================',
                ''
            }
            
            for i, name in ipairs(available_toggles) do
                local is_selected = vim.tbl_contains(selected, name)
                local mark = is_selected and '[x]' or '[ ]'
                local icon = M.get_icon(name)  -- シンプルなアイコン
                table.insert(lines, string.format('%d. %s %s %s', i, mark, icon, name))
            end
            
            table.insert(lines, '')
            table.insert(lines, 'Press: number=toggle, s=save&exit, q=quit, ESC=cancel')
            
            -- ウィンドウサイズを計算
            local width = 50
            local height = #lines + 2
            local col = math.floor((vim.o.columns - width) / 2)
            local row = math.floor((vim.o.lines - height) / 2)
            
            -- バッファを作成
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
            vim.api.nvim_buf_set_option(buf, 'filetype', 'toggleselect')
            
            -- floating windowを作成
            local win = vim.api.nvim_open_win(buf, true, {
                relative = 'editor',
                width = width,
                height = height,
                col = col,
                row = row,
                style = 'minimal',
                border = 'rounded',
                title = ' Toggle Selector ',
                title_pos = 'center'
            })
            
            return buf, win
        end
        
        -- キーマッピングを設定する関数
        local function setup_keymaps(current_buf, current_win)
            -- 数字キー (1-9)
            for i = 1, math.min(9, #available_toggles) do
                vim.keymap.set('n', tostring(i), function()
                    local toggle_name = available_toggles[i]
                    if vim.tbl_contains(selected, toggle_name) then
                        selected = vim.tbl_filter(function(name)
                            return name ~= toggle_name
                        end, selected)
                    else
                        table.insert(selected, toggle_name)
                    end
                    
                    -- ウィンドウを更新
                    if vim.api.nvim_win_is_valid(current_win) then
                        vim.api.nvim_win_close(current_win, true)
                    end
                    
                    local new_buf, new_win = create_float_window()
                    setup_keymaps(new_buf, new_win)
                end, { buffer = current_buf, silent = true })
            end
            
            -- 保存して終了
            vim.keymap.set('n', 's', function()
                save_selected_toggles(selected)
                if vim.api.nvim_win_is_valid(current_win) then
                    vim.api.nvim_win_close(current_win, true)
                end
                print('✅ lualine toggle display saved: ' .. table.concat(selected, ', '))
                
                if pcall(require, 'lualine') then
                    require('lualine').refresh()
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
        
        local buf, win = create_float_window()
        setup_keymaps(buf, win)
    end
    
    -- コマンド登録
    vim.api.nvim_create_user_command('ToggleLualineSelect', show_selector, {
        desc = 'Select toggles to display in lualine'
    })
    
    return {
        load_selected = load_selected_toggles,
        save_selected = save_selected_toggles,
        show_selector = show_selector,
        get_component = function()
            local selected = load_selected_toggles()
            return M.get_lualine_component(selected)
        end
    }
end

-- コマンド登録
vim.api.nvim_create_user_command('ToggleList', M.list_toggles, {})
vim.api.nvim_create_user_command('ToggleSave', M.save_states, {})
vim.api.nvim_create_user_command('ToggleLoad', M.load_states, {})
vim.api.nvim_create_user_command('ToggleMenu', function()
    M.enter_prefix_mode('<LocalLeader>0')
end, { desc = 'Show toggle menu' })

return M