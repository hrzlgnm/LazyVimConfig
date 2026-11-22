-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local api = vim.api

local function augroup(name)
  return api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Auto-close terminal when process exits cleanly
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup("AutoCloseTerminal"),
  callback = function(args)
    if vim.v.event.status == 0 then
      -- Defer so it runs after TermClose finishes
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          vim.api.nvim_buf_delete(args.buf, { force = true })
        end
      end)
    end
  end,
})

-- Disable line numbers in terminal and enter insert
-- mode to automatically follow the cursor
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("DisableLineNumbersInTerminalAndEnterInsertMode"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
})

-- CMake argument sorting (:CMakeSortAll, <M-y>) for cmake buffers
api.nvim_create_autocmd("FileType", {
  group = augroup("cmake_sort"),
  pattern = "cmake",
  callback = function(args)
    require("util.cmake_sort").attach(args.buf)
  end,
})
-- autocmds load on VeryLazy, so attach to cmake buffers that are already open
for _, buf in ipairs(api.nvim_list_bufs()) do
  if api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "cmake" then
    require("util.cmake_sort").attach(buf)
  end
end
