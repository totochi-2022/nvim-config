vim.api.nvim_create_autocmd({ "TermOpen" }, {
    callback = function()
        -- デバッグログ用のファイル
        local log_file = '/tmp/nvim_dragdrop_debug.log'

        -- ターミナルイベントをログに記録
        vim.api.nvim_create_autocmd({ "TermResponse" }, {
            callback = function(ev)
                local data = {
                    event = ev,
                    time = os.date(),
                    sequence = vim.inspect(ev),
                    is_bracket_paste = vim.opt.bracketed_paste:get()
                }
                -- ログに追記
                vim.fn.writefile({ vim.inspect(data) }, log_file, 'a')
            end
        })

        -- より低レベルのターミナルイベントも記録
        vim.api.nvim_create_autocmd({ "TermEnter", "TermLeave" }, {
            callback = function(ev)
                local data = {
                    event = ev.event,
                    time = os.date(),
                    raw_event = vim.inspect(ev)
                }
                vim.fn.writefile({ vim.inspect(data) }, log_file, 'a')
            end
        })
    end
})

