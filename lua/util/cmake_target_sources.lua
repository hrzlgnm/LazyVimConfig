-- Move source lists from add_executable/add_library into target_sources.
local api = vim.api
local get_node_text = vim.treesitter.get_node_text

local M = {}

-- Options that belong to the target declaration and must stay there.
local declaration_keywords = {
  ALIAS = true,
  EXCLUDE_FROM_ALL = true,
  GLOBAL = true,
  IMPORTED = true,
  INTERFACE = true,
  MACOSX_BUNDLE = true,
  MODULE = true,
  OBJECT = true,
  SHARED = true,
  STATIC = true,
  UNKNOWN = true,
  WIN32 = true,
}

local query_string = [[
  ((normal_command
    (identifier) @command_name
    (argument_list (argument)+ @argument)) @command
   (#any-of? @command_name "add_executable" "add_library" "target_sources"))
]]

local query
local function get_query()
  query = query or vim.treesitter.query.parse("cmake", query_string)
  return query
end

local function sortable_range(a, b)
  local a_row, a_col = a[1], a[2]
  local b_row, b_col = b[1], b[2]
  if a_row ~= b_row then
    return a_row < b_row
  end
  return a_col < b_col
end

--- Collect the commands we care about, in buffer order.
---@return {name: string, node: TSNode, args: {text: string, node: TSNode, range: integer[]}[]}[]|nil
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
  local commands = {}
  local by_node = {}
  -- Comments split the (argument)+ pattern into several matches; merge them
  -- back into one command entry before looking at the arguments.
  for _, matches, _ in q:iter_matches(parsed[1]:root(), bufnr, 0, -1, { all = true }) do
    local command_node = nil
    local name = nil
    for id, nodes in pairs(matches) do
      local capture = q.captures[id]
      if capture == "command" then
        command_node = nodes[1]
      elseif capture == "command_name" then
        name = get_node_text(nodes[1], bufnr)
      end
    end
    if command_node and name then
      local key = command_node:id()
      local command = by_node[key]
      if command == nil then
        command = { name = name, node = command_node, args = {}, seen = {} }
        by_node[key] = command
        table.insert(commands, command)
      end
      for id, nodes in pairs(matches) do
        if q.captures[id] == "argument" then
          for _, node in ipairs(nodes) do
            if not command.seen[node:id()] then
              command.seen[node:id()] = true
              table.insert(command.args, {
                text = get_node_text(node, bufnr),
                node = node,
                range = { node:range() },
              })
            end
          end
        end
      end
    end
  end
  for _, command in ipairs(commands) do
    command.seen = nil
    table.sort(command.args, function(a, b)
      return sortable_range(a.range, b.range)
    end)
  end
  table.sort(commands, function(a, b)
    local a_row, a_col = a.node:start()
    local b_row, b_col = b.node:start()
    return sortable_range({ a_row, a_col }, { b_row, b_col })
  end)
  return commands
end

local function leading_indent(line)
  return line:match("^%s*") or ""
end

local function is_indented_argument(lines, range)
  local line = lines[range[1] + 1]
  return line ~= nil and line:sub(1, range[2]):match("^%s*$") ~= nil
end

local function closing_paren(lines, node)
  local row, col = node:end_()
  local line = lines[row + 1]
  if line == nil then
    return row, col
  end
  for i = math.min(col, #line), 1, -1 do
    if line:sub(i, i) == ")" then
      return row, i - 1
    end
  end
  return row, col
end

local function insertion_lines(sources, indent)
  local result = {}
  for _, source in ipairs(sources) do
    table.insert(result, indent .. source)
  end
  return result
end

local function target_sources_block(target, sources, indent)
  local block = {
    indent .. "target_sources(" .. target,
    indent .. "    PRIVATE",
  }
  for _, line in ipairs(insertion_lines(sources, indent .. "        ")) do
    table.insert(block, line)
  end
  table.insert(block, indent .. ")")
  return block
end

--- Replace the whole add_* command so the target remains closed with ")".
local function rewrite_add(lines, command, args, extra_lines)
  local start_row, start_col = command.node:start()
  local end_row = select(1, command.node:end_())
  local end_line = lines[end_row + 1]
  local indent = leading_indent(lines[start_row + 1])

  local kept = { args[1].text }
  for i = 2, #args do
    if declaration_keywords[args[i].text:upper()] then
      table.insert(kept, args[i].text)
    end
  end

  local trailing = end_line:sub(select(2, command.node:end_()) + 1)
  local result = { indent .. command.name .. "(" .. table.concat(kept, " ") .. ")" .. trailing }

  -- Keep comments that lived inside the command as standalone lines.
  for row = start_row, end_row - 1 do
    local comment = lines[row + 1]:match("#.*")
    if comment then
      table.insert(result, leading_indent(lines[row + 1]) .. comment)
    end
  end
  for _, line in ipairs(extra_lines) do
    table.insert(result, line)
  end

  return { row = start_row, col = start_col, end_row = end_row, end_col = #end_line, lines = result }
end

--- Add the sources to an existing target_sources command.
local function append_existing(lines, command, sources, edits)
  local args = command.args
  local range = args[#args].range
  local indent = is_indented_argument(lines, range) and leading_indent(lines[range[1] + 1])
    or (leading_indent(lines[command.node:start() + 1]) .. "    ")

  local fileset = nil
  for _, arg in ipairs(args) do
    if arg.text:upper() == "FILE_SET" then
      fileset = arg
      break
    end
  end

  if fileset then
    local row, col = fileset.range[1], is_indented_argument(lines, fileset.range) and 0 or fileset.range[2]
    local insert = insertion_lines(sources, indent)
    if col == fileset.range[2] then
      -- Same line as the previous argument: end with a space instead of a newline.
      insert[#insert] = insert[#insert] .. " "
    else
      table.insert(insert, "")
    end
    table.insert(edits, { row = row, col = col, end_row = row, end_col = col, lines = insert })
    return
  end

  local close_row, close_col = closing_paren(lines, args[#args].node:parent())
  local insert = { "" }
  for _, line in ipairs(insertion_lines(sources, indent)) do
    table.insert(insert, line)
  end

  if close_row == range[3] then
    -- The closer was on the same line as the old last argument: give it a
    -- line of its own again.
    table.insert(insert, leading_indent(lines[command.node:start() + 1]))
    table.insert(edits, { row = close_row, col = close_col, end_row = close_row, end_col = close_col, lines = insert })
  else
    table.insert(edits, {
      row = range[3],
      col = range[4],
      end_row = range[3],
      end_col = range[4],
      lines = insert,
    })
  end
end

--- Move all inline source lists in the current CMake buffer into target_sources.
function M.move_sources()
  local bufnr = api.nvim_get_current_buf()
  local commands = collect(bufnr)
  if not commands then
    return
  end
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local existing = {}
  local groups = {}
  local edits = {}

  for _, command in ipairs(commands) do
    if command.name == "target_sources" and command.args[1] and existing[command.args[1].text] == nil then
      existing[command.args[1].text] = command
    elseif command.name == "add_executable" or command.name == "add_library" then
      local args = command.args
      if #args >= 1 then
        local skip = false
        local sources = {}
        for _, arg in ipairs(args) do
          local keyword = arg.text:upper()
          if keyword == "ALIAS" or keyword == "IMPORTED" then
            skip = true
            break
          end
        end
        if not skip then
          for i = 2, #args do
            if declaration_keywords[args[i].text:upper()] == nil then
              table.insert(sources, args[i])
            end
          end
          if #sources > 0 then
            local target = args[1].text
            local group = groups[target]
            if group == nil then
              group = { sources = {}, commands = {} }
              groups[target] = group
            end
            for _, source in ipairs(sources) do
              table.insert(group.sources, source.text)
            end
            table.insert(group.commands, command)
          end
        end
      end
    end
  end

  local extra_by_command = {}
  for target, group in pairs(groups) do
    local target_command = existing[target]
    if target_command then
      append_existing(lines, target_command, group.sources, edits)
    else
      local last_command = group.commands[1]
      for _, command in ipairs(group.commands) do
        if select(1, command.node:end_()) >= select(1, last_command.node:end_()) then
          last_command = command
        end
      end
      local indent = leading_indent(lines[select(1, last_command.node:start()) + 1])
      extra_by_command[last_command] = target_sources_block(target, group.sources, indent)
    end
  end

  for _, group in pairs(groups) do
    for _, command in ipairs(group.commands) do
      table.insert(edits, rewrite_add(lines, command, command.args, extra_by_command[command] or {}))
    end
  end

  if #edits == 0 then
    return
  end

  table.sort(edits, function(a, b)
    if a.row ~= b.row then
      return a.row > b.row
    end
    return a.col > b.col
  end)
  for _, edit in ipairs(edits) do
    api.nvim_buf_set_text(bufnr, edit.row, edit.col, edit.end_row, edit.end_col, edit.lines)
  end
  vim.notify(
    string.format("Moved sources for %d target%s", vim.tbl_count(groups), vim.tbl_count(groups) > 1 and "s" or ""),
    vim.log.levels.INFO
  )
end

--- Register buffer-local commands and keymaps for a CMake buffer.
function M.attach(bufnr)
  api.nvim_buf_create_user_command(bufnr, "CMakeMoveSources", M.move_sources, {
    desc = "Move add_executable/add_library sources into target_sources",
  })
  vim.keymap.set("n", "<M-x>", M.move_sources, { buffer = bufnr, desc = "Move sources into target_sources" })
end

return M
