-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
        -- Configuration table of features provided by AstroLSP
        features = {
            codelens = false,
            inlay_hints = false, -- enable/disable inlay hints on start
            semantic_tokens = true, -- enable/disable semantic token highlighting
        },
        -- customize lsp formatting options
        formatting = {
            -- control auto formatting on save
            format_on_save = {
                enabled = false, -- enable or disable format on save globally
                allow_filetypes = { -- enable format on save for specified filetypes only
                    -- "go",
                },
                ignore_filetypes = { -- disable format on save for specified filetypes
                    "python",
                },
            },
            disabled = { -- disable formatting capabilities for the listed language servers
                -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
                -- "lua_ls",
                "volar",
                "tsserver",
                "vtsls",
                "vue_ls",
            },
            timeout_ms = 1000, -- default format timeout
            -- filter = function(client) -- fully override the default formatting function
            --   return true
            -- end
        },
        -- enable servers that you already have installed without mason
        servers = {
            -- "pyright"
        },
        -- customize language server configuration options passed to `lspconfig`
        ---@diagnostic disable: missing-fields
        config = {
            -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
            vtsls = {
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
                settings = {
                    vtsls = {
                        tsserver = {
                            globalPlugins = {
                                {
                                    name = "@vue/typescript-plugin",
                                    location = vim.fn.stdpath "data"
                                        .. "/mason/packages/vue-language-server/node_modules/@vue/language-server/bin/typescript-plugin",
                                    languages = { "vue" },
                                    configNamespace = "typescript",
                                    enableForWorkspaceTypeScriptVersions = true,
                                },
                            },
                        },
                    },
                },
            },
            volar = {
                init_options = {
                    vue = {
                        hybridMode = true,
                    },
                },
            },
            phpactor = {
                init_options = {
                    ["language_server.diagnostics_on_update"] = false,
                    ["language_server.diagnostics_on_open"] = false,
                    ["language_server.diagnostics_on_save"] = false,
                    ["language_server_phpstan.enabled"] = true,
                    ["language_server_php_cs_fixer.enabled"] = true,
                    ["language_server_psalm.enabled"] = false,
                    ["language_server_completion.trim_leading_dollar"] = true,
                    ["language_server_php_cs_fixer.enabled true"] = true,
                },
            },
        },
        -- customize how language servers are attached
        handlers = {
            -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
            -- function(server, opts) require("lspconfig")[server].setup(opts) end

            -- the key is the server that is being setup with `lspconfig`
            tsserver = false,
            -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
            -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
        },
        -- Configure buffer local auto commands to add when attaching a language server
        autocmds = {
            -- first key is the `augroup` to add the auto commands to (:h augroup)
            lsp_codelens_refresh = {
                cond = "textDocument/codeLens",
                {
                    event = "LspAttach",
                    desc = "Enable codelens (buffer)",
                    callback = function(args) vim.lsp.codelens.enable(true, { bufnr = args.buf }) end,
                },
            },
        },
        -- mappings to be set up on attaching of a language server
        mappings = {
            n = {
                -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
                gD = {
                    function() vim.lsp.buf.declaration() end,
                    desc = "Declaration of current symbol",
                    cond = "textDocument/declaration",
                },
                ["<Leader>lr"] = false, -- disable LSP rename to allow Laravel routes keybinding
                ["<Leader>uY"] = {
                    function() require("astrolsp.toggles").buffer_semantic_tokens() end,
                    desc = "Toggle LSP semantic highlight (buffer)",
                    cond = function(client)
                        return client.server_capabilities.semanticTokensProvider ~= nil
                            and vim.lsp.semantic_tokens ~= nil
                    end,
                },
            },
        },
        -- A custom `on_attach` function to be run after the default `on_attach` function
        -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
        on_attach = function(client, bufnr)
            -- this would disable semanticTokensProvider for all clients
            -- client.server_capabilities.semanticTokensProvider = nil
        end,
    },
}
