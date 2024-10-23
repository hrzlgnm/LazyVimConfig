-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- @todo: redo this per file type like done by tj devries in https://github.com/tjdevries/config.nvim/tree/master/after/ftplugin
local opt = vim.opt

-- keep line ends as they are
opt.fileformats = "unix,dos,mac"

-- stolen from https://github.com/tjdevries/config.nvim/blob/master/plugin/options.lua
opt.inccommand = "split"

opt.smartcase = true
opt.ignorecase = false

-- personal perference
opt.relativenumber = true
opt.number = true

opt.splitbelow = true
opt.splitright = true

opt.signcolumn = "yes"
opt.shada = { "'10", "<0", "s10", "h" }

opt.clipboard = "unnamedplus"

-- Don't have `o` add a comment
opt.formatoptions:remove("o")

opt.wrap = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.breakindent = true
opt.showbreak = "> "
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

opt.updatetime = 1000
opt.scrolloff = 10

-- Make some some providers shut up
local g = vim.g
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.python3_host_prog = "/usr/bin/python3"
g.maplocalleader = ","
