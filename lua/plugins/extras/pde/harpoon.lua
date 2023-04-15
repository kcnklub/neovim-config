return {
	{
		"ThePrimeagen/harpoon",
		keys = {
			{
				"<leader>hl",
				function()
					require("harpoon.ui").toggle_quick_menu()
				end,
				desc = "harpoon menu",
			},
			{
				"<leader>hh",
				function()
					require("harpoon.mark").add_file()
				end,
				desc = "harpoon add file",
			},
			{
				"<leader>1",
				function()
					require("harpoon.ui").nav_file(1)
				end,
			},
			{
				"<leader>2",
				function()
					require("harpoon.ui").nav_file(2)
				end,
			},
		},
		opts = {
			global_settings = {
				save_on_toggle = true,
				enter_on_sendcmd = true,
			},
		},
	},
}
