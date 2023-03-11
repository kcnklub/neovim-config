-- Plugins
local function plugins(use)
	use { "wbthomason/packer.nvim" }

	-- Colorscheme
	use {
		"folke/tokyonight.nvim",
		config = function()
			vim.cmd "colorscheme tokyonight-night"
		end,
	}

	-- Git
	use {
		"TimUntersberger/neogit",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("config.neogit").setup()
		end,
	}

    -- whichkey
    use {
        "folke/which-key.nvim", 
        event = "VimEnter", 
        config = function()
            require("config.whichkey").setup();
        end,
    }

    -- Better icons;
    use {
        "kyazdani42/nvim-web-devicons", 
        module = "nvim-web-devicons", 
        config = function()
            require("nvim-web-devicons").setup { default = true }
        end,
    }

    -- Lua line
    use {
        "nvim-lualine/lualine.nvim",
        event = "VimEnter", 
        config = function()
            require("config.lualine").setup();
        end, 
        requires = { "nvim-web-devicons" }
    }

    use {
        "SmiteshP/nvim-gps", 
        require = "nvim-treesitter/nvim-treesitter", 
        module = "nvim-gps", 
        config = function()
            require("nvim-gps").setup();
        end,
    }

    -- tree sitter
    use {
        "nvim-treesitter/nvim-treesitter", 
        run = ":TSUpdate", 
        config = function()
            require("config.treesitter").setup(); 
        end 
    }

    use {
        "kyazdani42/nvim-tree.lua", 
        requires = {
            "nvim-web-devicons", 
        }, 
        cmd = {
            "NvimTreeToggle", "NvimTreeClose"
        }, 
        config = function()
            require("config.nvimtree").setup();
        end
    }

    -- completion w/out LSP
    use {
        "ms-jpq/coq_nvim", 
        branch = "coq", 
        event = "InsertEnter", 
        opt = true, 
        run = ":COQdeps", 
        config = function()
            require("config.coq").setup()
        end, 
        requires = {
            { "ms-jpq/coq.artifacts", branch = "artifacts" }, 
            { "ms-jpq/coq.thirdparty", branch = "3p", module = "coq_3p" },
        }, 
        disable = false,
    }

    use { 
        "hrsh7th/nvim-cmp", 
        event = "InsertEnter", 
        opt = true, 
        config = function()
            require("config.cmp").setup()
        end,
        wants  = { "LuaSnip" }, 
        requires = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lua",
            "ray-x/cmp-treesitter",
            "hrsh7th/cmp-cmdline",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-calc",
            "f3fora/cmp-spell",
            "hrsh7th/cmp-emoji",
            {
                "L3MON4D3/LuaSnip",
                wants = "friendly-snippets",
                config = function()
                    require("config.luasnip").setup()
                end,
            },
            "rafamadriz/friendly-snippets",
            disable = false,
        }
    }

    -- auto pairing {}<>
    use {
        "windwp/nvim-autopairs", 
        wants = "nvim-treesitter", 
        module = { "nvim-autopairs.completion.cmp", "nvim-autopairs" }, 
        config = function()
            require("config.autopairs").setup()
        end,
    }

    use {
        "windwp/nvim-ts-autotag", 
        wants = "nvim-treesitter", 
        event = "InsertEnter", 
        config = function()
            require("nvim-ts-autotag").setup {enable = true}
        end,
    }

    use {
        "RRethy/nvim-treesitter-endwise", 
        wants = "nvim-treesitter", 
        event = "InsertEnter"
    }

    use {
        "neovim/nvim-lspconfig",
        config = function()
            require("config.lsp").setup()
        end,
        requires = {
            "williamboman/mason.nvim", 
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            { "jayp0521/mason-null-ls.nvim" },
            "folke/neodev.nvim",
            "RRethy/vim-illuminate",
            "jose-elias-alvarez/null-ls.nvim",
            {
                "j-hui/fidget.nvim",
                config = function()
                    require("fidget").setup {}
                end,
            },
            { "b0o/schemastore.nvim", module = { "schemastore" } },
            { "jose-elias-alvarez/typescript.nvim", module = { "typescript" } },
            {
                "SmiteshP/nvim-navic",
                -- "alpha2phi/nvim-navic",
                config = function()
                    require("nvim-navic").setup {}
                end,
                module = { "nvim-navic" },
            },
            {
                "simrat39/inlay-hints.nvim",
                config = function()
                    require("inlay-hints").setup()
                end,
            },
            {
                "zbirenbaum/neodim",
                event = "LspAttach",
                config = function()
                    require("config.neodim").setup()
                end,
                disable = true,
            },
            {
                "theHamsta/nvim-semantic-tokens",
                config = function()
                    require("config.semantictokens").setup()
                end,
                disable = true,
            },
            {
                "David-Kunz/markid",
                disable = true,
            },
            {
                "simrat39/symbols-outline.nvim",
                cmd = { "SymbolsOutline" },
                config = function()
                    require("symbols-outline").setup()
                end,
                disable = true,
            },
        },
    }

    -- Rust
    use {
        "simrat39/rust-tools.nvim",
        requires = { "nvim-lua/plenary.nvim", "rust-lang/rust.vim" },
        opt = true,
        module = "rust-tools",
        ft = { "rust" },
    }
    use {
        "saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        requires = { { "nvim-lua/plenary.nvim" } },
        config = function()
            require("crates").setup {
                null_ls = {
                    enabled = false,
                    name = "crates.nvim",
                },
            }
        end,
        disable = false,
    } 
end

local packer_ok, packer = pcall(require, "packer");
if not packer_ok then
	print("Packer not found");
	return;
end

packer.init();
packer.startup(plugins);
