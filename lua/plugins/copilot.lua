return {
	{
		"github/copilot.vim",
		enabled = true,
		lazy = false,
		config = function()
			vim.g.copilot_start_on_startup = 1
		end,
	},
}
