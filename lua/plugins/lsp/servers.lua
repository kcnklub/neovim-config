local M = {}

local lsp_utils = require("plugins.lsp.utils")
local icons = require("config.icons")

local function lsp_init()
    local signs = {
        { name = "DiagnosticSignError", text = icons.diagnostics.Error },
        { name = "DiagnosticSignWarn",  text = icons.diagnostics.Warning },
        { name = "DiagnosticSignHint",  text = icons.diagnostics.Hint },
        { name = "DiagnosticSignInfo",  text = icons.diagnostics.Info },
    }
    for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
    end

    local config = {
        float = {
            focusable = true,
            style = "minimal",
            border = "rounded",
        },

        diagnostics = {
            virtual_text = {
                severity = {
                    min = vim.diagnostic.severity.ERROR,
                },
            },
            signs = {
                active = signs,
            },
            underline = false,
            update_in_insert = true,
            severity_sort = true,
            float = {
                focusable = true,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        },
    }

    vim.diagnostic.config(config.diagnostic)

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.buf.hover(config.float)
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.buf.signature_help(config.float)
end

function M.setup(_, opts)
    lsp_utils.on_attach(function(client, buffer)
        require("plugins.lsp.format").on_attach(client, buffer)
        require("plugins.lsp.keymaps").on_attach(client, buffer)
    end)

    lsp_init()

    local servers = opts.servers
    require("mason-lspconfig").setup({ ensure_installed = vim.tbl_keys(servers) })
end

return M
