local omarchy = require("utils.omarchy")

-- everforest is always installed as the fallback (macOS, or if the Omarchy
-- theme's plugin ever fails to resolve).
local spec = {
    { "neanias/everforest-nvim", priority = 1000 },
}

if omarchy.is_active() then
    local theme = omarchy.theme()
    if theme then
        vim.list_extend(spec, theme.plugins)
    end
end

return spec
