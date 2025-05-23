local install_root_dir = vim.fn.stdpath("data") .. "/mason"
local extension_path = install_root_dir .. "/packages/codelldb/extension/"
local codelldb_path = extension_path .. "adapter/codelldb"

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, { "rust" })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "simrat39/rust-tools.nvim", "rust-lang/rust.vim" },
        opts = {
            servers = {
                rust_analyzer = {
                    settings = {
                        ["rust_analyzer"] = {
                            cargo = { allFeatures = true },
                            checkOnSave = {
                                command = "cargo clippy",
                                extraArgs = { "--no-deps" },
                            },
                        },
                    },
                },
            },
            setup = {
                rust_analyzer = function(_, opts)
                    local lsp_utils = require("plugins.lsp.utils")
                    lsp_utils.on_attach(function(client, buffer)
                        if client.name == "rust_analyzer" then
                            vim.keymap.set(
                                "n",
                                "<leader>cR",
                                "<cmd>RustRunnables<cr>",
                                { buffer = buffer, desc = "Runnables" }
                            )
                            vim.keymap.set("n", "<leader>cl", function()
                                vim.lsp.codelens.run()
                            end, { buffer = buffer, desc = "Code lens" })
                        end
                    end)

                    require("rust-tools").setup({
                        tools = {
                            hover_actions = { border = "solid" },
                            on_initialized = function()
                                vim.api.nvim_create_autocmd(
                                    { "BufWritePost", "BufEnter", "CursorHold", "InsertLeave" },
                                    {
                                        pattern = { "*.rs" },
                                        callback = function()
                                            vim.lsp.codelens.refresh()
                                        end,
                                    }
                                )
                            end,
                        },
                        dap = {},
                        server = opts,
                    })

                    return true
                end,
            },
        },
    },
    {
        "mfussenegger/nvim-dap",
        opts = {
            setup = {
                codelldb = function()
                    local dap = require("dap")
                    dap.adapters.codelldb = {
                        type = "server",
                        port = "${port}",
                        executable = {
                            command = codelldb_path,
                            args = { "--port", "${port}" },
                        },
                    }

                    dap.configurations.cpp = {
                        {
                            name = "Launch file",
                            type = "codelldb",
                            request = "launch",
                            program = function()
                                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                            end,
                            cwd = "${workspaceFolder}",
                            stopOnEntry = false,
                        },
                    }

                    dap.configurations.c = dap.configurations.cpp
                    dap.configurations.rust = dap.configurations.cpp
                end,
            },
        },
    },
}
