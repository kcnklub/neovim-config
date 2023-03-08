local M = {}

function M.setup()
    require("telescope").load_extension "media_files"
    print("Telescope setup finished");
end

return M
