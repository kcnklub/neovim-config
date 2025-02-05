return {
    {
        "mrjones2014/legendary.nvim",
        keys = {
            { "<C-S-p>", "<cmd>Legendary<cr>", desc = "Legendary" },
            { "<leader>hc", "<cmd>Legendary<cr>", desc = "Command Palette" },
        },
        opts = {
            which_key = { auto_register = true },
        },
    },
    {
        "folke/which-key.nvim",
        dependencies = {
            "mrjones2014/legendary.nvim",
        },
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")
            wk.setup({
                show_help = true,
                plugins = { spelling = true },
                layout = {
                    height = { min = 4, max = 25 },
                    width = { min = 20, max = 50 },
                    spacing = 3,
                    align = "left",
                },
            })

            wk.add({
                { "<leader>w", "<cmd>w<cr>", desc = "Save" },
            })
        end,
    },
}
