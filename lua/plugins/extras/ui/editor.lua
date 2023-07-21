return {
	{
		"xiyaowong/nvim-transparent",
		cmd = { "TransparentEnable", "TransparentDisable", "TransparentToggle" },
		opts = {},
		config = function(_, opts)
			require("transparent").setup(opts)
		end,
	},

	-- Better `vim.notify`
	{
		"rcarriga/nvim-notify",
		keys = {
			{
				"<leader>un",
				function()
					require("notify").dismiss({ silent = true, pending = true })
				end,
				desc = "Dismiss all Notificaions",
			},
		},
		opts = {
			timeout = 3000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
		},
		init = function()
			require("notify").setup({
				background_colour = "#000000",
			})
			vim.notify = require("notify")
		end,
	},
}
