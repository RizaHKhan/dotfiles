---@type LazySpec
return {
    "folke/noice.nvim",
    opts = {
        views = {
            hover = {
                border = { style = "rounded", padding = { 0, 0 } },
                win_options = {
                    winhighlight = {
                        Normal = '',
                        FloatBorder = "LspHoverBorder",
                    },
                },
            },
        },
    },
}
