return {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
        {
            "microsoft/vscode-js-debug",
            -- After install, build it and rename the dist directory to out
            build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
            version = "1.*",
        },
        {
            "xdebug/vscode-php-debug",
            build = "npm install --legacy-peer-deps --no-save && npm run build",
        },
        {
            "mxsdev/nvim-dap-vscode-js",
            config = function()
                --@diagnostic disable-next-line: missing-fields
                require("dap-vscode-js").setup {
                    -- Path of node executable. Defaults to $NODE_PATH, and then "node"
                    node_path = "node",
                    -- which adapters to register in nvim-dap
                    adapters = {
                        "chrome",
                        "pwa-node",
                        "pwa-chrome",
                        "pwa-msedge",
                        "pwa-extensionHost",
                        "node-terminal",
                    },
                }
            end,
        },
        {
            "leoluz/nvim-dap-go",
        },
        {
            "jbyuki/one-small-step-for-vimkind",
        },
    },
    config = function()
        local dap = require "dap"

        require("dap-go").setup {
            dap_configurations = {
                {
                    type = "go",
                    name = "Attach remote",
                    mode = "remote",
                    request = "attach",
                },
            },
            delve = {
                path = "dlv",
                initialize_timeout_sec = 20,
                port = "${port}",
                args = {},
                build_flags = {},
                detached = vim.fn.has "win32" == 0,
                cwd = nil,
            },
            tests = {
                verbose = false,
            },
        }

        dap.adapters.python = {
            type = "executable",
            command = "/usr/bin/python3",
            args = {
                "-m",
                "debugpy.adapter",
            },
        }

        dap.configurations.python = {
            {
                type = "python",
                request = "launch",
                name = "Launch file",
                program = "${file}", -- This configuration will launch the current file if used.
            },
            {
                name = "Pytest: Current File",
                type = "python",
                request = "launch",
                module = "pytest",
                args = {
                    "${file}",
                    "-sv",
                    "--log-cli-level=INFO",
                    "--log-file=test_out.log",
                },
                console = "integratedTerminal",
            },
        }

        dap.adapters.php = {
            type = "executable",
            command = "node",
            args = { vim.fn.stdpath "data" .. "/lazy/vscode-php-debug/out/phpDebug.js" },
        }

        dap.configurations.php = {
            {
                type = "php",
                request = "launch",
                name = "Listen for Xdebug (Docker)",
                port = 9003,
                log = true,
                hostname = "0.0.0.0",
                pathMappings = {
                    ["/var/www/html"] = "${workspaceFolder}",
                },
            },
            {
                type = "php",
                request = "launch",
                name = "Listen for Xdebug on Sail",
                port = 9003,
                pathMappings = {
                    ["/var/www/html"] = "${workspaceFolder}",
                },
                hostname = "0.0.0.0",
            },
            {
                type = "php",
                request = "launch",
                name = "Listen for Xdebug (Local)",
                port = 9003,
                log = true,
                pathMappings = {
                    ["."] = "${workspaceFolder}",
                },
            },
        }

        for _, adapterType in ipairs { "node", "chrome", "msedge" } do
            local pwaType = "pwa-" .. adapterType

            dap.adapters[pwaType] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = {
                        vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
                        "${port}",
                    },
                },
            }

            -- this allow us to handle launch.json configurations
            -- which specify type as "node" or "chrome" or "msedge"
            dap.adapters[adapterType] = function(cb, config)
                local nativeAdapter = dap.adapters[pwaType]

                config.type = pwaType

                if type(nativeAdapter) == "function" then
                    nativeAdapter(cb, config)
                else
                    cb(nativeAdapter)
                end
            end
        end

        local enter_launch_url = function()
            local co = coroutine.running()
            return coroutine.create(function()
                vim.ui.input({ prompt = "Enter URL: ", default = "http://localhost:" }, function(url)
                    if url == nil or url == "" then
                        return
                    else
                        coroutine.resume(co, url)
                    end
                end)
            end)
        end

        for _, language in ipairs { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" } do
            dap.configurations[language] = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch file using Node.js (nvim-dap)",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                },
                {
                    type = "pwa-node",
                    request = "attach",
                    name = "Attach to process using Node.js (nvim-dap)",
                    processId = require("dap.utils").pick_process,
                    cwd = "${workspaceFolder}",
                },
                -- requires ts-node to be installed globally or locally
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch file using Node.js with ts-node/register (nvim-dap)",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    runtimeArgs = { "-r", "ts-node/register" },
                },
                {
                    type = "pwa-chrome",
                    request = "launch",
                    name = "Launch Chrome (nvim-dap)",
                    url = enter_launch_url,
                    webRoot = "${workspaceFolder}",
                    sourceMaps = true,
                },
                {
                    type = "pwa-msedge",
                    request = "launch",
                    name = "Launch Edge (nvim-dap)",
                    url = enter_launch_url,
                    webRoot = "${workspaceFolder}",
                    sourceMaps = true,
                },
            }
        end
    end,
}
