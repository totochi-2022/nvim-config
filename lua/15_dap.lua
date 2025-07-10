-- nvim-dap configuration
local dap = require('dap')
local dapui = require('dapui')





local dap_signs = {
    -- 基本的なデバッグアイコン
    DapBreakpoint = { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" },
    DapBreakpointCondition = { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" },
    DapLogPoint = { text = "◉", texthl = "DapLogPoint", linehl = "", numhl = "" },
    DapStopped = { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" },
    DapBreakpointRejected = { text = "○", texthl = "DapBreakpointRejected", linehl = "", numhl = "" },

    -- 追加アイコン
    DapStepOver = { text = "→", texthl = "DapStepOver" },
    DapStepInto = { text = "↓", texthl = "DapStepInto" },
    DapStepOut = { text = "↑", texthl = "DapStepOut" },
    DapContinue = { text = "▷", texthl = "DapContinue" },
    DapPause = { text = "⏸", texthl = "DapPause" },
    DapRestart = { text = "↺", texthl = "DapRestart" },
    DapTerminate = { text = "□", texthl = "DapTerminate" }
}

-- すべてのデバッグサインを登録
for name, sign in pairs(dap_signs) do
    vim.fn.sign_define(name, sign)
end

-- ハイライトグループの設定
vim.cmd([[
  highlight DapBreakpoint guifg=#993939 guibg=NONE
  highlight DapBreakpointCondition guifg=#993939 guibg=NONE
  highlight DapLogPoint guifg=#61afef guibg=NONE
  highlight DapStopped guifg=#98c379 guibg=NONE
  highlight DapBreakpointRejected guifg=#e06c75 guibg=NONE
  highlight DapStoppedLine guibg=#31353f
  highlight DapStepOver guifg=#98c379 guibg=NONE
  highlight DapStepInto guifg=#98c379 guibg=NONE
  highlight DapStepOut guifg=#98c379 guibg=NONE
  highlight DapContinue guifg=#98c379 guibg=NONE
  highlight DapPause guifg=#e5c07b guibg=NONE
  highlight DapRestart guifg=#98c379 guibg=NONE
  highlight DapTerminate guifg=#e06c75 guibg=NONE
]])



-- Basic UI setup
dapui.setup({
    icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
    },
    -- Expand lines larger than the window
    expand_lines = vim.fn.has("nvim-0.7") == 1,
    -- Layouts define sections of the screen to place windows.
    -- The position can be "left", "right", "top" or "bottom".
    -- The size specifies the height/width depending on position.
    -- Elements are the elements shown in the layout (in order).
    layouts = {
        {
            elements = {
                -- Elements can be strings or table with id and size keys.
                { id = "scopes", size = 0.25 },
                "breakpoints",
                "stacks",
                "watches",
            },
            size = 40, -- 40 columns
            position = "left",
        },
        {
            elements = {
                "repl",
                "console",
            },
            size = 0.25, -- 25% of total lines
            position = "bottom",
        },
    },
    windows = { indent = 1 },
    render = {
        max_type_length = nil, -- Can be integer or nil.
        max_value_lines = 100, -- Can be integer or nil.
    }
})

-- Automatically open and close the DAP UI
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

-- Python setup
require('dap-python').setup(vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python')

-- Python の設定をさらに詳細に構成
table.insert(dap.configurations.python, {
    type = 'python',
    request = 'launch',
    name = 'Launch file with arguments',
    program = "${file}",
    args = function()
        local args_string = vim.fn.input('Arguments: ')
        return vim.split(args_string, " ")
    end,
})

-- Django や Flask など特定のフレームワーク用の設定も追加可能
table.insert(dap.configurations.python, {
    type = 'python',
    request = 'launch',
    name = 'Django',
    program = "${workspaceFolder}/manage.py",
    args = { 'runserver', '--noreload' },
})
-- Configure various adapters based on your needs
-- Node.js (JavaScript/TypeScript)
dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = { vim.fn.stdpath('data') .. '/mason/packages/node-debug2-adapter/out/src/nodeDebug.js' },
}

dap.configurations.javascript = {
    {
        name = 'Launch',
        type = 'node2',
        request = 'launch',
        program = '${file}',
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = 'inspector',
        console = 'integratedTerminal',
    },
    {
        -- For this to work you need to make sure the node process is started with the --inspect flag.
        name = 'Attach to process',
        type = 'node2',
        request = 'attach',
        processId = require('dap.utils').pick_process,
    },
}
dap.configurations.typescript = dap.configurations.javascript

-- For C/C++/Rust (lldb)
dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode', -- Adjust path as needed
    name = 'lldb'
}

dap.configurations.cpp = {
    {
        name = 'Launch',
        type = 'lldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
    },
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

-- Visual indicators for breakpoints
vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '🟡', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapLogPoint', { text = '📝', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '👉', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '⭕', texthl = '', linehl = '', numhl = '' })

-- Key mappings for debugging
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Create a minor mode for debugging using your minor_mode.lua
local minor_mode = require('rc/minor_mode')

minor_mode.create('Debug', '<Leader>d').set_multi({
    { 'b', '<cmd>lua require("dap").toggle_breakpoint()<CR>' },
    { 'B', '<cmd>lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>' },
    { 'c', '<cmd>lua require("dap").continue()<CR>' },
    { 'i', '<cmd>lua require("dap").step_into()<CR>' },
    { 'o', '<cmd>lua require("dap").step_over()<CR>' },
    { 'O', '<cmd>lua require("dap").step_out()<CR>' },
    { 'r', '<cmd>lua require("dap").repl.open()<CR>' },
    { 'l', '<cmd>lua require("dap").run_last()<CR>' },
    { 'u', '<cmd>lua require("dapui").toggle()<CR>' },
    { 't', '<cmd>lua require("dap").terminate()<CR>' },
    { 'w', '<cmd>lua require("dap.ui.widgets").hover()<CR>' },
    { 's', '<cmd>lua local widgets=require("dap.ui.widgets");widgets.centered_float(widgets.scopes)<CR>' },
})

-- Update loader to include the DAP configuration

-- This comment will be removed after adding to 00_loader.lua






require('nvim-web-devicons').setup {
    -- デフォルトアイコン
    default = true,
    -- アイコン後のスペース
    strict = true,
    -- アイコンの色付け
    color_icons = true,
    -- アイコンの後のパディング
    default_icon = {
        icon = "",
        name = "Default",
        color = "#6d8086",
    },
}
