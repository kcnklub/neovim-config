local M = {};

function M.setup()
    local whichkey = require("which-key");

    local conf = {
        window = {
            border = "single",
            position = "bottom"
        }
    }

    local opts = {
        prefix = "<leader>",
    }

    local mappings = {
        ["w"] = { "<cmd>update!<CR>", "Save" },
        ["q"] = { "<cmd>q!<CR>", "Quit" },

        b = {
            name = "Buffer",
            c = { "<Cmd>bd!<Cr>", "Close current buffer" },
            D = { "<Cmd>%bd|e#|bd#<Cr>", "Delete all buffers" },
        },

        f = {
            name = "Find",
            f = { "<cmd>lua require('utils.finder').find_files()<cr>", "Files" },
            b = { "<cmd>FzfLua buffers<cr>", "Buffers" },
            o = { "<cmd>FzfLua oldfiles<cr>", "Old files" },
            g = { "<cmd>FzfLua live_grep<cr>", "Live grep" },
            c = { "<cmd>FzfLua commands<cr>", "Commands" },
            e = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
        },

        z = {
            name = "Packer",
            c = { "<cmd>PackerCompile<cr>", "Compile" },
            i = { "<cmd>PackerInstall<cr>", "Install" },
            p = { "<cmd>PackerProfile<cr>", "Profile" },
            s = { "<cmd>PackerSync<cr>", "Sync" },
            S = { "<cmd>PackerStatus<cr>", "Status" },
            u = { "<cmd>PackerUpdate<cr>", "Update" },
        },

        g = {
            name = "Git",
            s = { "<cmd>Neogit<CR>", "Status" },
        }, 

        p = {
            name = "telescope",
            f = { "<cmd>lua require('utils.finder').find_git()<cr>", "Files" },
            b = { "<cmd>Telescope buffers<cr>", "Buffers" },
            o = { "<cmd>Telescope oldfiles<cr>", "Old Files" },
            g = { "<cmd>lua require('utils.finder').find_grep()<cr>", "Live Grep" },
            c = { "<cmd>Telescope commands<cr>", "Commands" },
            r = { "<cmd>Telescope file_browser<cr>", "Browser" },
            w = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Current Buffer" },
            e = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
        }
    }



    whichkey.setup(conf);
    whichkey.register(mappings, opts);
end

return M;
