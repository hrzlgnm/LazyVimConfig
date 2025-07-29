-- much stuff stolen from:
-- * https://github.com/tjdevries/config.nvim/blob/master/plugin/options.lua
-- * https://github.com/radleylewis/nvim-lite/blob/master/init.lua

local set = vim.opt

set.fileformats = "unix,dos,mac" -- keep line ends as they are
set.inccommand = "split" -- show live substitutions in a split window

-- Basic settings
set.number = true -- Line numbers
set.relativenumber = true -- Relative line numbers
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
set.ignorecase = true -- Ignore case in search
set.smartcase = true -- Smart case sensitivity
set.hlsearch = false -- Don't highlight search results
set.incsearch = true -- Show search results as you type

-- Visual settings
set.termguicolors = true -- Enable 24-bit colors
set.signcolumn = "yes" -- Always show sign column
set.colorcolumn = "100" -- Show column at 100 characters
set.showmatch = true -- Highlight matching brackets
set.matchtime = 2 -- How long to show matching bracket

-- File handling
set.updatetime = 300 -- Faster completion
set.timeoutlen = 500 -- Key timeout duration
set.ttimeoutlen = 0 -- Key code timeout
set.autoread = true -- Auto reload files changed outside vim
set.autowrite = false -- Don't auto save

-- Behavior settings
set.hidden = true -- Allow hidden buffers
set.errorbells = false -- No error bells
set.backspace = "indent,eol,start" -- Better backspace behavior
set.autochdir = false -- Don't auto change directory
set.iskeyword:append("-") -- Treat dash as part of word
set.mouse = "a" -- Enable mouse support
set.clipboard:append("unnamedplus") -- Use system clipboard
set.encoding = "UTF-8"
set.formatoptions:remove("o") -- Don't have `o` add a comment
set.shada = { "'10", "<0", "s10", "h" }

-- Folding settings
set.foldmethod = "expr" -- Use expression for folding
set.foldexpr = "nvim_treesitter#foldexpr()" -- Use treesitter for folding
set.foldlevel = 99 -- Start with all folds open

-- Split behavior
vim.opt.splitbelow = true -- Horizontal splits go below
vim.opt.splitright = true -- Vertical splits go right

set.showbreak = "> "
set.linebreak = true

set.backspace = "indent,eol,start"

set.foldmethod = "marker"
set.foldlevel = 0
set.modelines = 1
set.belloff = "all"

set.joinspaces = true

set.fillchars = { eob = "~" }

-- Ignore compiled files
set.wildignore = "__pycache__"
set.wildignore:append({ "*.o", "*~", "*.pyc", "*pycache*" })

-- Floating window popup for completion on command line
set.pumblend = 17
set.wildmode = "longest:full"
set.wildoptions = "pum"

-- Performance improvements
set.updatetime = 1000
set.redrawtime = 10000
set.maxmempattern = 20000

-- Make some some providers shut up
local g = vim.g
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.python3_host_prog = "/usr/bin/python3"

-- Map localleader to ,
g.maplocalleader = ","

-- Use main brach of blink to avoid crashes
g.lazyvim_blink_main = true
