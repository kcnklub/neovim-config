local M = {}; 

function M.setup()
    require("nvim-tree").setup {
        disable_netrw = true, 
        hijack_netrw = true, 

        view = {
            number = true, 
            relativenumber = true,
        }, 

        filter = {
           custom = { ".git" } 
        }
    }
end

return M;
