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
    branch = "feat/custom-ci",
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
            providers = {
                bitbucket = {
                    user = env.BITBUCKET_USER or vim.env.BITBUCKET_USER or "rkhan@camcloud.com",
                    token = env.BITBUCKET_TOKEN or vim.env.BITBUCKET_TOKEN or "",
                    cache_ttl = 300,
                    ci = {
                        backend = {
                            fetch = function(context, opts, done)
                                -- Fetch pipelines with their stages and jobs.
                                done({}, nil)
                            end,

                            fetch_job = function(context, pipeline, job, done)
                                -- Fetch the updated job.
                                done(job, nil)
                            end,

                            fetch_job_log = function(context, pipeline, job, done)
                                done({ raw = "Your log output here" }, nil)
                            end,

                            parse = function(log)
                                -- Return cleaned lines or your own nested groups.
                                return log.lines
                            end,
                        },
                    },
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
                            key = "M",
                            layout = "compact", -- "compact" or "plain"
                            search = repository_search("camcloud", "~/camcloud/repos") .. ' author.nickname = "rkhan"',
                        },
                        {
                            name = "Others",
                            key = "O",
                            layout = "plain", -- "compact" or "plain"
                            search = repository_search("camcloud", "~/camcloud/repos") .. ' author.nickname != "rkhan"',
                        },
                    },
                },
                github = {
                    ---@type AtlasGitHubViewConfig[]
                    views = {
                        {
                            name = "My PRs",
                            key = "1",
                            search = "author:@me sort:updated-desc",
                        },
                        {
                            name = "Repo",
                            key = "2",
                            search = "repo:seanseaver/LabSpend-Laravel author:seanseaver",
                        },
                    },
                },
            },
            issues = {
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
                        ALE = {
                            customfield_10003 = {
                                name = "Approvers",
                                format = function(value)
                                    if type(value) ~= "table" or #value == 0 then
                                        return nil -- nil hides the field
                                    end

                                    return table.concat(value, ", ")
                                end,
                                hl_group = "AtlasChipActive",
                                display = "chip", -- "chip" (default) or "table"
                            },
                        },
                    },

                    ---@type JiraViewConfig[]
                    views = {
                        {
                            name = "My Board",
                            key = "M",
                            jql = "project = ALE AND assignee = currentUser() ORDER BY updated DESC",
                        },
                    },
                } or nil,
            },
        }
    end,
}
