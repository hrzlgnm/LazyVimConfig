-- much stuff stolen from:
-- * https://github.com/tjdevries/config.nvim/blob/master/plugin/options.lua
-- * https://github.com/radleylewis/nvim-lite/blob/master/init.lua

local set = vim.opt

set.fileformats = "unix,dos,mac" -- keep line ends as they are
set.inccommand = "split" -- show live substitutions in a split window

-- Basic settings
set.cursorline = true -- Highlight current line
set.wrap = true -- Wrap lines
set.scrolloff = 10 -- Keep 10 lines above/below cursor
set.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Indentation
set.tabstop = 4 -- Tab width
set.shiftwidth = 4 -- Indent width
set.softtabstop = 4 -- Soft tab stop
set.expandtab = true -- Use spaces instead of tabs
set.smartindent = true -- Smart auto-indenting
set.autoindent = true -- Copy indent from current line
set.breakindent = true -- Indent wrapped lines

-- Search settings
set.hlsearch = false -- Don't highlight search results
set.incsearch = true -- Show search results as you type

-- Visual settings
set.colorcolumn = "100" -- Show column at 100 characters
set.showmatch = true -- Highlight matching brackets
set.matchtime = 2 -- How long to show matching bracket

-- File handling
set.updatetime = 300 -- Faster completion
set.timeoutlen = 500 -- Key timeout duration
set.ttimeoutlen = 0 -- Key code timeout
set.autowrite = false -- Don't auto save

-- Behavior settings
set.autochdir = false -- Don't auto change directory
set.iskeyword:append("-") -- Treat dash as part of word
set.formatoptions:remove("o") -- Don't have `o` add a comment
set.shada = { "'10", "<0", "s10", "h" }

-- Folding settings
set.foldenable = false

set.showbreak = "> "
set.linebreak = true

set.foldmethod = "marker" -- Use {{{ }}} markers for folding
set.foldlevel = 0
set.modelines = 1

set.joinspaces = true

-- Floating window popup for completion on command line
set.pumblend = 17
set.wildmode = "longest:full"
set.wildoptions = "pum"

-- Make some some providers shut up
local g = vim.g
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.python3_host_prog = "/usr/bin/python3"

-- Map localleader to ,
g.maplocalleader = ","

-- enable codebook lsp
vim.lsp.enable("codebook")

-- Filetype detection for files nvim does not recognize on its own
vim.filetype.add({
  extension = {
    jenkinsfile = "groovy",
    automount = "systemd",
    device = "systemd",
    link = "systemd",
    mount = "systemd",
    network = "systemd",
    scope = "systemd",
    service = "systemd",
    slice = "systemd",
    socket = "systemd",
    swap = "systemd",
    target = "systemd",
    timer = "systemd",
  },
  pattern = {
    ["diloconboard.*%.conf"] = "dosini",
    ["compy.*%.conf.*"] = "dosini",
    ["Jenkinsfile.*"] = "groovy",
    ["%.gersemirc.*"] = "yaml",
  },
})
