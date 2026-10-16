-- Customize None-ls sources

---@type LazySpec
return {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
        opts = opts or {}
        local null_ls = require "null-ls"

        opts.sources = opts.sources or {}

        table.insert(opts.sources, null_ls.builtins.formatting.prettier.with {
            command = "oxfmt",
            prefer_local = "node_modules/.bin",
            args = { "--stdin-filepath", "$FILENAME" },
            runtime_condition = function(params) return params.bufname ~= nil and params.bufname ~= "" end,
        })

        return opts
    end,
}
