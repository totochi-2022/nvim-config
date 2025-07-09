-- 複数のイベントでデバッグ情報を出力
local events = {"BufNew", "BufAdd", "BufEnter", "BufNewFile"}

vim.api.nvim_create_autocmd(events, {
  callback = function(ev)
    local info = {
      event = ev.event,
      file = ev.file,
      buf = ev.buf,
      afile = vim.fn.expand('<afile>'),
      abuf = vim.fn.expand('<abuf>'),
      amatch = vim.fn.expand('<amatch>'),
    }

    -- ログファイルに出力（WSLの場合）
    local log = io.open("/tmp/nvim_debug.log", "a")
    if log then
      log:write(vim.inspect(info) .. "\n---\n")
      log:close()
    end
  end
})
