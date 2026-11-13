local function enable_lig_detection()
    local rex = require "reviewr.rex"
    local terminals = rex.terminals
    rex.terminals = function()
        local list = terminals()
        local output = vim.fn.system { "ps", "-axo", "pid=,ppid=,pgid=,tpgid=,tty=,args=" }
        if vim.v.shell_error ~= 0 then return list end
        local processes = {}
        for line in output:gmatch "[^\n]+" do
            local pid, parent, group, foreground, tty, args =
                line:match "^%s*(%d+)%s+(%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%S+)%s+(.+)$"
            if pid then
                processes[tonumber(pid)] = {
                    parent = tonumber(parent),
                    active = group == foreground and tty ~= "??",
                    args = args,
                }
            end
        end
        local agents = require("reviewr.config").get().agents
        for _, terminal in ipairs(list) do
            local fg = terminal.foreground or {}
            if fg.name == "login" or fg.name == "lig" then
                local matches = {}
                for pid, process in pairs(processes) do
                    if process.active then
                        local ancestor, seen = pid, {}
                        while processes[ancestor] and not seen[ancestor] and ancestor ~= fg.pid do
                            seen[ancestor] = true
                            ancestor = processes[ancestor].parent
                        end
                        if ancestor == fg.pid then
                            local words = vim.split(vim.trim(process.args), "%s+")
                            for i = 1, math.min(2, #words) do
                                local name = vim.fn.fnamemodify(words[i], ":t")
                                if vim.tbl_contains(agents, name) then
                                    matches[#matches + 1] = { name = name, argv0 = name, pid = pid }
                                    break
                                end
                            end
                        end
                    end
                end
                -- Never guess when a wrapper contains several active agents.
                if #matches == 1 then
                    terminal.foreground = vim.tbl_extend("force", fg, matches[1])
                end
            end
        end
        return list
    end
end

local function comment(visual)
    local buf = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_get_name(buf) == "" then
        vim.notify("Open a file before adding a comment", vim.log.levels.WARN)
        return
    end
    local first, last = vim.fn.line ".", vim.fn.line "."
    if visual then
        first = vim.fn.line "v"
        if first > last then first, last = last, first end
        vim.api.nvim_feedkeys(vim.keycode "<Esc>", "nx", false)
    end
    -- Reviewr cannot read terminal snapshots as repository files. Keep the
    -- selected text in the comment itself, even after the snapshot is deleted.
    local scrollback = vim.b[buf].rex_scrollback
    local context = scrollback and vim.api.nvim_buf_get_lines(buf, first - 1, last, false)
    vim.ui.input({ prompt = "Agent question/comment: " }, function(body)
        if not body or vim.trim(body) == "" or not vim.api.nvim_buf_is_valid(buf) then return end
        vim.api.nvim_buf_call(buf, function()
            if context then
                local quoted = vim.tbl_map(function(line) return "> " .. line end, context)
                body = "Selected terminal output (not a project file):\n"
                    .. table.concat(quoted, "\n") .. "\n\n" .. body
            end
            local added = require("reviewr").add_comment { body = body, start = first, ["end"] = last }
            if added then vim.notify("Agent comment added") end
        end)
    end)
end

local function list_comments()
    local comments = require("reviewr").list_comments()
    if #comments == 0 then
        vim.notify("No agent comments")
        return
    end
    vim.ui.select(comments, {
        prompt = "Agent comments",
        format_item = function(c)
            return string.format("%s:%d-%d — %s", c.file, c.start, c["end"], c.body:gsub("\n", " "))
        end,
    }, function(c)
        if not c then return end
        if c.file == "[Rex terminal scrollback]" then
            vim.notify(c.body, vim.log.levels.INFO, { title = "Scrollback comment" })
            return
        end
        local path = vim.fs.joinpath(c.repo, c.file)
        vim.cmd.edit(vim.fn.fnameescape(path))
        vim.api.nvim_win_set_cursor(0, { math.min(c.start, vim.api.nvim_buf_line_count(0)), 0 })
    end)
end

local function send_comments()
    local reviewr = require "reviewr"
    local agent = vim.g.reviewr_agent
    if type(agent) == "table" then
        for _, field in ipairs { "name", "session", "block" } do
            if type(agent[field]) ~= "string" or agent[field] == "" then
                -- An incomplete pairing must fall back to Reviewr\'s agent picker.
                vim.g.reviewr_agent = nil
                break
            end
        end
    end
    -- Keep a snapshot so comments added during the agent picker are not cleared.
    local comments = reviewr.list_comments()
    reviewr.export("send", function(ok, result, destination)
        if not ok then
            vim.notify("Reviewr: " .. tostring(result), vim.log.levels.WARN)
            return
        end
        -- Only clear after delivery to an agent, not a fallback inbox/clipboard.
        local fallback = destination == "clipboard"
            or (destination or ""):find("/.reviewr/inbox/", 1, true)
        if not fallback then
            for _, c in ipairs(comments) do
                if c.sent then reviewr.delete_comment(c.id) end
            end
        end
        vim.notify("Reviewr: " .. result .. " comments exported to " .. tostring(destination))
    end)
end

---@type LazySpec
return {
    "paul-enz/reviewr.nvim",
    cmd = { "ReviewrOpen", "ReviewrScope", "ReviewrComment", "ReviewrTurn", "ReviewrExport", "ReviewrClear" },
    opts = {
        send_mode = "submit",
    },
    config = function(_, opts)
        enable_lig_detection()
        require("reviewr").setup(opts)
    end,
    keys = {
        { "<leader>Y", function() comment(false) end, desc = "Agent comments: comment line" },
        { "L", list_comments, desc = "Agent comments: list" },
        { "C", function() comment(true) end, mode = "x", desc = "Agent comments: comment selection" },
        { "S", send_comments, desc = "Agent comments: send to agent" },
    },
}
