local scratch_buf = nil
local function toggle_scratch()
    if scratch_buf and vim.api.nvim_buf_is_valid(scratch_buf) then
        local win = vim.fn.bufwinid(scratch_buf)
        if win ~= -1 then
            vim.api.nvim_win_close(win, true)
            return
        end
    else
        scratch_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[scratch_buf].buftype = "nofile"
        vim.bo[scratch_buf].bufhidden = "hide"
        vim.bo[scratch_buf].swapfile = false
        vim.bo[scratch_buf].filetype = "markdown"
    end
    vim.cmd "botright 60vnew"
    vim.api.nvim_win_set_buf(0, scratch_buf)
end

local function jump_reference(count)
    local ns = vim.api.nvim_create_namespace "vim_lsp_references"
    local extmarks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
    if #extmarks == 0 then
        local clients = vim.lsp.get_clients { bufnr = 0, method = "textDocument/documentHighlight" }
        if #clients > 0 then
            vim.lsp.buf.document_highlight()
            extmarks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
        end
    end
    if #extmarks == 0 then
        vim.cmd(count > 0 and "normal! *n" or "normal! *N")
        return
    end
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cur_row, cur_col = cursor[1] - 1, cursor[2]
    local target = nil
    if count > 0 then
        for _, m in ipairs(extmarks) do
            if m[2] > cur_row or (m[2] == cur_row and m[3] > cur_col) then
                target = m
                break
            end
        end
        target = target or extmarks[1]
    else
        for i = #extmarks, 1, -1 do
            local m = extmarks[i]
            if m[2] < cur_row or (m[2] == cur_row and m[3] < cur_col) then
                target = m
                break
            end
        end
        target = target or extmarks[#extmarks]
    end
    if target then
        vim.api.nvim_win_set_cursor(0, { target[2] + 1, target[3] })
    end
end

---@type LazySpec
return {
    {
        "folke/snacks.nvim",
        opts = function(_, opts)
            opts = opts or {}
            opts.picker = opts.picker or {}
            opts.picker.enabled = false
            return opts
        end,
    },
    {
        "ibhagwan/fzf-lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            {
                "AstroNvim/astrocore",
                opts = {
                    mappings = {
                        n = {
                            ["gl"] = { function() require("fzf-lua").git_blame() end, desc = "Blame line" },
                            ["<Leader>n"] = {
                                function()
                                    local ok, noice = pcall(require, "noice")
                                    if ok then
                                        noice.cmd "all"
                                    else
                                        vim.cmd "messages"
                                    end
                                end,
                                desc = "Notification History",
                            },
                            ["<Leader>un"] = {
                                function()
                                    local ok, noice = pcall(require, "noice")
                                    if ok then
                                        noice.cmd "dismiss"
                                    end
                                end,
                                desc = "Dismiss All Notifications",
                            },
                        },
                    },
                },
            },
        },
        cmd = "FzfLua",
        opts = function()
            local actions = require "fzf-lua.actions"
            return {
                "default-title",
                winopts = {
                    height = 0.85,
                    width = 0.85,
                    row = 0.35,
                    col = 0.50,
                    preview = {
                        layout = "horizontal",
                        horizontal = "right:50%",
                    },
                },
                keymap = {
                    builtin = {
                        ["<C-d>"] = "preview-page-down",
                        ["<C-u>"] = "preview-page-up",
                    },
                    fzf = {
                        ["ctrl-d"] = "preview-page-down",
                        ["ctrl-u"] = "preview-page-up",
                        ["ctrl-q"] = "select-all+accept",
                    },
                },
                buffers = {
                    sort_lastused = true,
                    actions = {
                        ["ctrl-x"] = { fn = actions.buf_del, reload = true },
                    },
                },
                git = {
                    status = {
                        prompt = "Git Status> ",
                        headers = false,
                        winopts = {
                            preview = {
                                layout = "horizontal",
                                horizontal = "right:55%",
                            },
                        },
                        actions = {
                            ["right"] = { fn = actions.git_unstage, reload = true },
                            ["left"] = { fn = actions.git_stage, reload = true },
                            ["ctrl-x"] = { fn = actions.git_reset, reload = true },
                        },
                    },
                    icons = {
                        ["M"] = { icon = "●", color = "yellow" },
                        ["D"] = { icon = "", color = "red" },
                        ["A"] = { icon = "", color = "green" },
                        ["R"] = { icon = "", color = "yellow" },
                        ["C"] = { icon = "", color = "yellow" },
                        ["T"] = { icon = "●", color = "magenta" },
                        ["?"] = { icon = "?", color = "magenta" },
                    },
                },
                previewers = {
                    git_diff = {
                        cmd_deleted = "git --no-pager diff --no-ext-diff --color HEAD --",
                        cmd_modified = "git --no-pager diff --no-ext-diff --color HEAD",
                        cmd_untracked = "git --no-pager diff --no-ext-diff --color --no-index /dev/null",
                    },
                },
            }
        end,
        config = function(_, opts)
            local fzf = require "fzf-lua"
            local ok_prev, previewer_fzf = pcall(require, "fzf-lua.previewer.fzf")
            if ok_prev and previewer_fzf.git_diff then
                local orig_cmdline = previewer_fzf.git_diff.cmdline
                previewer_fzf.git_diff.cmdline = function(self, o)
                    local ret = orig_cmdline(self, o)
                    local orig_act = ret.fn
                    ret.fn = function(items, fzf_lines, fzf_columns)
                        if not items or not items[1] then return orig_act(items, fzf_lines, fzf_columns) end
                        local s = items[1]
                        local utils = require "fzf-lua.utils"
                        local has_icon = function(icon)
                            return icon and s:find(icon .. utils.nbsp, 1, true) ~= nil
                        end
                        local path = require("fzf-lua.path").entry_to_file(s, self.opts)
                        if not path.path then return "" end
                        local escaped = require("fzf-lua.libuv").shellescape(path.path)
                        if has_icon(self.git_icons["D"]) then
                            return { cmd = string.format("%s %s", self.cmd_deleted, escaped) }
                        elseif has_icon(self.git_icons["?"]) or has_icon(self.git_icons["C"]) then
                            return { cmd = string.format("%s %s", self.cmd_untracked, escaped) }
                        end
                        return orig_act(items, fzf_lines, fzf_columns)
                    end
                    return ret
                end
            end
            fzf.setup(opts)
            fzf.register_ui_select()
        end,
        keys = {
            {
                "H",
                function() require("fzf-lua").buffers { sort_lastused = true } end,
                desc = "Buffers",
            },
            {
                "<leader>lsw",
                function() require("fzf-lua").lsp_live_workspace_symbols() end,
                desc = "LSP Workspace Symbols",
            },
            {
                "K",
                function() require("fzf-lua").git_status() end,
                desc = "Git Status Files",
            },
            {
                "<leader>:",
                function() require("fzf-lua").command_history() end,
                desc = "Command History",
            },
            {
                "gd",
                function() require("fzf-lua").lsp_definitions { jump1 = false } end,
                desc = "Goto Definition",
            },
            {
                "<leader>D",
                function() require("fzf-lua").diagnostics_document() end,
                desc = "Buffer Diagnostics",
            },
            {
                "R",
                function() require("fzf-lua").registers() end,
                desc = "Registers",
            },
            {
                "gm",
                function() require("fzf-lua").marks() end,
                desc = "Marks",
            },
            {
                "gl",
                function() require("fzf-lua").git_blame() end,
                desc = "Blame line",
            },
            {
                "gD",
                function() require("fzf-lua").lsp_declarations { jump1 = false } end,
                desc = "Goto Declaration",
            },
            {
                "gr",
                function() require("fzf-lua").lsp_references { jump1 = false } end,
                nowait = true,
                desc = "References",
            },
            {
                "gi",
                function()
                    require("fzf-lua").fzf_exec("gh issue list --limit 100", {
                        prompt = "Git Issues> ",
                        actions = {
                            ["default"] = function(selected)
                                local issue = selected[1] and selected[1]:match "^%s*(%d+)"
                                if issue then vim.fn.system { "gh", "issue", "view", "--web", issue } end
                            end,
                        },
                    })
                end,
                desc = "Git Issues",
            },
            {
                "gI",
                function() require("fzf-lua").lsp_implementations { jump1 = false } end,
                desc = "Goto Implementation",
            },
            {
                "gy",
                function() require("fzf-lua").lsp_typedefs { jump1 = false } end,
                desc = "Goto Type Definition",
            },
            {
                "<leader>n",
                function()
                    local ok, noice = pcall(require, "noice")
                    if ok then
                        noice.cmd "all"
                    else
                        vim.cmd "messages"
                    end
                end,
                desc = "Notification History",
            },
            {
                "<leader>un",
                function()
                    local ok, noice = pcall(require, "noice")
                    if ok then
                        noice.cmd "dismiss"
                    end
                end,
                desc = "Dismiss All Notifications",
            },
            {
                "<leader>.",
                toggle_scratch,
                desc = "Toggle Scratch Buffer",
            },
            {
                "<leader>S",
                toggle_scratch,
                desc = "Select Scratch Buffer",
            },
            {
                "]]",
                function() jump_reference(vim.v.count1) end,
                desc = "Next Reference",
                mode = { "n", "t" },
            },
            {
                "[[",
                function() jump_reference(-vim.v.count1) end,
                desc = "Prev Reference",
                mode = { "n", "t" },
            },
        },
    },
}
