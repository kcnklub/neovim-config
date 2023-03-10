-- Plugins
local function plugins(use)
	use { "wbthomason/packer.nvim" }

	-- Colorscheme
	use {
		"sainnhe/everforest",
		config = function()
			vim.cmd "colorscheme everforest"
		end,
	}

	use {
		"goolord/alpha-nvim", 
		config = function()
			local status_ok, alpha = pcall(require, "alpha");
			if not status_ok then
				print("alpha not found");
				return; 
			end

			local theme_ok, theme = pcall(require, "alpha.themes.dashboard"); 
			if not theme_ok then
				print("theme not found"); 
				return; 
			end

			alpha.setup(theme.config);
		end
	}

	-- Git
	use {
		"TimUntersberger/neogit",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("config.neogit").setup()
		end,
	}
end

local packer_ok, packer = pcall(require, "packer");
if not packer_ok then
	print("Packer not found"); 
	return; 
end

packer.init();
packer.startup(plugins);
