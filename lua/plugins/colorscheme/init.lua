local omarchy = require("utils.omarchy")

-- everforest is always installed as the fallback (macOS, or if the Omarchy
-- theme's plugin ever fails to resolve).
--
-- aether.nvim is pinned unconditionally too: nearly every stock Omarchy
-- theme resolves to it (only the per-theme `opts.colors` palette differs),
-- so pinning it means the plugin is already on disk before the first
-- `:Lazy sync`, and a theme switch takes effect on the very next launch
-- instead of after an install round-trip. lazy.nvim merges specs by plugin
-- name, so this pin and the dynamically-appended spec from
-- `omarchy.theme().plugins` (which supplies the actual `opts`) combine
-- rather than conflict.
local spec = {
    { "neanias/everforest-nvim", priority = 1000 },
    { "bjarneo/aether.nvim", branch = "v3", name = "aether", priority = 1000 },
}

if omarchy.is_active() then
    local theme = omarchy.theme()
    if theme then
        vim.list_extend(spec, theme.plugins)
    end
end

return spec
