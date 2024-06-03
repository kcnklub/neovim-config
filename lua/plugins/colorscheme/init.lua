return {
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        config = function()
            ---vim.cmd([[colorscheme gruvbox]])
        end,
    },
    {
        "rose-pine/neovim",
        lazy = false,
        config = function()
            require("rose-pine").setup({
                variant = "moon",
                dark_variant = "moon",
                dim_inactitve_window = true,
            })
            ---vim.cmd([[colorscheme rose-pine]])
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        config = function()
            vim.cmd([[colorscheme tokyonight-storm]])
        end,
    },
}
