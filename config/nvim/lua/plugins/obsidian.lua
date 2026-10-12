---@type LazySpec
return {
    {
        "obsidian-nvim/obsidian.nvim",
        cmd = "Obsidian",
        event = { "BufReadPre " .. vim.fn.expand "~/obsidian-vault/**.md" },
        opts = {
            open = {
                -- Do not require the Obsidian Advanced URI community plugin.
                use_advanced_uri = false,
            },
        },
    },
    {
        "AstroNvim/astrocore",
        opts = {
            mappings = {
                n = {
                    ["gf"] = {
                        function()
                            local ok, obsidian = pcall(require, "obsidian")
                            local has_obsidian_link = false

                            if ok and obsidian.api and obsidian.api.cursor_link then
                                local link_ok, link = pcall(obsidian.api.cursor_link, 0)
                                has_obsidian_link = link_ok and link ~= nil
                            end

                            if has_obsidian_link then
                                vim.cmd "Obsidian follow_link"
                            else
                                pcall(vim.cmd.normal, { "gf", bang = true })
                            end
                        end,
                        desc = "Obsidian Follow Link",
                    },
                },
            },
        },
    },
}
