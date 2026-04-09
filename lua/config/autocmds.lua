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
  for _, entry in ipairs(tbl) do
    for _, inner in ipairs(entry.sortables) do
      if not inner.dropped and not is_strictly_sorted_ascending_nocase(inner.args) then
        table.insert(flat, { range = inner.range, args = inner.args, cmd = entry.cmd })
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

local single_line_sort_commands = {
  set = true,
  list = true,
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
    local cmd_name = nil
    for id, nodes in pairs(matches) do
      local capture_name = query.captures[id]
      if capture_name == "command_name" then
        cmd_name = get_node_text(nodes[1], bufnr)
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
    table.insert(all_sortables, { cmd = cmd_name, sortables = sortables })
  end

  local sortable = filter_out_sorted_and_dropped_and_flatten(all_sortables)

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
    local start_col = best_match.range[2]
    local end_col = best_match.range[4]

    local is_single_line = start_line == end_line
    local use_word_sort = is_single_line and single_line_sort_commands[best_match.cmd]

    if use_word_sort then
      local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
      local line = lines[1]

      local prefix = line:sub(1, start_col)
      local suffix = line:sub(end_col + 1)
      local middle = line:sub(start_col + 1, end_col)

      local words = {}
      for word in middle:gmatch("%S+") do
        table.insert(words, word)
      end
      table.sort(words, function(a, b) return a:lower() < b:lower() end)

      local sorted_line = prefix .. table.concat(words, " ") .. suffix
      vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, { sorted_line })
    else
      vim.cmd(string.format("%d,%dsort iu", start_line, end_line))
    end
  end
end

api.nvim_create_user_command("CMakeSortAll", function()
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
    local cmd_name = nil
    for id, nodes in pairs(matches) do
      local capture_name = query.captures[id]
      if capture_name == "command_name" then
        cmd_name = get_node_text(nodes[1], bufnr)
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
    table.insert(all_sortables, { cmd = cmd_name, sortables = sortables })
  end

  local sortable = filter_out_sorted_and_dropped_and_flatten(all_sortables)

  local changes = {}
  for _, r in ipairs(sortable) do
    local start_line = r.range[1] + 1
    local end_line = r.range[3] + 1
    local start_col = r.range[2]
    local end_col = r.range[4]

    local is_single_line = start_line == end_line
    local use_word_sort = is_single_line and single_line_sort_commands[r.cmd]

    table.insert(changes, {
      start_line = start_line,
      end_line = end_line,
      start_col = start_col,
      end_col = end_col,
      use_word_sort = use_word_sort,
    })
  end

  for i = #changes, 1, -1 do
    local c = changes[i]
    if c.use_word_sort then
      local lines = vim.api.nvim_buf_get_lines(bufnr, c.start_line - 1, c.end_line, false)
      local line = lines[1]
      local prefix = line:sub(1, c.start_col)
      local suffix = line:sub(c.end_col + 1)
      local middle = line:sub(c.start_col + 1, c.end_col)

      local words = {}
      for word in middle:gmatch("%S+") do
        table.insert(words, word)
      end
      table.sort(words, function(a, b) return a:lower() < b:lower() end)

      local sorted_line = prefix .. table.concat(words, " ") .. suffix
      vim.api.nvim_buf_set_lines(bufnr, c.start_line - 1, c.end_line, false, { sorted_line })
    else
      vim.cmd(string.format("%d,%dsort iu", c.start_line, c.end_line))
    end
  end

  vim.notify(string.format("Sorted %d ranges", #changes), vim.log.levels.INFO)
end, {})

api.nvim_create_user_command("CMakeSelectFirstSortableRange", cmake_select_first_sortable_range, {})
