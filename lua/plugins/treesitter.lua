local swap_objects = {
    p = "@parameter.inner",
    f = "@function.outer",
    c = "@class.outer",
}

return {
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = false,
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true },
                move = { set_jumps = true },
            })

            local select = require("nvim-treesitter-textobjects.select")
            for key, obj in pairs({
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            }) do
                vim.keymap.set({ "x", "o" }, key, function()
                    select.select_textobject(obj, "textobjects")
                end, { desc = "Select " .. obj })
            end

            local move = require("nvim-treesitter-textobjects.move")
            for fn, maps in pairs({
                goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
                goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
                goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
                goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
            }) do
                for key, obj in pairs(maps) do
                    vim.keymap.set({ "n", "x", "o" }, key, function()
                        move[fn](obj, "textobjects")
                    end, { desc = fn .. " " .. obj })
                end
            end

            local swap = require("nvim-treesitter-textobjects.swap")
            for key, obj in pairs(swap_objects) do
                vim.keymap.set("n", "<leader>cx" .. key, function()
                    swap.swap_next(obj)
                end, { desc = "Swap next " .. obj })
                vim.keymap.set("n", "<leader>cX" .. key, function()
                    swap.swap_previous(obj)
                end, { desc = "Swap previous " .. obj })
            end
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        -- main does not support lazy-loading
        lazy = false,
        dependencies = {
            "RRethy/nvim-treesitter-endwise",
            "windwp/nvim-ts-autotag",
        },
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "bash",
                "dockerfile",
                "html",
                "lua",
                "markdown",
                "yaml",
                "java",
                "javascript",
                "typescript",
            },
            -- keep vim regex syntax on alongside treesitter for these filetypes
            additional_vim_regex_highlighting = { "org", "markdown" },
            indent_disable = { "python" },
        },
        config = function(_, opts)
            local ts = require("nvim-treesitter")
            ts.setup()
            ts.install(opts.ensure_installed)

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
                callback = function(args)
                    if not pcall(vim.treesitter.start, args.buf) then
                        return
                    end
                    local ft = vim.bo[args.buf].filetype
                    if vim.tbl_contains(opts.additional_vim_regex_highlighting, ft) then
                        vim.bo[args.buf].syntax = "on"
                    end
                    if not vim.tbl_contains(opts.indent_disable, ft) then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })

            require("nvim-ts-autotag").setup()
        end,
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            npairs.setup({
                check_ts = true,
            })
        end,
    },
}
