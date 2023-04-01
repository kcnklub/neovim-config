return {
	{
		"xiyaowong/nvim-transparent",
		cmd = { "TransparentEnable", "TransparentDisable", "TransparentToggle" },
		opts = {},
		config = function(_, opts)
			require("transparent").setup(opts)
		end,
	},
}
