local omarchy = require("utils.omarchy")

-- gruvbox is always installed as the fallback (macOS, or if the Omarchy
-- theme's plugin ever fails to resolve).
local spec = {
    { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = {} },
}

if omarchy.is_active() then
    local theme = omarchy.theme()
    if theme then
        vim.list_extend(spec, theme.plugins)
    end
end

return spec
