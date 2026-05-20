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

-- 診断設定はトグルシステム（22_toggle.lua）で管理
-- ここでは基本設定のみ（トグルで変更されない項目）
vim.diagnostic.config({
    update_in_insert = false,
    severity_sort = true,
})

-- 遅延実行も削除（トグルシステムと競合するため）

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
    capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- 特別な設定が必要なサーバーのみ個別設定
vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { "vim", "use" } },
            -- workspace.libraryはlazydev.nvimが管理
            workspace = {
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

-- HTML LSPの設定
vim.lsp.config('html', {
    settings = {
        html = {
            format = {
                enable = true,
                wrapLineLength = 120,
                unformatted = "wbr",
                contentUnformatted = "pre,code,textarea",
                indentInnerHtml = false,
                preserveNewLines = true,
                maxPreserveNewLines = 10,
                indentHandlebars = false,
                endWithNewline = false,
                extraLiners = "head, body, /html",
                wrapAttributes = "auto",
                templating = false,
                unformattedContentDelimiter = "",
            },
            suggest = {
                html5 = true,
            },
            validate = {
                scripts = true,
                styles = true,
            },
            hover = {
                documentation = true,
                references = true,
            },
        },
    },
    init_options = {
        configurationSection = { "html", "css", "javascript" },
        embeddedLanguages = {
            css = true,
            javascript = true,
        },
        provideFormatter = true,
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

-- 補完エンジン（blink.cmp）の設定はlua/plugins/lsp.luaのopts内で行う

-- auto_hover機能
vim.api.nvim_create_autocmd({ "CursorHold" }, {
    pattern = "*",
    callback = function()
        if vim.g.toggle_auto_hover == 1 then
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then return end
            -- グローバル関数を使用（フック処理で統一的にボーダーが適用される）
            if _G.show_lsp_hover then
                _G.show_lsp_hover()
            else
                -- フォールバック（グローバル関数が未定義の場合）
                vim.lsp.buf.hover({ focus = false })
            end
        end
    end,
})

-- none-ls設定
local null_ls = require("null-ls")
null_ls.setup({
    sources = {},
    on_attach = function(client, bufnr)
        -- グローバル設定の on_attach が適用される
    end,
})