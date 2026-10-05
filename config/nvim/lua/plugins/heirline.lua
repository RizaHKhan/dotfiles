return {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
        opts.winbar = nil
        local status = require "astroui.status"
        local function git_branch_name()
            local file = vim.api.nvim_buf_get_name(0)
            local dir = file ~= "" and vim.fn.fnamemodify(file, ":p:h") or vim.fn.getcwd()
            local branch = vim.fn.systemlist { "git", "-C", dir, "branch", "--show-current" }
            if vim.v.shell_error == 0 and branch[1] and branch[1] ~= "" then return branch[1] end

            local commit = vim.fn.systemlist { "git", "-C", dir, "rev-parse", "--short", "HEAD" }
            return vim.v.shell_error == 0 and commit[1] or ""
        end

        opts.statusline = {
            status.component.file_info {
                filename = { fallback = "Empty", modify = ":." },
                file_icon = { hl = false },
                filetype = false,
                file_read_only = false,
                hl = { fg = "#9ECE6A" },
                padding = { right = 1 },
                surround = { separator = "NONE", condition = false, color = "NONE" },
            },
            status.component.builder {
                { provider = "|" },
                hl = { fg = "#7A7A7A", bg = "NONE" },
                padding = { right = 1 },
            },
            status.component.builder {
                {
                    provider = function()
                        local branch = vim.b.gitsigns_head or git_branch_name()
                        return branch ~= "" and (branch .. "  ") or ""
                    end,
                },
                hl = { fg = "#7DCFFF", bg = "NONE", bold = true },
            },
            status.component.fill(),
            status.component.lsp {
                hl = { fg = "#7A7A7A", bg = "NONE" },
                surround = { separator = "none", color = { bg = "NONE" } },
                padding = { left = 1, right = 1 },
            },
            status.component.builder {
                { provider = function() return string.format("%d:%d", vim.fn.line ".", vim.fn.col ".") end },
                hl = { fg = "#E0AF68", bg = "NONE" },
                surround = { separator = "NONE", condition = false, color = "NONE" },
                padding = { left = 0, right = 1 },
            },
        }
    end,
}
