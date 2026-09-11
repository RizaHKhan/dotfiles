-- Customize Mason

---@type LazySpec
return {
    -- use mason-tool-installer for automatically installing Mason packages
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        -- overrides `require("mason-tool-installer").setup(...)`
        opts = {
            -- Make sure to use the names found in `:Mason`
            auto_update = false,
            run_on_start = true,
            start_delay = 3000, -- 3 second delay
            ensure_installed = {
                -- install language servers
                "lua-language-server",
                "laravel-ls",
                "phpactor",
                "vtsls",
                "vue-language-server",

                -- install formatters
                "stylua",
                "pint",

                -- install debuggers
                "debugpy",
                "delve",

                -- install any other package
                "tree-sitter-cli",
            },
        },
    },
}
