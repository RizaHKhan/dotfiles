return {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = true,
    keys = {
        { "<leader>ge", false },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        "antosha417/nvim-lsp-file-operations",
    },
    opts = function(_, opts)
        opts.use_popups_for_input = false
        opts.enable_git_status = false
        opts.sources = { "filesystem" }
        opts.filesystem = opts.filesystem or {}
        opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
        opts.filesystem.filtered_items.hide_gitignored = false
        opts.source_selector = {
            winbar = true,
            statusline = false,
            sources = {
                { source = "filesystem" },
            },
        }
    end,
}
