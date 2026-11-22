-- Sort the argument lists of common CMake commands (target_sources, set, list, ...)
local api = vim.api
local get_node_text = vim.treesitter.get_node_text

local M = {}

local special_keywords = {
  INTERFACE = true,
  PUBLIC = true,
  PRIVATE = true,
  OPTIONAL = true,
  REQUIRED = true,
  OBJECT = true,
  LINK_PRIVATE = true,
  LINK_PUBLIC = true,
  STATIC = true,
  SHARED = true,
  MODULE = true,
  EXCLUDE_FROM_ALL = true,
  ALIAS = true,
}

-- once one of these is seen, every remaining argument of that command is
-- dropped (e.g. everything after PROPERTIES is key/value pairs, not a list)
local drop_rest_after_keywords = {
  PROPERTIES = true,
}

local drop_first_arg_commands = {
  set = 1,
  list = 2,
}

local single_line_sort_commands = {
  set = true,
  list = true,
}

local query_string = [[
  (normal_command
    (identifier) @command_name
    (argument_list (argument)+ @argument)
  (#any-of? @command_name "target_sources" "target_link_libraries" "target_compile_options" "target_include_directories" "add_library" "add_executable" "set_target_properties" "set" "list"))
]]

local query
local function get_query()
  query = query or vim.treesitter.query.parse("cmake", query_string)
  return query
end

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

-- ":sort" moves whole lines, so it is only safe when the range covers nothing
-- but arguments: no command prefix on the first line, no ")" on the last one.
local function is_line_sort_safe(bufnr, start_line, end_line, start_col, end_col)
  if end_line <= start_line then
    return false -- single line: ":sort" would be a no-op
  end
  local lines = api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  if #lines == 0 then
    return false
  end
  local head = lines[1]:sub(1, start_col)
  local tail = lines[#lines]:sub(end_col + 1)
  return head:match("^%s*$") ~= nil and tail:match("^%s*$") ~= nil
end

--- Collect all unsorted, sortable argument ranges in the buffer.
---@return {range: integer[], args: string[], cmd: string}[]|nil
local function collect(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "cmake")
  if parser == nil then
    return nil
  end
  local parsed = parser:parse()
  if parsed == nil then
    return nil
  end

  local q = get_query()
  local root = parsed[1]:root()
  local all_sortables = {}
  for _, matches, _ in q:iter_matches(root, bufnr, 0, -1, { all = true }) do
    local sortables = {}
    local drop_count = 0
    local cmd_name = nil
    local drop_rest = false
    for id, nodes in pairs(matches) do
      local capture_name = q.captures[id]
      if capture_name == "command_name" then
        cmd_name = get_node_text(nodes[1], bufnr)
        drop_count = drop_first_arg_commands[cmd_name] or 0
      elseif capture_name == "argument" then
        for _, node in ipairs(nodes) do
          local argument_value = get_node_text(node, bufnr)
          local range = { node:range() }
          local last = sortables[#sortables]

          local is_special = special_keywords[argument_value] == true
          local is_consecutive = false
          if last and last.range and not last.dropped then
            local last_end_row, last_end_col = last.range[3], last.range[4]
            local curr_start_row, curr_start_col = range[1], range[2]
            if last_end_row > 0 and last_end_col > 0 then
              is_consecutive = (curr_start_row == last_end_row and curr_start_col > last_end_col)
                or (curr_start_row == last_end_row + 1)
            end
          end

          if drop_rest_after_keywords[argument_value] then
            drop_rest = true
          end

          local should_drop = #sortables < drop_count
          if drop_rest or should_drop or is_special then
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

  return filter_out_sorted_and_dropped_and_flatten(all_sortables)
end

--- Turn a sortable into a change description, or nil when sorting it is unsafe.
local function to_change(bufnr, r)
  local start_line = r.range[1] + 1
  local end_line = r.range[3] + 1
  local start_col = r.range[2]
  local end_col = r.range[4]

  local is_single_line = start_line == end_line
  local use_word_sort = is_single_line and single_line_sort_commands[r.cmd]

  if not use_word_sort and not is_line_sort_safe(bufnr, start_line, end_line, start_col, end_col) then
    return nil
  end
  return {
    start_line = start_line,
    end_line = end_line,
    start_col = start_col,
    end_col = end_col,
    use_word_sort = use_word_sort,
  }
end

--- Apply one change. Returns true when the buffer text changed.
local function apply(bufnr, c)
  if c.use_word_sort then
    local line = api.nvim_buf_get_lines(bufnr, c.start_line - 1, c.end_line, false)[1]
    local prefix = line:sub(1, c.start_col)
    local suffix = line:sub(c.end_col + 1)
    local middle = line:sub(c.start_col + 1, c.end_col)

    local words = {}
    for word in middle:gmatch("%S+") do
      table.insert(words, word)
    end
    local original = table.concat(words, " ")
    table.sort(words, function(a, b)
      return a:lower() < b:lower()
    end)
    local sorted = table.concat(words, " ")

    if sorted == original then
      return false
    end
    api.nvim_buf_set_lines(bufnr, c.start_line - 1, c.end_line, false, { prefix .. sorted .. suffix })
    return true
  end

  local lines_before = api.nvim_buf_get_lines(bufnr, c.start_line - 1, c.end_line, false)
  vim.cmd(string.format("%d,%dsort iu", c.start_line, c.end_line))
  local lines_after = api.nvim_buf_get_lines(bufnr, c.start_line - 1, c.end_line, false)
  return #lines_before ~= #lines_after or table.concat(lines_before) ~= table.concat(lines_after)
end

--- Sort the unsorted range closest to the cursor.
function M.sort_nearest()
  local bufnr = api.nvim_get_current_buf()
  local sortable = collect(bufnr)
  if not sortable then
    return
  end

  local cursor_line = api.nvim_win_get_cursor(0)[1] - 1
  local best_match = nil
  local best_distance = math.huge
  for _, r in ipairs(sortable) do
    local distance = math.abs(r.range[1] - cursor_line)
    if distance < best_distance then
      best_distance = distance
      best_match = r
    end
  end

  local change = best_match and to_change(bufnr, best_match)
  if change then
    apply(bufnr, change)
  end
end

--- Sort every unsorted range in the buffer.
function M.sort_all()
  local bufnr = api.nvim_get_current_buf()
  local sortable = collect(bufnr)
  if not sortable then
    return
  end

  local changes = {}
  for _, r in ipairs(sortable) do
    local change = to_change(bufnr, r)
    if change then
      table.insert(changes, change)
    end
  end

  -- apply bottom-up so earlier ranges stay valid
  local sorted_count = 0
  for i = #changes, 1, -1 do
    if apply(bufnr, changes[i]) then
      sorted_count = sorted_count + 1
    end
  end

  if sorted_count > 0 then
    vim.notify(string.format("Sorted %d range%s", sorted_count, sorted_count > 1 and "s" or ""), vim.log.levels.INFO)
  end
end

--- Register buffer-local commands and keymaps for a cmake buffer.
function M.attach(bufnr)
  api.nvim_buf_create_user_command(bufnr, "CMakeSortAll", M.sort_all, { desc = "Sort all cmake sortable ranges" })
  api.nvim_buf_create_user_command(
    bufnr,
    "CMakeSelectFirstSortableRange",
    M.sort_nearest,
    { desc = "Sort the cmake sortable range nearest to the cursor" }
  )
  vim.keymap.set("n", "<M-y>", M.sort_all, { buffer = bufnr, desc = "Sort all cmake sortable ranges in file" })
end

return M
