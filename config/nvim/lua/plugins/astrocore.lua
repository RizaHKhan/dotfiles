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
            },
            g = { -- vim.g.<key>
                -- configure global vim variables (vim.g)
                -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
                -- This can be found in the `lua/lazy_setup.lua` file
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
                ["M"] = { cmd = ":MarkdownPreview<cr>", desc = "Markdown Preview" },
                ["<leader>M"] = { cmd = ":MarkdownPreviewStop<cr>", desc = "Close Markdown Preview" },
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
        },
    },
}
