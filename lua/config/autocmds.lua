-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local api = vim.api

local function augroup(name)
  return api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- mark certain config files as ini syntax
api.nvim_create_autocmd("BufReadPost", {
  group = augroup("mark_syntax_as_dosini"),
  pattern = {
    "diloconboard*.conf",
    "compy*.conf*",
  },
  callback = function()
    vim.bo.filetype = "dosini"
  end,
})

-- Mark .jenkinsfile* files as groovy syntax
api.nvim_create_autocmd("BufReadPost", {
  group = augroup("mark_syntax_as_grovy"),
  pattern = {
    "Jenkinsfile*",
    "*.jenkinsfile",
  },
  callback = function()
    vim.bo.filetype = "groovy"
  end,
})

-- Mark .gersemirc* files as yaml syntax
api.nvim_create_autocmd("BufReadPost", {
  group = augroup("mark_syntax_as_yaml"),
  pattern = {
    ".gersemirc*",
  },
  callback = function()
    vim.bo.filetype = "yaml"
  end,
})

-- Mark systemd unit files as systemd syntax
api.nvim_create_autocmd("BufReadPost", {
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

-- Lint file after writing or reading
api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
  group = augroup("auto-lint"),
  callback = function()
    require("lint").try_lint()
  end,
})

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
  group = augroup("DisalbeLineNumbersInTerminalAndEnterInsertMode"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
})

--- cmake sort magic
local get_node_text = vim.treesitter.get_node_text

-- @todo perhaps consider using utf8 aware string compare
local function is_strictly_sorted_ascending_nocase(tbl)
  for i = 1, #tbl - 1 do
    if tbl[i]:lower() >= tbl[i + 1]:lower() then
      return false
    end
  end
  return true
end

local function filter_out_sorted_and_dropped_and_flatten(tbl)
  local flat = {}
  for _, outer in ipairs(tbl) do
    for _, inner in ipairs(outer) do
      if not inner.dropped and not is_strictly_sorted_ascending_nocase(inner.args) then
        table.insert(flat, inner)
      end
    end
  end
  return flat
end

local special_keywords = {
  "INTERFACE",
  "PUBLIC",
  "PRIVATE",
  "OPTIONAL",
  "REQUIRED",
  "OBJECT",
  "LINK_PRIVATE",
  "LINK_PUBLIC",
  "STATIC",
  "SHARED",
  "MODULE",
  "OBJECT",
  "EXCLUDE_FROM_ALL",
}

local drop_first_arg_commands = {
  set = 1,
  list = 2,
}

local function cmake_select_first_sortable_range()
  local bufnr = api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, "cmake")
  if parser == nil then
    return
  end
  local parsed = parser:parse()
  if parsed == nil then
    return
  end

  local query = vim.treesitter.query.parse(
    "cmake",
    [[
    (normal_command
      (identifier) @command_name
      (argument_list (argument)+ @argument)
    (#any-of? @command_name "target_sources" "target_link_libraries" "target_compile_options" "target_include_directories" "add_library" "add_executable" "set_target_properties" "set" "list"))
    ]]
  )

  local tree = parsed[1]
  local root = tree:root()
  local all_sortables = {}
  for _, matches, _ in query:iter_matches(root, bufnr, 0, -1, { all = true }) do
    local sortables = {}
    local drop_count = 0
    for id, nodes in pairs(matches) do
      local capture_name = query.captures[id]
      if capture_name == "command_name" then
        local cmd_name = get_node_text(nodes[1], bufnr)
        drop_count = drop_first_arg_commands[cmd_name] or 0
      elseif capture_name == "argument" then
        for _, node in ipairs(nodes) do
          local argument_value = get_node_text(node, bufnr)
          local range = { node:range() }
          local last = sortables[#sortables]

          local is_special = vim.tbl_contains(special_keywords, argument_value)
          local is_consecutive = false
          if last and last.range then
            local last_end_row, last_end_col = last.range[3], last.range[4]
            local curr_start_row, curr_start_col = range[1], range[2]
            if not last.dropped and last_end_row > 0 and last_end_col > 0 then
              is_consecutive = (curr_start_row == last_end_row and curr_start_col > last_end_col)
                or (curr_start_row == last_end_row + 1)
            end
          end

          local should_drop = #sortables < drop_count
          if should_drop or is_special then
            table.insert(sortables, { dropped = true })
          elseif is_consecutive then
            last.range[3] = range[3]
            last.range[4] = range[4]
            table.insert(last.args, argument_value)
          else
            table.insert(sortables, { range = range, args = { argument_value } })
          end
        end
      end
    end
    table.insert(all_sortables, sortables)
  end

  local sortable = filter_out_sorted_and_dropped_and_flatten(all_sortables)

  if #sortable == 0 then
    return
  end

  local cursor = api.nvim_win_get_cursor(0)
  local cursor_line = cursor[1] - 1

  local best_match = nil
  local best_distance = math.huge
  for _, r in ipairs(sortable) do
    local range_start = r.range[1]
    local distance = math.abs(range_start - cursor_line)
    if distance < best_distance then
      best_distance = distance
      best_match = r
    end
  end

  if best_match then
    local start_line = best_match.range[1] + 1
    local end_line = best_match.range[3] + 1
    vim.cmd(string.format("%d,%dsort iu", start_line, end_line))
  end
end

api.nvim_create_user_command("CMakeSelectFirstSortableRange", cmake_select_first_sortable_range, {})
