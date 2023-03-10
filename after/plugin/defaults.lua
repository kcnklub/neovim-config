local api = vim.api
local g = vim.g
local opt = vim.opt

api.nvim_set_keymap("", "<Space>", "Nop", { noremap = true, silent })
g.mapleader = " "
g.mapleaderlocal = " "

opt.termguicolors = true;
opt.hlsearch = true;
opt.number = true; 
opt.relativenumber = true;
opt.undofile = true;
opt.ignorecase = true;
opt.updatetime = 250; 
opt.clipboard = "unnamedplus"

-- highlight on yank; 
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]
