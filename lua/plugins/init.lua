return {
    "nvim-lua/plenary.nvim",
    {
        "nvim-tree/nvim-web-devicons",
        dependency = { "DaikyXendo/nvim-material-icon" },
        config = function()
            require("nvim-web-devicons").setup({
                override = require("nvim-web-devicons").get_icons(),
            })
        end,
    },
    {
        "aserowy/tmux.nvim",
        config = function()
            require("tmux").setup({
                navigation = {
                    enable_default_keybindings = false,
                },
            })
        end,
        keys = {
            {
                "<C-H>",
                "<cmd>lua require('tmux').move_left()<cr>)",
            },
            {
                "<C-J>",
                "<cmd>lua require('tmux').move_bottom()<cr>)",
            },
            {
                "<C-K>",
                "<cmd>lua require('tmux').move_top()<cr>)",
            },
            {
                "<C-L>",
                "<cmd>lua require('tmux').move_right()<cr>)",
            },
        },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        lazy = false,
        main = "ibl",
        opts = {},
        config = function()
            local highlight = {
                "RainbowRed",
                "RainbowYellow",
                "RainbowBlue",
                "RainbowOrange",
                "RainbowGreen",
                "RainbowViolet",
                "RainbowCyan",
            }

            local hooks = require("ibl.hooks")
            -- create the highlight groups in the highlight setup hook, so they are reset
            -- every time the colorscheme changes
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
                vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
                vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
                vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
                vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
                vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
                vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
            end)
            require("ibl").setup({ indent = { highlight = highlight } })
        end,
    },
}
