return {
	"nvim-lua/plenary.nvim",
	"MunifTanjim/nui.nvim",
	{
		"nvim-tree/nvim-web-devicons",
		dependencies = { "DaikyXendo/nvim-material-icon" },
		config = function()
			require("nvim-web-devicons").setup({
				override = require("nvim-material-icon").get_icons(),
			})
		end,
	},
	{ "yamatsum/nvim-nonicons", config = true, enabled = false },
	{ "tpope/vim-repeat", event = "VeryLazy" },
	{ "nacro90/numb.nvim", event = "BufReadPre", config = true },
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			char = "|",
			filetype_exclude = { "help", "alpha", "dashboard", "NvimTree", "Trouble", "lazy" },
			show_trailing_blankline_indent = false,
			show_current_context = false,
		},
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
}
