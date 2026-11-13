require("actions")
require("keymaps")

rex.action {
    name = "floating_scrollback",
    title = "Open Scrollback in Neovim",
    run = function(ctx)
        if not ctx.block_id then error("No focused pane to capture") end
        local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
        local layer, err = rex.session.new_layer {
            session_id = ctx.session_id,
            bounds = { 0.05, 0.05, 0.9, 0.9 },
            focus = true,
            layout = rex.layout.block {
                flavor = "com.superlogical.terminal.shell",
                label = "Scrollback",
                options = {
                    command = {
                        "sh", config_home .. "/rex/scripts/scrollback.sh", ctx.session_id, ctx.block_id,
                    },
                },
            },
        }
        if not layer then error(err) end
        return layer
    end,
}


-- Share Neovim's managed reviewr copy. Reload Rex after plugin updates.
do
    local data_home = os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share"
    local path = data_home .. "/nvim/lazy/reviewr.nvim/rex/reviewr/init.lua"
    local ok, reviewr = pcall(dofile, path)
    if ok then reviewr.setup() end
end
