return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/neotest-python",
        "olimorris/neotest-phpunit",
        "nvim-neotest/neotest-jest",
        "marilari88/neotest-vitest",
        "V13Axel/neotest-pest",
    },
    opts = function(_, opts)
        -- See all config options with :h neotest.Config
        opts.discovery = {
            -- Drastically improve performance in ginormous projects by
            -- only AST-parsing the currently opened buffer.
            enabled = false,
            -- Number of workers to parse files concurrently.
            -- A value of 0 automatically assigns number based on CPU.
            -- Set to 1 if experiencing lag.
            concurrent = 1,
        }
        opts.running = {
            -- Run tests concurrently when an adapter provides multiple commands to run.
            concurrent = true,
        }
        opts.summary = {
            -- Enable/disable animation of icons.
            animated = false,
        }
        opts.adapters = {
            require "neotest-python",
            require "neotest-vitest",
            require "neotest-phpunit" {
                root_ignore_files = { "tests/Pest.php" },
            },
            require "neotest-pest" {},
            require "neotest-jest" {
                jestCommand = "npm test --",
                jestConfigFile = "custom.jest.config.ts",
                env = { CI = true },
                cwd = function(_) return vim.fn.getcwd() end,
            },
        }
    end,
}
