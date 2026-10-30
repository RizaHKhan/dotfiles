-- Customize None-ls sources

---@type LazySpec
return {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
        opts = opts or {}
        local null_ls = require "null-ls"
        local helpers = require "null-ls.helpers"

        opts.sources = opts.sources or {}

        -- oxfmt is the formatter for everything it supports; no prettier.
        table.insert(
            opts.sources,
            helpers.make_builtin {
                name = "oxfmt",
                method = null_ls.methods.FORMATTING,
                filetypes = {
                    "css",
                    "graphql",
                    "html",
                    "htmlangular",
                    "javascript",
                    "javascriptreact",
                    "json",
                    "jsonc",
                    "less",
                    "markdown",
                    "scss",
                    "typescript",
                    "typescriptreact",
                    "vue",
                    "yaml",
                },
                generator_opts = {
                    command = "oxfmt",
                    args = { "--stdin-filepath", "$FILENAME" },
                    to_stdin = true,
                    -- project copy first, so it follows the repo's version and .oxfmtrc.json
                    dynamic_command = require("null-ls.helpers.command_resolver").from_node_modules(),
                    runtime_condition = function(params) return params.bufname ~= nil and params.bufname ~= "" end,
                },
                factory = helpers.formatter_factory,
            }
        )

        return opts
    end,
}
