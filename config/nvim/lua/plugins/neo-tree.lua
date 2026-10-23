return {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = true,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        "antosha417/nvim-lsp-file-operations",
    },
    opts = function(_, opts)
        -- Avoid expensive git scans when opening directories from paths that
        -- accidentally resolve to a very large git root, e.g. ~.
        opts.enable_git_status = false
        opts.sources = { "filesystem", "buffers" }
        opts.filesystem = opts.filesystem or {}
        opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
        opts.filesystem.filtered_items.hide_gitignored = false
        opts.source_selector = {
            winbar = false,
            statusline = false,
        }
    end,
}
