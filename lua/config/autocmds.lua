-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("mark_syntax_as_dosini"),
  pattern = {
    "diloconboard.conf",
  },
  callback = function()
    vim.bo.filetype = "dosini"
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("mark_syntax_as_grovy"),
  pattern = {
    "Jenkinsfile*",
  },
  callback = function()
    vim.bo.filetype = "groovy"
  end,
})
