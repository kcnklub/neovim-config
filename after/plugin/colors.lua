-- Follow the active Omarchy theme's colorscheme when on Omarchy; otherwise
-- (e.g. macOS) fall back to gruvbox. See lua/utils/omarchy.lua.
local omarchy = require("utils.omarchy")

local function apply_omarchy()
    if not omarchy.is_active() then
        return false
    end
    local theme = omarchy.theme()
    if not (theme and theme.colorscheme) then
        return false
    end
    return pcall(vim.cmd.colorscheme, theme.colorscheme)
end

if not apply_omarchy() then
    require("gruvbox").setup({
        transparent_mode = true,
    })
    vim.o.background = "dark"
    vim.cmd("colorscheme gruvbox")
end
