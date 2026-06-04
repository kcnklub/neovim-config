return {
	{
		"RRethy/vim-illuminate",
		event = "BufReadPost",
		opts = {
            delay = 200,
            providers = {"lsp", "regex"}
        },
		config = function(_, opts)
			require("illuminate").configure(opts)
		end,
	},
}
