-- 新しいNeovim 0.11 LSP設定
-- vim.lsp.config() と vim.lsp.enable() を使用

-- 環境設定
local is_windows = vim.fn.has('win64') == 1

-- Masonの基本設定（そのまま）
require("mason").setup({
    install_root_dir = is_windows
        and vim.fn.expand('$LOCALAPPDATA/nvim-data/mason')
        or nil,
    providers = {
        "mason.providers.registry-api"
    },
    ui = {
        check_outdated_packages_on_open = true,
        border = "rounded",
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
        keymaps = {
            toggle_package_expand = "<CR>",
            install_package = "i",
            update_package = "u",
            check_package_version = "c",
            update_all_packages = "U",
            check_outdated_packages = "C",
            uninstall_package = "X",
        }
    },
    max_concurrent_installers = 4,
})

-- Mason-LSPConfig設定（Mason 2.0の新機能を使用）
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
    ensure_installed = {
        "lua_ls", "rust_analyzer", "html", "cssls", "ts_ls", "jsonls",
        "pyright", "ruff", "ruby_lsp", "bashls", "marksman", "omnisharp",
    },
    automatic_installation = false,
    automatic_enable = true,  -- Mason 2.0の新機能：自動でvim.lsp.enable()
})

-- Mason-null-ls設定（そのまま）
local mason_null_ls = require("mason-null-ls")
mason_null_ls.setup({
    ensure_installed = {},
    automatic_installation = false,
})

-- 診断設定（そのまま）
vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = false,
    update_in_insert = false,
    severity_sort = true,
})

vim.defer_fn(function()
    vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        underline = false,
        update_in_insert = false,
        severity_sort = true,
    })
end, 500)

-- グローバル設定（全LSPサーバー共通）
vim.lsp.config('*', {
    on_attach = function(client, bufnr)
        -- LSPキーマップはm系列で設定済み（21_keymap.luaで定義）
        
        -- フォーマット機能がある場合のみ保存時フォーマットを有効化
        if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("LspFormat_" .. bufnr, { clear = true }),
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })
        end
    end,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- 特別な設定が必要なサーバーのみ個別設定
vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { "vim", "use" } },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = { enable = false },
        },
    },
})

vim.lsp.config('rust_analyzer', {
    settings = {
        ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
        },
    },
})

vim.lsp.config('ruff', {
    cmd = {'ruff', 'server', '--preview'},
    settings = {
        organizeImports = true,
        fixAll = true,
    },
})

vim.lsp.config('ruby_lsp', {
    settings = {
        ruby_lsp = {
            formatter = "syntax_tree",
            diagnostics = true,
            codeActions = true,
        },
    },
})

-- OmniSharp専用設定（競合回避）
vim.lsp.config('omnisharp', {
    cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
    filetypes = {'cs'},
    root_markers = {'*.csproj', '*.sln', '.git'},
    settings = {
        omnisharp = {
            FormattingOptions = {
                EnableEditorConfigSupport = true
            },
            Sdk = {
                IncludePrereleases = true
            }
        }
    },
    on_attach = function(client, bufnr)
        -- フォーマット機能を無効化（エラー回避）
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        
        -- キーマップは21_keymap.luaのm系列を使用
    end,
})

-- Mason 2.0のautomatic_enable = trueにより、手動のvim.lsp.enable()は不要
-- インストールされたサーバーは自動的に有効化される

-- 補完設定（nvim-cmp）- 変更なし
local cmp_ok, cmp = pcall(require, "cmp")
if not cmp_ok then
    return
end

local lspkind_ok, lspkind = pcall(require, 'lspkind')
if not lspkind_ok then
    lspkind = nil
end

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },

    sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "vsnip",    priority = 750 },
        { name = "buffer",   priority = 500 },
        { name = "path",     priority = 250 },
        { name = "emoji",    priority = 100 },
    }),

    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<Tab>"] = cmp.mapping.select_next_item(),

        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
        }),
        ['<C-l>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<Esc>'] = cmp.mapping.close(),
    }),

    formatting = lspkind_ok and {
        format = lspkind.cmp_format({
            mode = 'symbol_text',
            maxwidth = 50,
            ellipsis_char = '...',
            before = function(entry, vim_item)
                vim_item.menu = ({
                    nvim_lsp = "[LSP]",
                    vsnip = "[Snippet]",
                    buffer = "[Buffer]",
                    path = "[Path]",
                    emoji = "[Emoji]",
                })[entry.source.name]
                return vim_item
            end
        })
    } or {
        format = function(entry, vim_item)
            vim_item.menu = ({
                nvim_lsp = "[LSP]",
                vsnip = "[Snippet]",
                buffer = "[Buffer]",
                path = "[Path]",
                emoji = "[Emoji]",
            })[entry.source.name]
            return vim_item
        end
    },

    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },

    experimental = {
        ghost_text = true,
    },
})

-- auto_hover機能
vim.api.nvim_create_autocmd({ "CursorHold" }, {
    pattern = "*",
    callback = function()
        if vim.g.toggle_auto_hover == 1 then
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then return end
            vim.lsp.buf.hover({
                focus = false,
                border = "rounded"
            })
        end
    end,
})

-- コマンドライン補完
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- none-ls設定
local null_ls = require("null-ls")
null_ls.setup({
    sources = {},
    on_attach = function(client, bufnr)
        -- グローバル設定の on_attach が適用される
    end,
})