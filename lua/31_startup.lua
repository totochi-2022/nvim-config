-- 31_startup.lua - 起動最終処理
-- カラースキーム変更とdashboard起動を最終段階で実行

-- 起動時にランダムカラースキームを実行
-- RandomScheme(true)

vim.cmd.colorscheme('gruvbox')
-- 起動時の dashboard 表示。
-- VimEnter autocmd（同期）で描画する。lazy は VeryLazy を vim.schedule（次tick）で
-- 発火するので、VimEnter 内で先に Dashboard を出せば「VeryLazy 群のロードを待たずに」
-- スタート画面が即表示され、プラグインは背後でロードされる。
-- （以前は vim.defer_fn(fn,1) だったが、1msタイマーが vim.schedule より後に走るため
--  VeryLazy 全ロード後に dashboard が出て、表示までラグが出ていた）
vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
        -- 引数なしで起動し、空のバッファの場合のみ表示
        if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" and vim.bo.filetype == "" then
            -- dashboardが有効な場合のみ起動（無効化時はDashboardコマンドが存在しない）
            if vim.fn.exists(':Dashboard') == 2 then
                vim.cmd('Dashboard')
            end
        end
    end,
})
