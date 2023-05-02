return {
	{
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		config = function()
			require("catppuccin").setup({
				transparent_background = true,
				flavour = "mocha",
			})
			vim.cmd([[colorscheme catppuccin]])
		end,
	},
}
