require("mason").setup({
    providers = {
        -- "mason.providers.client",
        "mason.providers.registry-api" -- This is the default provider. You can still include it here if you want, as a fallback to the client provider.
    },
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        }
    }
})
-- Reference highlight

null_ls = require('null-ls')
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
    ensure_installed = {
        "nimls",
        "solargraph",
        "pyright",
        "marksman",
        "jsonls",
        "yamlls",
        "taplo",
        "vimls",
    },
    automatic_instllation = true,
})
-- auto lspconfig setting
require('mason-lspconfig').setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {}
  end,
}

require('mason-null-ls').setup({
    ensure_installed = {
        "black"
    },
    automatic_installation = false,
    handlers = {},
})
null_ls.setup({
   sources = {
       null_ls.builtins.formatting.prettierd,
       null_ls.builtins.diagnostics.rubocop,
       null_ls.builtins.formatting.rubocop,
       null_ls.builtins.formatting.black,
       null_ls.builtins.formatting.goimports,
   },
   -- debug = false,
})
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

local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
    },
    mapping = cmp.mapping.preset.insert({
        -- prev
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        -- next
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        -- complete
        ["<CR>"] = cmp.mapping.confirm { select = true },
        ['<C-l>'] = cmp.mapping.complete(),
        -- abort
        ['<C-e>'] = cmp.mapping.abort(),
        ['<BackSpace>'] = cmp.mapping.abort(),
    }),
    experimental = {
        ghost_text = true,
    },
})
