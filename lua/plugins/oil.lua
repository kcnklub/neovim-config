return {
	"stevearc/oil.nvim",
	lazy = false, -- must load at startup to take over `nvim <dir>` / :e <dir>
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
		{ "<leader>fe", "<cmd>Oil<cr>", desc = "Explorer" },
	},
	opts = {
		default_file_explorer = true,
		delete_to_trash = true,
		skip_confirm_for_simple_edits = true,
		watch_for_changes = true,
		view_options = {
			show_hidden = true,
			is_always_hidden = function(name)
				return name == ".git"
			end,
		},
		win_options = {
			number = true,
			relativenumber = true,
		},
		keymaps = {
			["q"] = { "actions.close", mode = "n" },
			["<C-h>"] = false,
			["<C-l>"] = false,
			["gr"] = "actions.refresh",
		},
	},
}
