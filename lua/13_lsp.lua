-- 環境判定
local is_windows = vim.fn.has('win64') == 1

-- Masonの基本設定
require("mason").setup({
    -- Windowsの場合、インストールパスに日本語が含まれていると問題が起きることがあるので注意
    install_root_dir = is_windows
        and vim.fn.expand('$LOCALAPPDATA/nvim-data/mason')  -- Windows用パス
        or nil,  -- デフォルトパスを使用
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
        "lua_ls",           -- Lua (Neovim設定用)
        "rust_analyzer",    -- Rust
        
        -- Web開発（確実に動作）
        "html",            -- HTML
        "cssls",           -- CSS  
        "ts_ls",           -- TypeScript/JavaScript
        "jsonls",          -- JSON
        
        -- 基本言語
        "pyright",         -- Python
        "bashls",          -- Bash
        "marksman",        -- Markdown
        
        -- 手動インストール推奨（環境依存が強いもの）
        -- "nimls",         -- Nim (nim compiler required)
        -- "yamlls",        -- YAML (時々失敗)
        -- "taplo",         -- TOML (時々失敗)
        -- "vimls",         -- Vim script (古い)
        -- "clangd",        -- C/C++ (build tools required)
        -- "gopls",         -- Go (go required)
        -- "solargraph",    -- Ruby (gem環境依存)
    },
    automatic_installation = false, -- 手動管理で安定性確保
})
-- LSPサーバーの自動設定
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- 共通のon_attach関数
local on_attach = function(client, bufnr)
    -- LSPキーマップは21_keymap.luaで設定済み
    
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

-- 重複診断の削減設定（グローバル）
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        -- 同じ位置の診断を統合
        virtual_text = {
            spacing = 2,
            prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
    }
)

-- デフォルト設定
local default_setup = {
    on_attach = on_attach,
    capabilities = capabilities,
}

-- 個別LSP設定（確実に動作するサーバーのみ）
-- デフォルト設定をすべてのLSPに適用
local servers = {
    "lua_ls", "rust_analyzer", "html", "cssls", 
    "ts_ls", "jsonls", "pyright", "bashls", "marksman"
}

for _, server in ipairs(servers) do
    local server_config = default_setup
    
    -- 個別設定
    if server == "lua_ls" then
        server_config = vim.tbl_extend("force", default_setup, {
            settings = {
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
            },
        })
    elseif server == "rust_analyzer" then
        server_config = vim.tbl_extend("force", default_setup, {
            settings = {
                ["rust-analyzer"] = {
                    cargo = {
                        allFeatures = true,
                    },
                    checkOnSave = {
                        command = "clippy",
                    },
                },
            },
        })
    end
    
    -- サーバーが利用可能な場合のみ設定
    if lspconfig[server] then
        lspconfig[server].setup(server_config)
    end
end

-- フォーマッター・リンターはLSPビルトイン機能を優先使用
-- none-ls（null-lsの後継）は最小限の使用に留める

-- 理由：
-- 1. 多くのLSPサーバーにフォーマット機能が内蔵されている
-- 2. none-ls/null-lsは複雑性とエラーの原因になりやすい  
-- 3. LSPネイティブの方が設定が簡単で安定

-- 必要な場合のみnone-lsを使用（コメントアウトして無効化）
--[[
local none_ls_ok, null_ls = pcall(require, 'null-ls')
if none_ls_ok then
    null_ls.setup({
        sources = {
            -- 基本的なフォーマッターのみ（LSPで対応できないもの）
            null_ls.builtins.formatting.stylua,  -- Lua（lua_lsにフォーマット機能がない場合）
        },
        on_attach = function(client, bufnr)
            -- LSPと競合しないよう無効化
            client.server_capabilities.documentFormattingProvider = false
        end,
    })
end
--]]

-- Mason-null-ls も無効化（手動管理）
--[[
local mason_null_ls_ok, mason_null_ls = pcall(require, 'mason-null-ls')
if mason_null_ls_ok then
    mason_null_ls.setup({
        ensure_installed = {},
        automatic_installation = false,
        handlers = {},
    })
end
--]]

-- mason_lspconfig.setup_handlers({
--     function(server)
--         local opt = {
--             -- -- Function executed when the LSP server startup
--             on_attach = function(client, bufnr)
--                 --   local opts = { noremap=true, silent=true }
--                 -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
--                 vim.cmd 'autocmd BufWritePre * lua vim.lsp.buf.formatting_sync(nil, 1000)'
--             end,
--             capabilities = require('cmp_nvim_lsp').default_capabilities(
--                 vim.lsp.protocol.make_client_capabilities()
--             )
--         }
--         require('lspconfig')[server].setup(opt)
--     end,
-- })

-- require("lspconfig").sumneko_lua.setup({
--    settings = {
--         Lua = {
--             diagnostics = {
--                 -- Get the language server to recognize the `vim` global
--                 globals = { "vim", "use", "capabilities" },
--             },
--         },
--     },
-- })

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
        { name = "vsnip", priority = 750 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 250 },
        { name = "emoji", priority = 100 },
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
