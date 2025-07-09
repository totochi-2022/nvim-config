vim.api.nvim_create_autocmd({"TermEnter"}, {
  callback = function(ev)
    -- TermEnterイベントで送られてくるデータを確認
    local data = vim.v.event
    -- データの中身を確認
    print(vim.inspect(data))
  end
})
