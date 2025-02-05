return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
            "nvim-telescope/telescope-file-browser.nvim",
            "nvim-telescope/telescope-project.nvim",
            "cljoly/telescope-repo.nvim",
            "stevearc/aerial.nvim",
            "kkharji/sqlite.lua",
            "aaronhallaert/advanced-git-search.nvim",
            "benfowler/telescope-luasnip.nvim",
        },
        cmd = "Telescope",
        keys = {
            { "<leader><space>", require("utils").find_files, desc = "Find files" },
            { "<leader>ff", require("utils").find_files, desc = "Find GIT files" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
            { "<leader>sw", "<cmd>Telescope live_grep<cr>", desc = "Workspace" },
            { "<leader>ss", "<cmd>Telescope luasnip<cr>", desc = "Snippets" },
            {
                "<leader>sb",
                function()
                    require("telescope.builtin").current_buffer_fuzzy_find()
                end,
                desc = "Buffer",
            },
            { "<leader>vo", "<cmd>Telescope aerial<cr>", desc = "Code Outline" },
        },
        config = function(_, _)
            local telescope = require("telescope")
            local icons = require("config.icons")
            local actions = require("telescope.actions")
            local actions_layout = require("telescope.actions.layout")

            local mappings = {
                i = {
                    ["<C-j>"] = actions.move_selection_next,
                    ["<C-k>"] = actions.move_selection_previous,
                    ["<C-n>"] = actions.cycle_history_next,
                    ["<C-p>"] = actions.cycle_history_prev,
                    ["?"] = actions_layout.toggle_preview,
                },
            }

            local opts = {
                defaults = {
                    prompt_prefix = icons.ui.Telescope .. " ",
                    selection_caret = icons.ui.Forward .. " ",
                    mappings = mappings,
                    border = {},
                    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                    color_devicons = true,
                },
                pickers = {
                    find_files = {
                        previewer = false,
                        find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
                    },
                    git_files = {},
                    buffers = {},
                },
                extensions = {
                    file_browser = {
                        hijack_netrw = true,
                        mappings = mappings,
                    },
                    project = {},
                },
            }

            telescope.setup(opts)
            telescope.load_extension("fzf")
            telescope.load_extension("file_browser")
            telescope.load_extension("project")
            telescope.load_extension("aerial")
            telescope.load_extension("luasnip")
        end,
    },
    {
        "stevearc/aerial.nvim",
        config = true,
    },
}
