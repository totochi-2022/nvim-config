-- 31_startup.lua - 起動最終処理
-- カラースキーム変更とdashboard起動を最終段階で実行

-- 起動時にランダムカラースキームを実行
RandomScheme(true)

-- 起動時のdashboard表示判定（カラー変更後）
vim.defer_fn(function()
    -- 引数なしで起動し、空のバッファの場合のみ表示
    if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" and vim.bo.filetype == "" then
        print("DEBUG: Starting dashboard from startup file")
        -- dashboard-nvimの正しい起動方法
        vim.cmd('Dashboard')  -- コマンド実行
        print("DEBUG: Dashboard command executed")
    end
end, 200)  -- 200ms遅延でカラースキーム変更後に実行