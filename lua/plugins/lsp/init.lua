return {
    {
        "neovim/nvim-lspconfig",
        event = "BufReadPre",
        dependencies = {
            { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
            {
                "folke/neodev.nvim",
                opts = {
                    library = { plugins = { "neotest", "nvim-dap-ui" }, types = true },
                },
            },
            { "smjonas/inc-rename.nvim", config = true },
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "jay-babu/mason-null-ls.nvim",
        },
        opts = {
            servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
                            },
                            completion = { callSnippet = "Replace" },
                            telemetry = { enable = false },
                            hint = { enable = false },
                        },
                    },
                },
                dockerls = {},
            },
            setup = {
                lua_ls = function(_, _)
                    local lsp_utils = require("plugins.lsp.utils")
                    lsp_utils.on_attach(function(client, buffer)
                        if client.name == "lua_ls" then
                            vim.keymap.set("n", "<leader>dX", function()
                                require("osv").run_this()
                            end, { buffer = buffer, desc = "OSV Run" })
                            vim.keymap.set("n", "<leader>dL", function()
                                require("osv").launch({ 8086 })
                            end, { buffer = buffer, desc = "OSV Launch" })
                        end
                    end)
                end,
            },
        },
        config = function(plugin, opts)
            require("plugins.lsp.servers").setup(plugin, opts)
        end,
    },
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        cmd = "Mason",
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        opts = {
            ensure_installed = {
                "stylua",
                "typescript-language-server",
                "rust-analyzer",
                "codelldb",
                "shfmt",
                "gopls",
            },
        },
        config = function(_, opts)
            require("mason").setup()
            local mason_registry = require("mason-registry")
            for _, tool in ipairs(opts.ensure_installed) do
                local p = mason_registry.get_package(tool)
                if not p:is_installed() then
                    p:install()
                end
            end
        end,
    },
    {
        "jose-elias-alvarez/null-ls.nvim",
        event = "BufReadPre",
        dependencies = {
            "mason.nvim",
        },
        config = function()
            local nls = require("null-ls")
            nls.setup({
                sources = {
                    nls.builtins.formatting.stylua,
                    nls.builtins.formatting.shfmt,
                },
            })
        end,
    },
    {
        "jay-babu/mason-null-ls.nvim",
        opts = {
            ensure_installed = nil,
            automatic_installation = false,
            automatic_setup = false,
        },
    },
    {
        "utilyre/barbecue.nvim",
        event = "VeryLazy",
        dependencies = {
            "neovim/nvim-lspconfig",
            "SmiteshP/nvim-navic",
            "nvim-tree/nvim-web-devicons",
        },
        config = true,
    },
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        opts = {
            use_diagnostic_signs = true,
        },
        keys = {
            { "<leader>cd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document Diagnostics" },
            { "<leader>cD", "<cmd>Trouble diagnostics toggle<cr>", desc = "Document Diagnostics" },
        },
    },
}
