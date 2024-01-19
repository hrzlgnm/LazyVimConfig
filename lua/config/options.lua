-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
opt.autoindent = true
opt.cindent = true
opt.wrap = true
opt.relativenumber = true
opt.number = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.breakindent = true
opt.showbreak = "   "
opt.linebreak = true

opt.foldmethod = "marker"
opt.foldlevel = 0
opt.modelines = 1
opt.belloff = "all"

opt.joinspaces = true

opt.fillchars = { eob = "~" }
-- Ignore compiled files
opt.wildignore = "__pycache__"
opt.wildignore:append({ "*.o", "*~", "*.pyc", "*pycache*" })

-- Floating window popup for completion on command line
opt.pumblend = 17
opt.wildmode = "longest:full"
opt.wildoptions = "pum"

opt.incsearch = true
opt.showmatch = true
opt.ignorecase = true
opt.smartcase = true
opt.hidden = true
opt.equalalways = true
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 1000
opt.scrolloff = 10

local g = vim.g
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.python3_host_prog = "/usr/bin/python3"
