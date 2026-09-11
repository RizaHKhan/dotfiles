-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
vim.filetype.add {
    extension = {
        ["http"] = "http",
    },
}

vim.opt.iskeyword:append { "-", "$" }
vim.opt.conceallevel = 2
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function() vim.opt_local.conceallevel = 0 end,
})
vim.opt.swapfile = false
vim.keymap.set("x", "p", '"_dP', { silent = true })

function _G.NumberedTabline()
    local s = ""
    for i = 1, vim.fn.tabpagenr "$" do
        local hl = i == vim.fn.tabpagenr() and "%#TabLineSel#" or "%#TabLine#"
        s = s .. hl .. " " .. i .. " "
    end
    return s .. "%#TabLineFill#"
end
