-- Reads the active Omarchy theme's Neovim colorscheme so this config can
-- follow whatever theme Omarchy is set to (`omarchy theme set ...`).
--
-- Omarchy publishes a LazyVim-style plugin spec at:
--   ~/.config/omarchy/current/theme/neovim.lua
-- e.g. return {
--   { "OldJobobo/retro-82.nvim", priority = 1000 },
--   { "LazyVim/LazyVim", opts = { colorscheme = "retro-82" } },
-- }
-- This config isn't LazyVim, so we pull the colorscheme plugin spec(s) and
-- the scheme name out ourselves rather than relying on the LazyVim entry.

local M = {}

local neovim_spec_path = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")

-- True only on Omarchy machines (macOS has no ~/.config/omarchy at all).
function M.is_active()
    return vim.loop.fs_stat(neovim_spec_path) ~= nil
end

-- Returns { plugins = <lazy spec list>, colorscheme = <string|nil> }, or nil
-- if the file is missing or doesn't look like the expected spec.
function M.theme()
    local ok, spec = pcall(dofile, neovim_spec_path)
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

return M
