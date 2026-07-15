-- Make split boundaries easier to spot. Themes are swapped in from Omarchy
-- (or gruvbox as a transparent fallback, see after/plugin/colors.lua), so this
-- must never hardcode a color: it derives an accent from whatever colorscheme
-- is active and only sets a foreground (WinSeparator has no background here),
-- which keeps it working under a transparent Normal too.

-- Priority list of groups that almost every colorscheme defines with a
-- meaningful `fg`, roughly ordered from "most accent-like" to "safe fallback".
local ACCENT_GROUPS = { "Function", "Special", "Type", "Identifier", "Statement", "Constant", "Directory" }

local function hl_fg(name)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl and hl.fg then
        return hl.fg
    end
    return nil
end

local function to_rgb(color)
    return { r = math.floor(color / 65536) % 256, g = math.floor(color / 256) % 256, b = color % 256 }
end

local function to_hex(rgb)
    return string.format("#%02x%02x%02x", rgb.r, rgb.g, rgb.b)
end

-- Blend `color` toward `target` by `factor` (0 = color, 1 = target). Used to
-- pull a bright accent down to something subtle rather than screaming.
local function blend(color, target, factor)
    local c, t = to_rgb(color), to_rgb(target)
    return to_hex({
        r = math.floor(c.r + (t.r - c.r) * factor),
        g = math.floor(c.g + (t.g - c.g) * factor),
        b = math.floor(c.b + (t.b - c.b) * factor),
    })
end

local function darken(color, factor)
    local c = to_rgb(color)
    return to_hex({
        r = math.floor(c.r * factor),
        g = math.floor(c.g * factor),
        b = math.floor(c.b * factor),
    })
end

local function accent_color()
    for _, group in ipairs(ACCENT_GROUPS) do
        local fg = hl_fg(group)
        if fg then
            return fg
        end
    end
    return hl_fg("Comment") or 0x808080
end

local function set_separator()
    local accent = accent_color()

    local ok, normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal", link = false })
    local normal_bg = ok and normal and normal.bg

    local color
    if normal_bg then
        -- Solid background available: blend toward it for a subtle, on-theme tint.
        color = blend(accent, normal_bg, 0.35)
    else
        -- Transparent background: no bg to blend toward, so just darken the accent.
        color = darken(accent, 0.6)
    end

    vim.api.nvim_set_hl(0, "WinSeparator", { fg = color, bg = "NONE" })
end

vim.opt.fillchars:append({
    vert = "│",
    horiz = "─",
    horizup = "┴",
    horizdown = "┬",
    vertleft = "┤",
    vertright = "├",
    verthoriz = "┼",
})

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("window_separator", { clear = true }),
    callback = set_separator,
})

set_separator()
