-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec

return {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
        style = {
            inactive = false,
        },
        -- change colorscheme
        colorscheme = "teide-darker", -- set the colorscheme to use
        -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
        highlights = {
            init = {
                -- Normal = { bg = "#212830" },
                NormalNC = { bg = "NONE" },
                NormalFloat = { bg = "NONE" },
                FloatBorder = { bg = "NONE" },
                WinSeparator = { fg = "#606060" },
                SignColumn = { bg = "NONE" },
                NeoTreeNormal = { bg = "NONE" },
                NeoTreeNormalNC = { bg = "NONE" },
                NeoTreeWinSeparator = { fg = "#606060", bg = "NONE" },
            }, -- this table overrides highlights in all themes
            astrodark = { -- a table of overrides/changes when applying the astrotheme theme
                Normal = { bg = "#212830" },
                NormalNC = { bg = "NONE" }, -- set the background of NormalNC to transparent
                WinSeparator = { fg = "#404040" },
                NeoTreeNormal = { bg = "#151b23" }, -- set the background of NeoTreeNormal to match Normal
                SignColumn = { bg = "NONE" }, -- set the background of SignColumn to match Normal
                NeoTreeWinSeparator = { bg = "#151b23", fg = "#151b23" }, -- set the background of NeoTreeWinSeparator to match Normal
            },
        },
        -- Icons can be configured throughout the interface
        icons = {
            -- configure the loading of the lsp in the status line
            LSPLoading1 = "⠋",
            LSPLoading2 = "⠙",
            LSPLoading3 = "⠹",
            LSPLoading4 = "⠸",
            LSPLoading5 = "⠼",
            LSPLoading6 = "⠴",
            LSPLoading7 = "⠦",
            LSPLoading8 = "⠧",
            LSPLoading9 = "⠇",
            LSPLoading10 = "⠏",
            VimIcon = "",
            ScrollText = "",
            GitBranch = "",
            GitAdd = "",
            GitChange = "",
            GitDelete = "",
        },
        status = {
            -- define the separators between each section
            separators = {
                left = { "", "" }, -- separator for the left side of the statusline
                right = { " ", "" }, -- separator for the right side of the statusline
                tab = { "", "" },
            },
            -- add new colors that can be used by heirline
            colors = function(hl)
                local get_hlgroup = require("astroui").get_hlgroup
                -- use helper function to get highlight group properties
                local comment_fg = get_hlgroup("Comment").fg
                hl.git_branch_fg = comment_fg
                hl.git_added = comment_fg
                hl.git_changed = comment_fg
                hl.git_removed = comment_fg
                hl.blank_bg = get_hlgroup("Folded").fg
                hl.file_info_bg = get_hlgroup("Visual").bg
                hl.nav_icon_bg = get_hlgroup("String").fg
                hl.nav_fg = hl.nav_icon_bg
                hl.folder_icon_bg = get_hlgroup("Error").fg
                return hl
            end,
            attributes = {
                mode = { bold = true },
            },
            icon_highlights = {
                file_icon = {
                    statusline = false,
                },
            },
        },
    },
}
