return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "java" })
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = { "mfussenegger/nvim-jdtls" },
		opts = {
			setup = {
				jdtls = function(_, opts)
					vim.api.nvim_create_autocmd("FileType", {
						pattern = "java",
						callback = function()
							local config = {
								cmd = {
									"java", -- or '/path/to/java17_or_newer/bin/java'
									-- depends on if `java` is in your $PATH env variable and if it points to the right version.

									"-javaagent:~/.local/share/nvim/mason/packages/jdtls/lombok.jar",
									-- '-Xbootclasspath/a:/home/jake/.local/share/java/lombok.jar',
									"-Declipse.application=org.eclipse.jdt.ls.core.id1",
									"-Dosgi.bundles.defaultStartLevel=4",
									"-Declipse.product=org.eclipse.jdt.ls.core.product",
									"-Dlog.protocol=true",
									"-Dlog.level=ALL",
									-- '-noverify',
									"-Xms4g",
									"--add-modules=ALL-SYSTEM",
									"--add-opens",
									"java.base/java.util=ALL-UNNAMED",
									"--add-opens",
									"java.base/java.lang=ALL-UNNAMED",
									"-jar",
									vim.fn.glob(
										"~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"
									),
									-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
									-- Must point to the                                                     Change this to
									-- eclipse.jdt.ls installation                                           the actual version

									-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
									-- Must point to the                      Change to one of `linux`, `win` or `mac`
									-- eclipse.jdt.ls installation            Depending on your system.

									-- See `data directory configuration` section in the README
								},

								root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),

								settings = {
									java = {},
								},
							}
							require("jdtls").start_or_attach(config)
						end,
					})
					return true
				end,
			},
		},
	},
}
