-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- yank everything between { } including {}
map("n", "YY", "va{Vy", { desc = "Select everything between {} including {}" })

-- greatest remap ever
map("x", "<leader>p", [["_d"+P]], { desc = "Paste selected text over current selection" })
map(
  "n",
  "<m-y>",
  [[<cmd>CMakeSelectFirstSortableRange<CR><cmd>'<,'>Sort iu<CR><Esc>]],
  { desc = "Select and sort cmake sortable list range" }
)

local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

-- vim way: ; goes to the direction you were moving.
map({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
map({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
