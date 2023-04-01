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
				key_labels = { ["<leader>"] = "SPC" },
				triggers = "auto",
				window = {
					border = "single",
					position = "bottom",
					margin = { 1, 0, 1, 0 },
					padding = { 1, 1, 1, 1 },
					winblend = 0,
				},
				layout = {
					height = { min = 4, max = 25 },
					width = { min = 20, max = 50 },
					spacing = 3,
					align = "left",
				},
			})

			wk.register({
				w = { "<cmd>update!<CR>", "Save" },
				q = {
					name = "Quit",
					q = {
						function()
							require("utils").quit()
						end,
						"Quit",
					},
					t = { "<cmd>tabclose<cr>", "Close tab" },
				},
				b = { name = "+Buffer" },
				d = { name = "+Debug" },
				f = { name = "+File" },
				h = { name = "+Help" },
				j = { name = "+Jump" },
				g = { name = "+Git", h = { name = "Hunk" }, t = { name = "Toggle" } },
				n = { name = "+Notes" },
				p = { name = "+Project" },

				t = { name = "+Test", N = { name = "Neotest" }, o = { "Overseer" } },
				v = { name = "+View" },
				z = { name = "+System" },

				s = {
					name = "+Search",
					c = {
						function()
							require("utils.coding").cht()
						end,
						"Cheatsheets",
					},
					o = {
						function()
							require("utils.coding").stack_overflow()
						end,
						"Stack Overflow",
					},
				},
				c = {
					name = "+Code",
					g = { name = "Annotation" },
					x = {
						name = "Swap Next",
						f = "Function",
						p = "Parameter",
						c = "Class",
					},
					X = {
						name = "Swap Previous",
						f = "Function",
						p = "Parameter",
						c = "Class",
					},
				},
			}, { prefix = "<leader>", mode = { "n", "v" } })
		end,
	},
}
