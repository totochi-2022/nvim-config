-- /tmp/nvim_dragdrop_logger.lua
-- イベントロガー
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    callback = function(ev)
        local buf = ev.buf
        vim.fn.writefile({ "Terminal opened: " .. vim.inspect(ev) }, '/tmp/nvim_term_events.log', 'a')

        vim.api.nvim_create_autocmd({ "BufWritePre", "TextChanged", "TextChangedI", "TextChangedP" }, {
            buffer = buf,
            callback = function(event)
                local data = {
                    event_type = event.event,
                    time = os.date(),
                    content = vim.fn.getline(1, '$'),
                    mode = vim.api.nvim_get_mode().mode
                }
                vim.fn.writefile({ vim.inspect(data) }, '/tmp/nvim_term_events.log', 'a')
            end
        })
    end
})

-- RAW入力キャプチャ
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    callback = function(ev)
        local buf = ev.buf
        local tmp_file = '/tmp/raw_input.log'

        vim.api.nvim_buf_attach(buf, false, {
            on_bytes = function(_, _, _, start_row, start_col, offset, _, _, _, _, _, _)
                local data = {
                    time = os.date(),
                    row = start_row,
                    col = start_col,
                    offset = offset,
                    raw = vim.api.nvim_buf_get_text(buf, start_row, start_col, start_row, start_col + offset, {})
                }
                vim.fn.writefile({ vim.inspect(data) }, tmp_file, 'a')
            end
        })
    end
})
