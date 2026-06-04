local icons = require("config.icons")

local function fg(name)
    return function()
        local hl = vim.api.nvim_get_hl(0, {})
        return hl and hl.foreground and { fg = string.format("#%06x", hl.foreground) }
    end
end

local git_root_cache = {}

local function current_file_path()
    if vim.bo.buftype ~= "" then
        return nil
    end

    local name = vim.api.nvim_buf_get_name(0)
    if name == "" or name:match("^[%w+.-]+://") then
        return nil
    end

    return vim.fs.normalize(name)
end

local function current_git_root()
    local path = current_file_path()
    if not path then
        return nil
    end

    local dir = vim.fn.isdirectory(path) == 1 and path or vim.fn.fnamemodify(path, ":p:h")
    if dir == "" or vim.fn.isdirectory(dir) ~= 1 then
        return nil
    end

    local cached = git_root_cache[dir]
    if cached ~= nil then
        return cached or nil
    end

    local git_dir = vim.fs.find(".git", { path = dir, upward = true })[1]
    if not git_dir then
        git_root_cache[dir] = false
        return nil
    end

    local root = vim.fs.dirname(git_dir)
    git_root_cache[dir] = root
    return root
end

return {
    spaces = {
        function()
            local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")
            return icons.ui.Tab .. " " .. shiftwidth
        end,
        padding = 1,
    },
    git_repo = {
        function()
            local root = current_git_root()
            return root and vim.fn.fnamemodify(root, ":t") or ""
        end,
        cond = current_git_root,
    },
    separator = {
        function()
            return "%="
        end,
    },
    diff = {
        "diff",
        colored = false,
        cond = current_git_root,
    },
    diagnostics = {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        diagnostics_color = {
            error = "DiagnosticError",
            warn = "DiagnosticWarn",
            info = "DiagnosticInfo",
            hint = "DiagnosticHint",
        },
        colored = true,
    },
    lsp_client = {
        function(msg)
            msg = msg or ""
            local buf_clients = vim.lsp.get_clients({ bufnr = 0 })

            if next(buf_clients) == nil then
                if type(msg) == "boolean" or #msg == 0 then
                    return ""
                end
                return msg
            end

            local buf_ft = vim.bo.filetype
            local buf_client_names = {}

            -- add client
            for _, client in pairs(buf_clients) do
                if client.name ~= "null-ls" then
                    table.insert(buf_client_names, client.name)
                end
            end

            -- add formatter
            local lsp_utils = require("plugins.lsp.utils")
            local formatters = lsp_utils.list_formatters(buf_ft)
            vim.list_extend(buf_client_names, formatters)

            -- add linter
            local linters = lsp_utils.list_linters(buf_ft)
            vim.list_extend(buf_client_names, linters)

            -- add hover
            local hovers = lsp_utils.list_hovers(buf_ft)
            vim.list_extend(buf_client_names, hovers)

            -- add code action
            local code_actions = lsp_utils.list_code_actions(buf_ft)
            vim.list_extend(buf_client_names, code_actions)

            local hash = {}
            local client_names = {}
            for _, v in ipairs(buf_client_names) do
                if not hash[v] then
                    client_names[#client_names + 1] = v
                    hash[v] = true
                end
            end
            table.sort(client_names)
            return icons.ui.Code .. " " .. table.concat(client_names, ", ") .. " " .. icons.ui.Code
        end,
        -- icon = icons.ui.Code,
        colored = true,
        on_click = function()
            vim.cmd([[LspInfo]])
        end,
    },
    noice_mode = {
        function()
            return require("noice").api.status.mode.get()
        end,
        cond = function()
            return package.loaded["noice"] and require("noice").api.status.mode.has()
        end,
        color = fg("Constant"),
    },
    noice_command = {
        function()
            return require("noice").api.status.command.get()
        end,
        cond = function()
            return package.loaded["noice"] and require("noice").api.status.command.has()
        end,
        color = fg("Statement"),
    },
}
