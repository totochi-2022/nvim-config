-- 04_env_check.lua - 環境チェックと設定
-- 実行可能ファイルやディレクトリの存在を確認し、グローバル変数として保存

local M = {}

-- チェック項目の定義
local check_items = {
    -- コマンド
    commands = {
        zenhan = { check_cmd = 'which zenhan 2>/dev/null' },
        cmigemo = { check_cmd = 'which cmigemo 2>/dev/null' },
        deno = { check_cmd = 'which deno 2>/dev/null' },
        rg = { check_cmd = 'which rg 2>/dev/null' },
        make = { check_cmd = 'which make 2>/dev/null' },
        gcc = { check_cmd = 'which gcc 2>/dev/null' },
        cargo = { check_cmd = 'which cargo 2>/dev/null' },
        node = { check_cmd = 'which node 2>/dev/null' },
        npm = { check_cmd = 'which npm 2>/dev/null' },
    },
    
    -- ディレクトリ
    directories = {
        local_plugins = { path = vim.env.HOME .. '/work/repo' },
        user_bin = { path = vim.env.HOME .. '/bin' },
    },
    
    -- ファイル
    files = {
        migemo_dict = {
            paths = {
                '/usr/share/migemo/utf-8/migemo-dict',
                '/usr/share/cmigemo/utf-8/migemo-dict',
                '/usr/local/share/migemo/utf-8/migemo-dict',
                vim.env.HOME .. '/.local/share/migemo/utf-8/migemo-dict',
            }
        },
    },
}

-- コマンドの存在をチェック。
-- 以前は vim.fn.system('which X') でシェルを spawn していたが、WSL+fish では
-- 1回数百ms×コマンド数で起動が数秒遅延していた。組み込みの exepath()（シェル
-- 非起動・即時のPATH探索）に変更して解消。引数はコマンド名。
local function check_command(name)
    local path = vim.fn.exepath(name)
    if path ~= '' then
        return true, path
    end
    return false, nil
end

-- ファイルの存在をチェック
local function check_file(paths)
    for _, path in ipairs(paths) do
        if vim.fn.filereadable(path) == 1 then
            return true, path
        end
    end
    return false, nil
end

-- ディレクトリの存在をチェック
local function check_directory(path)
    return vim.fn.isdirectory(path) == 1, path
end

-- 環境チェックを実行してグローバル変数に設定
local function setup_env()
    -- 環境情報を格納するテーブル（ローカル）
    local env_has = {}
    local env_paths = {}
    
    -- コマンドチェック（name がコマンド名。exepath で即時判定）
    for name, _item in pairs(check_items.commands) do
        local available, path = check_command(name)
        env_has[name] = available
        if path then
            env_paths[name] = path
        end
    end
    
    -- ディレクトリチェック
    for name, item in pairs(check_items.directories) do
        local available, path = check_directory(item.path)
        env_has[name] = available
        if available then
            env_paths[name] = path
        end
    end
    
    -- ファイルチェック
    for name, item in pairs(check_items.files) do
        local available, path = check_file(item.paths)
        env_has[name] = available
        if path then
            env_paths[name] = path
        end
    end
    
    -- 最後に一度だけグローバル変数に設定
    vim.g.env_has = env_has
    vim.g.env_paths = env_paths
end

-- 環境情報を表示するコマンド
function M.show_env()
    print("=== 環境チェック結果 ===")
    print("")
    
    local categories = {
        { title = "【コマンド】", items = check_items.commands },
        { title = "【ディレクトリ】", items = check_items.directories },
        { title = "【ファイル】", items = check_items.files },
    }
    
    for _, category in ipairs(categories) do
        print(category.title)
        for name, _ in pairs(category.items) do
            local status = vim.g.env_has[name] and "✓" or "✗"
            local path = vim.g.env_paths[name] and (" (" .. vim.g.env_paths[name] .. ")") or ""
            print(string.format("  %s %s%s", status, name, path))
        end
        print("")
    end
end

-- 初期化実行
setup_env()

-- コマンド登録
vim.api.nvim_create_user_command('CheckEnv', function()
    setup_env()
    M.show_env()
end, { desc = '環境チェックを実行して表示' })

return M