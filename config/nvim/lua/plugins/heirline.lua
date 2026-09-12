return {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
        opts.winbar = nil
        local status = require "astroui.status"
        opts.statusline = {
            hl = { fg = "fg", bg = "bg" },
            status.component.mode {
                mode_text = {
                    icon = { kind = "VimIcon", padding = { right = 1, left = 1 } },
                },
                surround = {
                    separator = "left",
                    color = function() return { main = status.hl.mode_bg(), right = "blank_bg" } end,
                },
            },
            status.component.builder {
                { provider = "" },
                surround = {
                    separator = "left",
                    color = { main = "blank_bg", right = "file_info_bg" },
                },
            },
             status.component.file_info {
                 filename = { fallback = "Empty", modify = ":." },
                 filetype = false,
                 file_read_only = false,
                 padding = { right = 2 },
                 surround = { separator = "left", condition = false, color = "file_info_bg" },
             },
             status.component.git_branch {
                 git_branch = { padding = { left = 2, right = 2 } },
                 hl = { fg = "#7DCFFF", bold = true },
                 surround = { separator = "none", color = { bg = "NONE" } },
             },
             status.component.git_diff {
                 padding = { left = 1 },
                 surround = { separator = "none", color = { bg = "NONE" } },
                 added = { hl = { fg = "#6B9B6B" } },
                 changed = { hl = { fg = "#D4A574" } },
                 removed = { hl = { fg = "#C94F4F" } },
             },
             status.component.fill(),
             status.component.lsp {
                 surround = { separator = "none", color = { bg = "NONE" } },
                 padding = { left = 1, right = 1 },
             },
             status.component.builder {
                 { provider = function() return string.format("%d:%d", vim.fn.line ".", vim.fn.col ".") end },
                 surround = { separator = "right", condition = false, color = "file_info_bg" },
                 padding = { left = 0, right = 1 },
             },
        }
    end,
}
