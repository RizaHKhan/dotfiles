return {
    "RizaHKhan/nvim-dbee",
    requires = {
        "MunifTanjim/nui.nvim",
    },
    keys = {
        {
            "D",
            function() require("dbee").toggle() end,
        },
    },
    run = function()
        -- Install tries to automatically detect the install method.
        -- if it fails, try calling it with one of these parameters:
        --    "curl", "wget", "bitsadmin", "go"
        require("dbee").install()
    end,
    config = function()
        require("dbee").setup( --[[optional config]])
    end,
}
