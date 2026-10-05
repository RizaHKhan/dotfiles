-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
        -- Configure core features of AstroNvim
        features = {
            large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
            autopairs = true, -- enable autopairs at start
            cmp = true, -- enable completion at start
            diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
            highlighturl = true, -- highlight URLs at start
            notifications = false, -- enable notifications at start
        },
        -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
        diagnostics = {
            virtual_text = true,
            virtual_lines = false, -- Neovim v0.11+ only
            update_in_insert = false,
            underline = false,
            severity_sort = true,
        },
        -- vim options can be configured here
        options = {
            opt = { -- vim.opt.<key>
                relativenumber = false, -- sets vim.opt.relativenumber
                number = true, -- sets vim.opt.number
                spell = false, -- sets vim.opt.spell
                signcolumn = "yes", -- sets vim.opt.signcolumn to yes
                wrap = false, -- sets vim.opt.wrap
                foldcolumn = "0",
                showtabline = 1,
                tabline = "%!v:lua.NumberedTabline()",
                cmdheight = 0,
            },
            g = { -- vim.g.<key>
                -- configure global vim variables (vim.g)
                -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
                -- This can be found in the `lua/lazy_setup.lua` file
                snacks_indent = false,
                snacks_scope = false,
            },
        },
        -- Mappings can be configured through AstroCore as well.
        -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
        mappings = {
            -- first key is the mode
            n = {
                -- navigate buffer tabs
                ["tt"] = { cmd = ":tabnew <cr>", desc = "New tab" },
                ["tc"] = { cmd = ":tabclose <cr>", desc = "Close tab" },
                ["<leader>jq"] = { cmd = ":JqPlayground<cr>", desc = "JQ" },
                [";d"] = { cmd = ":CodeDiff<cr>", desc = "Open Diffview" },
                [";h"] = { cmd = ":CodeDiff history %<cr>", desc = "Close Diffview" },
                ["<leader>gp"] = {
                    function() require("mini.diff").toggle_overlay(0) end,
                    desc = "Preview Git hunk overlay",
                },
                ["<leader>gb"] = { cmd = ":GitBlameToggle<cr>", desc = "Toggle Git blame for current line" },
                ["<leader>gr"] = {
                    function()
                        local diff = require "mini.diff"
                        local line = vim.api.nvim_win_get_cursor(0)[1]
                        local data = diff.get_buf_data(0)

                        for _, hunk in ipairs(data and data.hunks or {}) do
                            local hunk_start = hunk.buf_count > 0 and hunk.buf_start or math.max(hunk.buf_start, 1)
                            local hunk_end = hunk.buf_count > 0 and (hunk.buf_start + hunk.buf_count - 1) or hunk_start

                            if hunk_start <= line and line <= hunk_end then
                                diff.do_hunks(0, "reset", { line_start = hunk_start, line_end = hunk_end })
                                return
                            end
                        end

                        vim.notify("No Git hunk under cursor", vim.log.levels.INFO)
                    end,
                    desc = "Reset Git hunk",
                },
                ["M"] = { function() require("mdkite").start() end, desc = "Markdown Preview" },
                ["<leader>A"] = { cmd = ":Atlas<cr>", desc = "Atlas" },
                ["<leader>M"] = { function() require("mdkite").stop() end, desc = "Close Markdown Preview" },
                ["<leader>y"] = { cmd = ":YankPath<cr>", desc = "Yank path" },
                [".."] = {
                    cmd = function()
                        local word = vim.fn.expand "<cWORD>"
                        local row = unpack(vim.api.nvim_win_get_cursor(0))
                        local line = vim.api.nvim_get_current_line()
                        local s, e = line:find(word, 1, true)
                        if s and e then
                            local new_line = line:sub(1, s - 1)
                                .. "<"
                                .. word
                                .. "></"
                                .. word
                                .. ">"
                                .. line:sub(e + 1)
                            vim.api.nvim_set_current_line(new_line)
                            vim.api.nvim_win_set_cursor(0, { row, s + #word + 1 })
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", true)
                        end
                    end,
                    desc = "Wrap word in HTML tag, place cursor inside, and enter insert mode",
                },
            },
            x = {
                ["/"] = { "<Esc>/\\%V", desc = "Search within visual selection" },
                ["?"] = { "<Esc>?\\%V", desc = "Search backward within visual selection" },
            },
        },
    },
}
