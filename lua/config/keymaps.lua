-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- yank everything between { } including {}
map("n", "YY", "va{Vy", { desc = "Yank everything between {} including {}" })

-- greatest remap ever (<leader>p is yanky's yank history)
map("x", "<leader>P", [["_d"+P]], { desc = "Paste over selection (keep register)" })

-- Center screen when jumping (keeps LazyVim's direction-aware n/N)
map("n", "n", "'Nn'[v:searchforward].'zzzv'", { expr = true, desc = "Next search result (centered)" })
map("n", "N", "'nN'[v:searchforward].'zzzv'", { expr = true, desc = "Prev search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Join lines and keep cursor position
map("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })
