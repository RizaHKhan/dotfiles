local function repositories(workspace, directory)
    local repos = {}
    local expanded = directory:gsub("^~", os.getenv "HOME")
    local p = io.popen("ls " .. directory)
    if p then
        for repo in p:lines() do
            table.insert(repos, { workspace = workspace, repo = repo })
        end
        p:close()
    end
    return repos
end

local function repository_search(workspace, directory)
    local selectors = {}
    for _, repo in ipairs(repositories(workspace, directory)) do
        table.insert(selectors, string.format("repo:%s/%s", repo.workspace, repo.repo))
    end
    return table.concat(selectors, " ")
end

local function dotenv()
    local path = vim.fn.stdpath "config" .. "/.env"
    if vim.fn.filereadable(path) == 0 then return {} end

    local values = {}
    for _, line in ipairs(vim.fn.readfile(path)) do
        local key, value = line:match "^%s*([%w_]+)%s*=%s*(.-)%s*$"
        if key and value then values[key] = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1") end
    end
    return values
end

return {
    "emrearmagan/atlas.nvim",
    branch = "dev",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "MeanderingProgrammer/render-markdown.nvim",
        { "esmuellert/codediff.nvim", version = "2.67.2" }, -- atlas targets codediff 2.67.x; v4 breaks diff
        "dlyongemallo/diffview-plus.nvim",
    },
    config = function()
        local env = dotenv()
        local jira_base_url = env.JIRA_BASE_URL or vim.env.JIRA_BASE_URL or ""
        local jira_email = env.JIRA_EMAIL or vim.env.JIRA_EMAIL or ""
        local jira_token = env.JIRA_TOKEN or vim.env.JIRA_TOKEN or ""
        local jira_enabled = jira_base_url ~= "" and jira_email ~= "" and jira_token ~= ""

        require("atlas").setup {
            ui = {
                picker = "snacks",
            },
            keymaps = {
                pulls = {
                    review = {
                        -- atlas defaults to ]c/[c, which shadows codediff's hunk navigation
                        next_comment = "]C",
                        prev_comment = "[C",
                    },
                    custom = {
                        {
                            key = "ga",
                            desc = "Approve PR",
                            callback = function(context, done)
                                require("atlas.pulls.actions").run("approve", context, done)
                            end,
                        },
                        {
                            key = "rc",
                            desc = "Request changes",
                            callback = function(context, done)
                                require("atlas.pulls.actions").run("request_changes", context, done)
                            end,
                        },
                        {
                            key = "sr",
                            desc = "Submit review",
                            callback = function(context, done)
                                require("atlas.pulls.actions").run("submit_review", context, done)
                            end,
                        },
                    },
                },
            },
            providers = {
                bitbucket = {
                    user = env.BITBUCKET_USER or vim.env.BITBUCKET_USER or "rkhan@camcloud.com",
                    token = env.BITBUCKET_TOKEN or vim.env.BITBUCKET_TOKEN or "",
                    cache_ttl = 300,
                },
                github = {
                    cache_ttl = 300,
                },
                jira = jira_enabled and {
                    base_url = jira_base_url,
                    email = jira_email,
                    token = jira_token,
                    cache_ttl = 300,
                } or nil,
            },
            pulls = {
                default_merge_method = "squash",
                diff = {
                    open_cmd = "CodeDiff",
                },
                repo_config = {
                    -- Maps `workspace/repo` to local paths. Used for checkout, diff (`gd`), and custom actions.
                    paths = {
                        ["camcloud/*"] = "~/camcloud/repos/*",
                        ["seanseaver/LabSpend-Laravel"] = "~/labspend",
                    },
                    settings = {
                        ["camcloud/atlas"] = {
                            readme = "README.md", -- optional, defaults to README.md
                        },
                    },
                },
                -- Pipelines: no CI column in the Bitbucket PR list (GitHub/GitLab only). Statuses show in the
                -- PR detail -- overview lists pipelines (`za` folds stages/steps), commits shows per-commit
                -- state. `K`/`<CR>` on one opens the pipelines panel for job logs, `A` for run/stop (numeric
                -- Bitbucket Pipelines only; external CI statuses are read-only), `gx` opens it in the browser.
                bitbucket = {
                    views = {
                        {
                            name = "Me",
                            key = "1",
                            layout = "compact", -- "compact" or "plain"
                            search = repository_search("camcloud", "~/camcloud/repos") .. ' author.nickname = "rkhan"',
                        },
                        {
                            name = "ALE-9803",
                            key = "2",
                            layout = "compact", -- "compact" or "plain"
                            search = repository_search("camcloud", "~/camcloud/repos")
                                .. ' (title ~ "ALE-9803" OR description ~ "ALE-9803")',
                        },
                        {
                            name = "ALE-9817",
                            key = "3",
                            layout = "compact", -- "compact" or "plain"
                            search = repository_search("camcloud", "~/camcloud/repos")
                                .. ' (title ~ "ALE-9817" OR description ~ "ALE-9817")',
                        },
                        {
                            name = "ALE-9837",
                            key = "4",
                            layout = "compact", -- "compact" or "plain"
                            search = repository_search("camcloud", "~/camcloud/repos")
                                .. ' (title ~ "ALE-9837" OR description ~ "ALE-9837")',
                        },
                        {
                            name = "Others",
                            key = "5",
                            layout = "grouped", -- "compact", "grouped", or "plain"
                            search = repository_search("camcloud", "~/camcloud/repos") .. ' author.nickname != "rkhan"',
                        },
                        {
                            name = "Mobile",
                            key = "m",
                            layout = "plain", -- "compact" or "plain"
                            search = "repo:camcloud/camcloud-ios-v2 repo:camcloud/camcloud-android-v2"
                                .. ' author.nickname != ""',
                        },
                    },
                },
                github = {
                    ---@type AtlasGitHubViewConfig[]
                    views = {
                        {
                            name = "My PRs",
                            key = "1",
                            layout = "grouped", -- "compact", "grouped", or "plain"
                            search = "author:@me sort:updated-desc",
                        },
                        {
                            name = "Repo",
                            key = "2",
                            layout = "grouped", -- "compact", "grouped", or "plain"
                            search = "repo:seanseaver/LabSpend-Laravel sort:updated-desc author:seanseaver",
                        },
                        {
                            name = "Other",
                            key = "3",
                            layout = "grouped", -- "compact", "grouped", or "plain"
                            search = "repo:seanseaver/LabSpend-Laravel sort:updated-desc -author:@me -author:seanseaver",
                        },
                    },
                },
            },
            issues = {
                -- Enables related-item loading. For Jira, atlas.nvim uses Jira's
                -- dev-status API to surface linked Bitbucket PRs in the issue detail
                -- related-items picker/chips (`gl` / "Open references").
                with_relationships = true,
                github = {
                    ---@type AtlasGitHubIssuesViewConfig[]
                    views = {
                        {
                            name = "Labspend",
                            key = "1",
                            layout = "plain",
                            search = "is:open sort:updated-desc repo:seanseaver/LabSpend-Laravel",
                        },
                        {
                            name = "High Priority",
                            key = "2",
                            layout = "plain",
                            search = 'is:issue repo:seanseaver/LabSpend-Laravel state:open label:"High Priority"',
                        },
                        {
                            name = "Production Bug",
                            key = "3",
                            layout = "plain",
                            search = 'is:issue repo:seanseaver/LabSpend-Laravel state:open label:"Production Bug"',
                        },
                    },
                },
                jira = jira_enabled and {
                    project_config = {
                        -- Current atlas.nvim Jira config uses global display options plus per-project
                        -- custom fields keyed by Jira project key.
                        ALE = {},
                    },

                    ---@type AtlasJiraViewConfig[]
                    views = {
                        {
                            name = "My Board",
                            key = "M",
                            layout = "plain",
                            jql = "project = ALE AND assignee = currentUser() ORDER BY updated DESC",
                        },
                    },
                } or nil,
            },
        }

        -- Atlas' Jira config accepts `components = { editor = true }`, but the
        -- installed editor does not render project fields yet. Until that lands,
        -- default ALE's required Components field so Jira accepts issue creation.
        if jira_enabled then
            local jira_issues = require "atlas.issues.providers.jira.api.issues"
            jira_issues._dotfiles_create_issue = jira_issues._dotfiles_create_issue or jira_issues.create_issue
            local create_issue = jira_issues._dotfiles_create_issue
            jira_issues.create_issue = function(fields, callback)
                if vim.tbl_get(fields, "project", "key") == "ALE" and fields.components == nil then
                    fields = vim.tbl_deep_extend("force", {}, fields, { components = { { name = "Web" } } })
                end
                return create_issue(fields, callback)
            end
        end
    end,
}
