-- Reads the active Omarchy theme's Neovim colorscheme so this config can
-- follow whatever theme Omarchy is set to (`omarchy theme set ...`).
--
-- Omarchy publishes a LazyVim-style plugin spec at:
--   <theme_dir>/neovim.lua
-- e.g. return {
--   { "OldJobobo/retro-82.nvim", priority = 1000 },
--   { "LazyVim/LazyVim", opts = { colorscheme = "retro-82" } },
-- }
-- This config isn't LazyVim, so we pull the colorscheme plugin spec(s) and
-- the scheme name out ourselves rather than relying on the LazyVim entry.
--
-- Omarchy has moved where "current theme" state lives before (it used to be
-- under ~/.config/omarchy/current/, now it's under
-- ~/.local/state/omarchy/current/), so we probe a list of candidates rather
-- than hardcoding one path.

local M = {}

local CANDIDATE_THEME_DIRS = {
    "~/.local/state/omarchy/current/theme", -- current
    "~/.config/omarchy/current/theme", -- legacy
}

-- Memoized resolved theme dir. `false` means "resolved, and none found" so we
-- don't re-stat on every call once we know this isn't an Omarchy machine.
local resolved_theme_dir = nil

-- Returns the active theme directory, or nil if this isn't an Omarchy
-- machine (e.g. macOS) or no candidate path exists.
function M.theme_dir()
    if resolved_theme_dir == nil then
        resolved_theme_dir = false
        for _, candidate in ipairs(CANDIDATE_THEME_DIRS) do
            local path = vim.fn.expand(candidate)
            if vim.loop.fs_stat(path) ~= nil then
                resolved_theme_dir = path
                break
            end
        end
    end

    return resolved_theme_dir or nil
end

-- True only on Omarchy machines (macOS has no theme state dir at all).
function M.is_active()
    return M.theme_dir() ~= nil
end

-- Returns { plugins = <lazy spec list>, colorscheme = <string|nil> }, or nil
-- if the file is missing or doesn't look like the expected spec.
function M.theme()
    local theme_dir = M.theme_dir()
    if not theme_dir then
        return nil
    end

    local ok, spec = pcall(dofile, theme_dir .. "/neovim.lua")
    if not ok or type(spec) ~= "table" then
        return nil
    end

    local plugins = {}
    local colorscheme = nil

    for _, entry in ipairs(spec) do
        if type(entry) == "table" and entry[1] == "LazyVim/LazyVim" then
            colorscheme = type(entry.opts) == "table" and entry.opts.colorscheme or nil
        else
            table.insert(plugins, entry)
        end
    end

    return { plugins = plugins, colorscheme = colorscheme }
end

-- Parses <theme_dir>/colors.toml into a flat { key = "#hex", ... } table.
-- The file is a simple flat TOML doc (no tables/arrays), so a line-based
-- gmatch is enough and avoids pulling in a TOML parser.
function M.colors()
    local theme_dir = M.theme_dir()
    if not theme_dir then
        return nil
    end

    local path = theme_dir .. "/colors.toml"
    local fd = io.open(path, "r")
    if not fd then
        return nil
    end

    local colors = {}
    for line in fd:lines() do
        local key, value = line:match('^%s*([%w_]+)%s*=%s*"([^"]*)"%s*$')
        if key then
            colors[key] = value
        end
    end
    fd:close()

    return colors
end

return M
