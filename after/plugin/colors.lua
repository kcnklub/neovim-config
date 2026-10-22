-- Follow the active Omarchy theme's colorscheme when on Omarchy; otherwise
-- (e.g. macOS) fall back to everforest dark. See lua/utils/omarchy.lua.
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
    require("everforest").setup({
        background = "medium",
        transparent_background_level = 1,
    })
    vim.o.background = "dark"
    -- 0.9 opacity: floats/popups blend 10%; Neovide gets a real window alpha.
    vim.o.winblend = 10
    vim.o.pumblend = 10
    vim.g.neovide_opacity = 0.9
    vim.cmd("colorscheme everforest")
end
