return {
    "mistweaverco/kulala.nvim",
    branch = "develop",
    enabled = true,
    ft = { "http", "rest" },
    opts = {
        global_keymaps = true,
        global_keymaps_prefix = "<leader>r",
        kulala_keymaps_prefix = "",
        kulala_keymaps = {},
        contenttypes = {
            -- ["application/json"] = {
            --     ft = "json",
            --     formatter = { "jq", "." },
            --     pathresolver = require("kulala.parser.jsonpath").parse,
            -- },
            ["application/xml"] = {
                ft = "xml",
                formatter = { "xmllint", "--format", "-" },
                pathresolver = { "xmllint", "--xpath", "{{path}}", "-" },
            },
            ["text/html"] = {
                ft = "html",
                formatter = { "xmllint", "--format", "--html", "-" },
                pathresolver = {},
            },
        },
        ui = {
            formatter = true,
            max_response_size = 10000000,
            pickers = {
                snacks = {
                    layout = function()
                        local has_snacks, snacks_picker = pcall(require, "snacks.picker")
                        return not has_snacks and {}
                            or vim.tbl_deep_extend("force", snacks_picker.config.layout "horizontal", {})
                    end,
                },
            },
        },
        debug = true,
    },
}
