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
        opts.source_selector = {
            winbar = false,
            statusline = false,
        }
    end,
}
