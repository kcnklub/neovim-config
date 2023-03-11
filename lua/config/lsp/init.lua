local M = {}

local servers = {
  gopls = {},
  html = {},
  jsonls = {},
  pyright = {},
  rust_analyzer = {},
  tsserver = {},
  vimls = {},
}

local function on_attach(client, bufnr)
 
    local caps = client.server_capabilities; 

    if caps.completionProvider then
        vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end

    if caps.documentFormattingProvider then
        vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
    end

    -- Configure key mappings
    require("config.lsp.keymaps").setup(client, bufnr)

    if caps.definitionProvider then
        vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    end
end
    
local opts = {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
}

function M.setup()
  require("config.lsp.installer").setup(servers, opts)
end

return M
