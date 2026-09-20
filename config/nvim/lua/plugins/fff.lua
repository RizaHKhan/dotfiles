---@type LazySpec
return {
    "dmtrKovalenko/fff",
    version = "^0.10",
    build = function()
        local dl = require "fff.download"
        local done = false
        local fatal_err = nil
        dl.ensure_downloaded({ force = false }, function(ok, _)
            if ok then
                done = true
                return
            end
            dl.ensure_downloaded({ force = true, version = "v0.10.6" }, function(ok2, err2)
                done = true
                if not ok2 then fatal_err = err2 end
            end)
        end)
        vim.wait(120000, function() return done end, 100)
        if fatal_err then
            error("Failed to download fff binary: " .. fatal_err)
        end
    end,
    lazy = false,
    opts = {
        title = "FFFiles",
        prompt = "🪿 ",
        max_threads = 4,
        lazy_sync = true,
        layout = {
            height = 0.8,
            width = 0.8,
            prompt_position = "bottom",
            preview_position = "right",
            preview_size = 0.5,
        },
        file_picker = {
            current_file_label = "(current)",
            fuzzy_query_highlighting = false,
        },
        preview = {
            enabled = true,
        },
        debug = {
            enabled = false,
            show_scores = false,
        },
    },
    keys = {
        {
            "<leader><space>",
            function() require("fff").find_files() end,
            desc = "Smart Find Files (fff)",
        },
        {
            "<leader>/",
            function() require("fff").live_grep() end,
            desc = "Live Grep (fff)",
        },
        {
            "fw",
            function() require("fff").live_grep_under_cursor() end,
            desc = "Current word search (fff)",
            mode = { "n", "x" },
        },
        {
            "<leader>ff",
            function() require("fff").find_files() end,
            desc = "Find files (fff)",
        },
        {
            "<leader>fg",
            function() require("fff").live_grep() end,
            desc = "Live grep (fff)",
        },
        {
            "<leader>fr",
            function() require("fff").scan_files() end,
            desc = "Rescan files (fff)",
        },
    },
}
