local M = {}

local packer_bootstrap = false; 

local function packer_init()
    local fn = vim.fn;
    local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then 
        packer_bootstrap = fn.system {
            "git", 
            "clone", 
            "--depth", 
            "1", 
            "https://github.com/wbthomason/packer.nvim", 
            install_path, 
        }
        vim.cmd [[packadd packer.nvim]]
    end
    vim.cmd "autocmd BufWritePost plugins.lua source <afile> | PackerCompile"
end

packer_init();

function M.setup()
    local conf = {
        compile_path = vim.fn.stdpath "config" .. "/lua/packer_compiled.lua", 
        display = {
            open_fn = function()
                return require("packer.util").float { border = "rounded" }
            end
        }
    }

    local function plugins(use)
        use { "lewis6991/impatient.nvim" }
        use { "wbthomason/packer.nvim" } 
        
        -- telescope
        use { "nvim-lua/plenary.nvim" } 
        use { "nvim-lua/popup.nvim" }
        use {
            'nvim-telescope/telescope.nvim', 
            module = "telescope",
            as = "telescope",
            requires = { 
                "nvim-telescope/telescope-media-files.nvim",
            }, 
            config = function()
                require("config.telescope").setup();
            end,
        }
        use {
            'rose-pine/neovim'
        }

        use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})

        use('theprimeagen/harpoon')
        use('mbbill/undotree')
        use('tpope/vim-fugitive')
        use {
            'VonHeikemen/lsp-zero.nvim',
            branch = 'v1.x',
            requires = {
                -- LSP Support
                {'neovim/nvim-lspconfig'},             -- Required
                {'williamboman/mason.nvim'},           -- Optional
                {'williamboman/mason-lspconfig.nvim'}, -- Optional

                -- Autocompletion
                {'hrsh7th/nvim-cmp'},         -- Required
                {'hrsh7th/cmp-nvim-lsp'},     -- Required
                {'hrsh7th/cmp-buffer'},       -- Optional
                {'hrsh7th/cmp-path'},         -- Optional
                {'saadparwaiz1/cmp_luasnip'}, -- Optional
                {'hrsh7th/cmp-nvim-lua'},     -- Optional

                -- Snippets
                {'L3MON4D3/LuaSnip'},             -- Required
                {'rafamadriz/friendly-snippets'}, -- Optional
            }
        }

        use({
            "Pocco81/auto-save.nvim",
            config = function()
                require("auto-save").setup {
                    -- your config goes here
                    -- or just leave it empty :)
                }
            end,
        })

        use("christoomey/vim-tmux-navigator")


        use {
            'nvim-tree/nvim-tree.lua',
            requires = {
                'nvim-tree/nvim-web-devicons', -- optional, for file icons
            },
            tag = 'nightly' -- optional, updated every week. (see issue #1193)
        }

        use("szw/vim-maximizer")

        use { "mfussenegger/nvim-jdtls", ft = { "java" } }
    end
    print("running plugin setup");
    pcall(require, "impatient");
    pcall(require, "packer_compiled");
    require("packer").init(conf);
    require("packer").startup(plugins);
end

return M
