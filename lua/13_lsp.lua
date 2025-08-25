-- 環境?定
local is_windows = vim.fn.has('win64') == 1

-- Masonの基本設定
require("mason").setup({
    -- Windowsの場合、インストールパスに日本語が含まれていると問題が起きることがあるので注意
    install_root_dir = is_windows
        and vim.fn.expand('$LOCALAPPDATA/nvim-data/mason') -- Windows用パス
        or nil,                                            -- デフォルトパスを使用
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

-- Mason-LSPConfig設定（自動インストール対応）
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
    -- 確実に動作するLanguage Serverのみ自動インストール
    ensure_installed = {
        -- 核となる言語（100%動作保証）
        "lua_ls",        -- Lua (Neovim設定用)
        "rust_analyzer", -- Rust

        -- Web開発（確実に動作）
        "html",   -- HTML
        "cssls",  -- CSS
        "ts_ls",  -- TypeScript/JavaScript

        "jsonls", -- JSON

        -- 基本言語
        "pyright",                  -- Python
        "ruff",                     -- Python linter/formatter (LSP)
        "ruby_lsp",                 -- Ruby (Shopify)
        "bashls",                   -- Bash
        "marksman",                 -- Markdown
        "omnisharp",                -- C# (Masonでインストールのみ、設定は手動)
    },
    automatic_installation = false, -- 手動管理で安定性確保
    handlers = {
        -- pyrightとruffは自動で設定
        function(server_name)
            if server_name == "pyright" or server_name == "ruff" then
                require('lspconfig')[server_name].setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                })
            end
        end,
    }
})

-- Mason-null-ls設定（フォーマッター・リンターの自動インストール）
local mason_null_ls = require("mason-null-ls")
mason_null_ls.setup({
    ensure_installed = {
        -- フォーマッター・リンターはここに追加
    },
    automatic_installation = false,
})

-- LSPサーバーの自動設定
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- 共通のon_attach関数
local on_attach = function(client, bufnr)
    -- LSPキーマップはm系列で設定済み（21_keymap.luaで定義）
    -- デフォルトのg系列は使用しない

    -- フォーマット機能がある場合のみ保存時フォーマットを有効化
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormat", {}),
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ async = false })
            end,
        })
    end
end

-- 標準診断設定（signsのみ有効）
vim.diagnostic.config({
    virtual_text = false, -- virtual_textは無効
    signs = true,         -- エラー行判別用にsignsを有効
    underline = false,    -- アンダーラインは無効
    update_in_insert = false,
    severity_sort = true,
})

-- 確実に設定するため遅延実行
vim.defer_fn(function()
    vim.diagnostic.config({
        virtual_text = false,
        signs = true,      -- signsを有効化
        underline = false, -- アンダーラインは無効
        update_in_insert = false,
        severity_sort = true,
    })
end, 500)

-- 手動でのLSP設定（omnisharpを除外して設定）
local servers = {
    "lua_ls", "rust_analyzer", "html", "cssls",
    "ts_ls", "jsonls", "ruby_lsp", "bashls", "marksman"
    -- pyrightとruffは定義ジャンプが重複するため除外（ensure_installedで自動設定される）
    -- omnisharpはここから除外（下で個別設定）
}

for _, server in ipairs(servers) do
    local server_config = {
        on_attach = on_attach,
        capabilities = capabilities,
    }

    -- 個別設定
    if server == "lua_ls" then
        server_config.settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                },
                diagnostics = {
                    globals = { "vim", "use" },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                telemetry = {
                    enable = false,
                },
            },
        }
    elseif server == "rust_analyzer" then
        server_config.settings = {
            ["rust-analyzer"] = {
                cargo = {
                    allFeatures = true,
                },
                checkOnSave = {
                    command = "clippy",
                },
            },
        }
    elseif server == "ruby_lsp" then
        server_config.settings = {
            ruby_lsp = {
                formatter = "syntax_tree", -- syntax_treeの方が高速
                diagnostics = true,
                codeActions = true,
            },
        }
    end

    -- サーバーが利用可能な場合のみ設定
    if lspconfig[server] then
        lspconfig[server].setup(server_config)
    end
end

-- OmniSharp専用設定（競合回避）
lspconfig.omnisharp.setup({
    cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
    root_dir = lspconfig.util.root_pattern("*.csproj", "*.sln"),
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

        -- キーマップは21_keymap.luaのm系列を使用（共通のon_attach関数は呼ばない）
    end,
    capabilities = capabilities,
})

-- 補完設定（nvim-cmp）- エラーハンドリング追加
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

    -- 補完ソースの優先度設定
    sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "vsnip",    priority = 750 },
        { name = "buffer",   priority = 500 },
        { name = "path",     priority = 250 },
        { name = "emoji",    priority = 100 },
    }),

    -- キーマッピング
    mapping = cmp.mapping.preset.insert({
        -- 選択
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<Tab>"] = cmp.mapping.select_next_item(),

        -- スクロール
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        -- 確定・キャンセル
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
        }),
        ['<C-l>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<Esc>'] = cmp.mapping.close(),
    }),

    -- フォーマット設定
    formatting = lspkind_ok and {
        format = lspkind.cmp_format({


            mode = 'symbol_text',
            maxwidth = 50,
            ellipsis_char = '...',
            before = function(entry, vim_item)
                -- ソース名を表示
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

    -- ウィンドウ設定
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },

    -- 実験的機能
    experimental = {
        ghost_text = true,
    },
})

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
    sources = {
        -- 他のフォーマッター・リンターはここに追加
    },
    on_attach = on_attach,
})
