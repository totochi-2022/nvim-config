-- jaq_process.lua - jaq-nvim用のプロセス管理モジュール
local M = {}

-- アクティブなプロセスを管理
M.processes = {}

-- デバッグ用フラグ
local DEBUG = false

local function debug_print(msg)
    if DEBUG then
        print("[jaq_process] " .. msg)
    end
end

-- コマンドを実行してプロセスを管理下に登録
function M.run(command, file, mode)
    mode = mode or "float"  -- デフォルトはfloat
    
    -- コマンド文字列を構築
    local cmd = command .. " " .. vim.fn.shellescape(file)
    debug_print("Running: " .. cmd)
    
    -- jaq-nvimのfloat機能を直接実装
    local jaq = require('jaq-nvim')
    
    -- フロートウィンドウを作成してターミナルを開く
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'Jaq')
    
    -- フロートウィンドウの設定（jaq-nvimの設定を参考）
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)
    
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = col,
        row = row,
        border = 'rounded',
        style = 'minimal'
    })
    
    -- ターミナルを開始
    local job_id = vim.fn.termopen(cmd, {
        on_exit = function(job_id, exit_code, event)
            M.processes[buf] = nil
            debug_print("Process finished: " .. cmd .. " (exit: " .. exit_code .. ")")
        end
    })
    
    if job_id > 0 then
        -- プロセス情報を登録
        M.processes[buf] = {
            job_id = job_id,
            buffer = buf,
            window = win,
            command = cmd,
            file = file,
            mode = mode,
            timestamp = os.time()
        }
        
        debug_print("Process registered: " .. cmd .. " (job_id: " .. job_id .. ")")
        
        -- Escキーでウィンドウを閉じる
        vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', 
            '<cmd>lua vim.api.nvim_win_close(' .. win .. ', true)<CR>', 
            { silent = true, noremap = true })
    else
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, { force = true })
        vim.api.nvim_err_writeln("Failed to start: " .. cmd)
    end
end

-- 全てのjaqプロセスを停止
function M.kill_all()
    local count = 0
    
    for buf, process in pairs(M.processes) do
        if vim.api.nvim_buf_is_valid(buf) then
            -- ジョブを停止
            if process.job_id then
                pcall(vim.fn.jobstop, process.job_id)
                debug_print("Killed job_id: " .. process.job_id)
            end
            
            -- バッファを削除
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
            count = count + 1
        end
        
        -- プロセス記録を削除
        M.processes[buf] = nil
    end
    
    if count > 0 then
        print("Killed " .. count .. " jaq process(es)")
    else
        print("No jaq process found")
    end
    
    return count
end

-- アクティブなプロセス一覧を表示
function M.list()
    local count = 0
    print("Active jaq processes:")
    
    for buf, process in pairs(M.processes) do
        if vim.api.nvim_buf_is_valid(buf) then
            local elapsed = os.time() - process.timestamp
            print(string.format("  %s (job_id: %s, %ds ago)", 
                process.command, process.job_id or "N/A", elapsed))
            count = count + 1
        else
            -- 無効なバッファは削除
            M.processes[buf] = nil
        end
    end
    
    if count == 0 then
        print("  No active processes")
    end
    
    return count
end

-- デバッグモードの切り替え
function M.debug(enable)
    DEBUG = enable or not DEBUG
    print("jaq_process debug mode: " .. (DEBUG and "ON" or "OFF"))
end

return M