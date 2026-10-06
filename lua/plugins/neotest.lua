return {
    {
        "rcasia/neotest-java",
        ft = "java",
        dependencies = {
            "mfussenegger/nvim-jdtls",
            "mfussenegger/nvim-dap",
        },
    },
    {
        "nvim-neotest/neotest",
        cmd = "Neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "rcasia/neotest-java",
        },
        keys = {
            {
                "<leader>tt",
                function()
                    require("neotest").run.run()
                end,
                desc = "Run Nearest Test",
            },
            {
                "<leader>tf",
                function()
                    require("neotest").run.run(vim.fn.expand("%"))
                end,
                desc = "Run Test File",
            },
            {
                "<leader>ta",
                function()
                    require("neotest").run.run(vim.uv.cwd())
                end,
                desc = "Run All Tests",
            },
            {
                "<leader>tl",
                function()
                    require("neotest").run.run_last()
                end,
                desc = "Run Last Test",
            },
            {
                "<leader>td",
                function()
                    require("neotest").run.run({ strategy = "dap" })
                end,
                desc = "Debug Nearest Test",
            },
            {
                "<leader>ts",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "Toggle Test Summary",
            },
            {
                -- capital O because <leader>to is tabnew
                "<leader>tO",
                function()
                    require("neotest").output.open({ enter = true, auto_close = true })
                end,
                desc = "Show Test Output",
            },
            {
                "<leader>tP",
                function()
                    require("neotest").output_panel.toggle()
                end,
                desc = "Toggle Test Output Panel",
            },
            {
                "<leader>tS",
                function()
                    require("neotest").run.stop()
                end,
                desc = "Stop Test Run",
            },
            {
                "]T",
                function()
                    require("neotest").jump.next({ status = "failed" })
                end,
                desc = "Next Failed Test",
            },
            {
                "[T",
                function()
                    require("neotest").jump.prev({ status = "failed" })
                end,
                desc = "Previous Failed Test",
            },
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-java")({}),
                },
            })
        end,
    },
}
