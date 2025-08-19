-- plugins/ime.lua - IME自動切り替え（シンプル版）
return {
    -- シンプルなzenhan制御
    {
        dir = vim.fn.stdpath('config'), -- ダミーディレクトリ
        name = 'simple-ime',
        config = function()
            -- zenhanが存在する場合のみ設定
            if vim.fn.executable(vim.env.HOME .. '/bin/zenhan') == 1 then
                -- 基本的なIME制御
                vim.api.nvim_create_autocmd({"InsertLeave", "CmdlineLeave"}, {
                    pattern = "*",
                    callback = function()
                        vim.fn.system(vim.env.HOME .. '/bin/zenhan 0')
                    end,
                    desc = "IMEを英語モードに切り替え"
                })
                
                -- 手動制御用関数
                _G.toggle_ime = function()
                    local result = vim.fn.system(vim.env.HOME .. '/bin/zenhan')
                    local current = vim.v.shell_error
                    local new_state = current == 1 and 0 or 1
                    vim.fn.system(vim.env.HOME .. '/bin/zenhan ' .. new_state)
                    local status = new_state == 1 and "日本語" or "英語"
                    print("IME: " .. status)
                end
            else
                vim.notify("zenhanが見つかりません: " .. vim.env.HOME .. '/bin/zenhan', vim.log.levels.WARN)
            end
        end,
        lazy = false,
    },
}