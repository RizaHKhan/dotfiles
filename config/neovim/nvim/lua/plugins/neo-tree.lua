return {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = true,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        "antosha417/nvim-lsp-file-operations",
        "folke/snacks.nvim",
    },
    opts = function(_, opts)
        local function on_move(data) Snacks.rename.on_rename_file(data.source, data.destination) end
        local events = require "neo-tree.events"
        opts.event_handlers = opts.event_handlers or {}

        vim.list_extend(opts.event_handlers, {
            { event = events.FILE_MOVED, handler = on_move },
            { event = events.FILE_RENAMED, handler = on_move },
        })

        opts.source_selector = {
            winbar = false,
            statusline = false,
        }
    end,
}
