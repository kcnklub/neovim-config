return {
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		config = function()
			vim.o.background = "dark"
			vim.cmd([[colorscheme gruvbox]])
		end,
	},
}
