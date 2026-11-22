-- much stuff stolen from:
-- * https://github.com/tjdevries/config.nvim/blob/master/plugin/options.lua
-- * https://github.com/radleylewis/nvim-lite/blob/master/init.lua

local set = vim.opt

set.fileformats = "unix,dos,mac" -- keep line ends as they are
set.inccommand = "split" -- show live substitutions in a split window

-- Basic settings
set.wrap = true -- Wrap lines
set.scrolloff = 10 -- Keep 10 lines above/below cursor

-- Indentation
set.tabstop = 4 -- Tab width
set.shiftwidth = 4 -- Indent width
set.softtabstop = 4 -- Soft tab stop
set.breakindent = true -- Indent wrapped lines

-- Search settings
set.hlsearch = false -- Don't highlight search results

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
set.exrc = true -- Load trusted .nvim.lua/.nvimrc/.exrc from cwd and parents (see :trust)
set.iskeyword:append("-") -- Treat dash as part of word
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
    ["%.gersemirc.*"] = "yaml",
  },
})

-- Don't continue comments with o/O. Filetype plugins reset 'formatoptions',
-- so this has to run per buffer.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_no_comment_on_o", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove("o")
  end,
})
