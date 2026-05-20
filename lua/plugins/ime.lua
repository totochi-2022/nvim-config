-- plugins/ime.lua - IME自動切り替え（シンプル版）
return {
    -- シンプルなzenhan制御
    {
        dir = vim.fn.stdpath('config'), -- ダミーディレクトリ
        name = 'simple-ime',
        cond = function()
            -- zenhanが存在する場合のみロード
            return vim.g.env_has and vim.g.env_has.zenhan
        end,
        config = function()
            local zenhan_path = vim.g.env_paths.zenhan
            
            -- 基本的なIME制御
            vim.api.nvim_create_autocmd({"InsertLeave", "CmdlineLeave"}, {
                pattern = "*",
                callback = function()
                    vim.fn.system(zenhan_path .. ' 0')
                end,
                desc = "IMEを英語モードに切り替え"
            })
            
            -- 手動制御用関数
            _G.toggle_ime = function()
                local result = vim.fn.system(zenhan_path)
                local current = vim.v.shell_error
                local new_state = current == 1 and 0 or 1
                vim.fn.system(zenhan_path .. ' ' .. new_state)
                local status = new_state == 1 and "日本語" or "英語"
                print("IME: " .. status)
            end
        end,
        lazy = false,
    },
}