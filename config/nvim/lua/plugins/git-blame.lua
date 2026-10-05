---@type LazySpec
return {
    "f-person/git-blame.nvim",
    opts = {
        enabled = false,
        message_template = "<author> • <date> • <summary> • <<sha>>",
        date_format = "%r",
        delay = 200,
        virtual_text_column = 1,
    },
}
