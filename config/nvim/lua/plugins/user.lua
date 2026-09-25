---@type LazySpec

return {
    {
        "akinsho/toggleterm.nvim",
        enabled = true,
        opts = {
            shade_terminals = false,
            highlights = {
                NormalFloat = { link = "Normal" },
                FloatBorder = { link = "Normal" },
            },
        },
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "BufRead",
        config = function() require("lsp_signature").setup() end,
    },
    { "max397574/better-escape.nvim", enabled = false },
    {
        "L3MON4D3/LuaSnip",
        config = function(plugin, opts)
            require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
            -- add more custom luasnip configuration such as filetype extend or custom snippets
            local luasnip = require "luasnip"
            luasnip.filetype_extend("javascript", { "javascriptreact" })
        end,
    },
    {
        "windwp/nvim-autopairs",
        config = function(plugin, opts)
            require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
            -- add more custom autopairs configuration such as custom rules
            local npairs = require "nvim-autopairs"
            local Rule = require "nvim-autopairs.rule"
            local cond = require "nvim-autopairs.conds"
            npairs.add_rules(
                {
                    Rule("$", "$", { "tex", "latex" })
                        -- don't add a pair if the next character is %
                        :with_pair(
                            cond.not_after_regex "%%"
                        )
                        -- don't add a pair if  the previous character is xxx
                        :with_pair(
                            cond.not_before_regex("xxx", 3)
                        )
                        -- don't move right when repeat character
                        :with_move(cond.none())
                        -- don't delete if the next character is xx
                        :with_del(
                            cond.not_after_regex "xx"
                        )
                        -- disable adding a newline when you press <cr>
                        :with_cr(cond.none()),
                },
                -- disable for .vim files, but it work for another filetypes
                Rule("a", "a", "-vim")
            )
        end,
    },
    {
        "okuuva/auto-save.nvim",
        version = "^1.0.0", -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
        cmd = "ASToggle", -- optional for lazy loading on command
        event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
        opts = {
            -- your config goes here
            -- or just leave it empty :)
        },
    },
    {
        "vhyrro/luarocks.nvim",
    },
    {
        "s1n7ax/nvim-window-picker",
        name = "window-picker",
        event = "VeryLazy",
        version = "2.*",
        config = function() require("window-picker").setup() end,
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        config = function(_, opts)
            require("flash").setup(opts)
            vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#000000", bg = "#d75f00", bold = true })
        end,
        -- stylua: ignore
        keys = {
            { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
            { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
            { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
            { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        },
    },
    {
        "serhez/teide.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    {
        "esmuellert/codediff.nvim",
        version = "2.67.2", -- atlas.nvim 0.7.x targets codediff 2.67.x (v4.x removed ui/scroll)
        cmd = "CodeDiff",
    },
    { "yochem/jq-playground.nvim" },
    {
        "ywpkwon/yank-path.nvim",
        dependencies = { "ibhagwan/fzf-lua" },
        config = function()
            require("yank-path").setup {
                default_mapping = false,
                use_oil = true,
            }
        end,
    },
    {
        "ravitemer/mcphub.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
        config = function() require("mcphub").setup() end,
    },
    {
        "stevearc/oil.nvim",
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {},
        -- Optional dependencies
        dependencies = {
            { "nvim-mini/mini.icons", opts = {} },

            { -- AstroCore is always loaded on startup, so making it a dependency doesn't matter
                "AstroNvim/astrocore",
                opts = {
                    mappings = { -- define a mapping to load the plugin module
                        n = {
                            ["="] = { cmd = ":Oil<cr>", desc = "Oil" },
                        },
                    },
                },
            },
        },
        config = function()
            require("oil").setup {
                default_file_explorer = false,
            }
        end,
        -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
        -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
        lazy = false,
    },
    {
        "willfish/herdr-navigator.nvim",
        config = function() require("herdr-navigator").setup() end,
    },
    {
        "cajames/copy-reference.nvim",
        opts = {}, -- optional configuration
        keys = {
            { "Y", "<cmd>CopyReference line<cr>", mode = { "v" }, desc = "Copy file:line reference" },
        },
    },
    {
        "selimacerbas/markdown-preview.nvim",
        dependencies = { "selimacerbas/live-server.nvim" },
        config = function()
            require("markdown_preview").setup {
                -- all optional; sane defaults shown
                instance_mode = "takeover", -- "takeover" (one tab) or "multi" (tab per instance)
                port = 0, -- 0 = auto (8421 for takeover, OS-assigned for multi)
                open_browser = true,
                default_theme = "dark", -- "dark" or "light"; initial preview theme
                debounce_ms = 300,
            }
        end,
    },
    {
        "adalessa/laravel.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-neotest/nvim-nio",
        },
        ft = { "php", "blade" },
        event = { "BufEnter composer.json" },
        keys = {
            { "<leader>ll", function() Laravel.pickers.laravel() end, desc = "Laravel: Picker" },
            { "<leader>la", function() Laravel.pickers.artisan() end, desc = "Laravel: Artisan Picker" },
            { "<leader>lr", function() Laravel.pickers.routes() end, desc = "Laravel: Routes Picker" },
            { "<leader>lm", function() Laravel.pickers.make() end, desc = "Laravel: Make Picker" },
            {
                "<leader>lc",
                function() Laravel.pickers.commands() end,
                desc = "Laravel: Custom Commands Picker",
            },
            { "<leader>lo", function() Laravel.pickers.resources() end, desc = "Laravel: Resources Picker" },
            { "<leader>lh", function() Laravel.run "artisan docs" end, desc = "Laravel: Documentation" },
            { "<leader>lt", function() Laravel.commands.run "actions" end, desc = "Laravel: Code Actions" },
            { "<leader>lu", function() Laravel.commands.run "hub" end, desc = "Laravel: Artisan Hub" },
            { "<leader>lp", function() Laravel.commands.run "command_center" end, desc = "Laravel: Command Center" },
            { "<c-g>", function() Laravel.commands.run "view:finder" end, desc = "Laravel: View Finder" },
            {
                "gf",
                function()
                    if Laravel.app("gf").cursorOnResource() then return "<cmd>lua Laravel.commands.run('gf')<cr>" end
                    return "gf"
                end,
                expr = true,
                noremap = true,
                desc = "Laravel: Go to resource",
            },
        },
        opts = {
            features = {
                pickers = {
                    provider = "fzf-lua", -- telescope | fzf-lua | snacks | ui.select
                },
            },
        },
    },
    {
        "kopecmaciej/vi-sql.nvim",
        config = function()
            require("vi-sql").setup {
                -- Press this inside vi-sql to hide the window (change to taste)
                hide_key = "q",
            }
        end,
        cmd = { "ViSQL", "ViSQLJump" },
        keys = {
            { "<leader>vs", "<cmd>ViSQL<cr>", desc = "Open vi-sql" },
            -- { "<leader>vj", ":ViSQLJump ", desc = "vi-sql: jump to table", silent = false },
        },
    },
    {
        "ChmaraX/herdr-nvim",
        opts = {
            keymaps = false,
            clear_after_send = true,
        },
        keys = {
            { "L", function() require("herdr-nvim").list_comments() end, desc = "Agent comments: list" },
            {
                "C",
                function() require("herdr-nvim").comment_selection() end,
                mode = "x",
                desc = "Agent comments: comment selection",
            },
            {
                "S",
                function() require("herdr-nvim").send_all { submit = true } end,
                desc = "Agent comments: send to agent",
            },
        },
    },
}
