-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("mark_syntax_as_dosini"),
  pattern = {
    "diloconboard*.conf",
    "compy*.conf*",
  },
  callback = function()
    vim.bo.filetype = "dosini"
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("mark_syntax_as_grovy"),
  pattern = {
    "Jenkinsfile*",
    "*.jenkinsfile",
  },
  callback = function()
    vim.bo.filetype = "groovy"
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("mark_syntax_as_systemd"),
  pattern = {
    "*.automount",
    "*.device",
    "*.link",
    "*.mount",
    "*.network",
    "*.scope",
    "*.service",
    "*.slice",
    "*.socket",
    "*.swap",
    "*.target",
    "*.timer",
  },
  callback = function()
    vim.bo.filetype = "systemd"
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
  group = augroup("auto-lint"),
  callback = function()
    require("lint").try_lint()
  end,
})

local api = vim.api
-- @todo use vim.treesitter.query.get_node_text instead
local ts_utils = require("nvim-treesitter.ts_utils")
local ts_query = vim.treesitter.query
local get_node_text = ts_query.get_node_text or ts_utils.get_node_text

local function select_sortable_range(bufnr, line, col, end_line, end_col)
  api.nvim_buf_set_mark(bufnr, "<", line + 1, col, {})
  api.nvim_buf_set_mark(bufnr, ">", end_line + 1, end_col - 1, {})
  vim.cmd([[
    normal! gv
]])
end

-- @todo perhaps consider using utf8 aware string compare
local function is_strictly_sorted_ascending_nocase(tbl)
  for i = 1, #tbl - 1 do
    if tbl[i]:lower() >= tbl[i + 1]:lower() then
      return false
    end
  end
  return true
end

local function flatten_filter(tbl)
  local flat = {}
  for _, outer in ipairs(tbl) do
    for _, inner in ipairs(outer) do
      if not inner.drop and not is_strictly_sorted_ascending_nocase(inner.args) then
        table.insert(flat, inner)
      end
    end
  end
  return flat
end

local special_keywords = { "INTERFACE", "PUBLIC", "PRIVATE" }

-- @todo: support more commands line add_library or add_executable
local function cmake_select_first_sortable_range()
  local query = vim.treesitter.query.parse(
    "cmake",
    [[
    (normal_command
      (identifier) @command_name
      (argument_list (argument)+ @argument)
    (#eq? @command_name "target_sources"))
    ;
    (normal_command
      (identifier) @command_name
      (argument_list (argument)+ @argument)
    (#eq? @command_name "target_link_libraries"))
]]
  )

  local bufnr = api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, "cmake")
  local tree = parser:parse()[1]
  local root = tree:root()
  local all_sortables = {}
  for _, matches, _ in query:iter_matches(root, bufnr, 0, -1, { all = true }) do
    local sortables = {}
    for id, nodes in pairs(matches) do
      local capture_name = query.captures[id]
      if capture_name == "argument" then
        for _, node in ipairs(nodes) do
          local argument_value = get_node_text(node, bufnr)[1]
          -- mark target or special_keywords as dropped
          if #sortables == 0 or vim.tbl_contains(special_keywords, argument_value) then
            table.insert(sortables, { drop = true })
          else
            local range = { node:range() }
            local last = sortables[#sortables]
            if not last.drop then
              -- extend range end_line and end_col
              last.range[3] = range[3]
              last.range[4] = range[4]
              -- add value
              table.insert(last.args, argument_value)
            else
              -- begin a new range
              table.insert(sortables, { range = range, args = { argument_value } })
            end
          end
        end
      end
    end
    table.insert(all_sortables, sortables)
  end
  local flat = flatten_filter(all_sortables)

  for _, r in ipairs(flat) do
    select_sortable_range(bufnr, unpack(r.range))
    break
  end
end

api.nvim_create_user_command("CMakeSelectFirstSortableRange", cmake_select_first_sortable_range, {})
