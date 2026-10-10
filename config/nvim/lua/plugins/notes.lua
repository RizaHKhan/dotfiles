---@type LazySpec
return {
    "ibhagwan/fzf-lua",
    keys = {
        {
            "<leader>nl",
            function()
                require("fzf-lua").files {
                    cwd = vim.fn.expand "~/dotfiles/notes/linux",
                    prompt = "Linux notes> ",
                }
            end,
            desc = "Linux Notes",
        },
        {
            "<leader>nL",
            function()
                require("fzf-lua").live_grep {
                    cwd = vim.fn.expand "~/dotfiles/notes/linux",
                    prompt = "Search Linux notes> ",
                }
            end,
            desc = "Search Linux Notes",
        },
    },
}
