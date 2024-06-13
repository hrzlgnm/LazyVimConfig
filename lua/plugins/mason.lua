local function get_opts()
  local libc_is_musl = vim.fn.getfperm("/usr/lib/libc.so"):match("x") == "x"
  local to_install = {
    "bash-language-server",
    "cmakelint",
    "groovy-language-server",
    "hadolint",
    "markdownlint",
    "prettier",
    "quick-lint-js",
    "shellcheck",
    "shellharden",
    "shfmt",
    "stylua",
  }
  local excluded = {}
  if libc_is_musl then
    table.insert(excluded, "clang-format")
    table.insert(excluded, "codelldb")
    table.insert(excluded, "clangd")
  else
    table.insert(to_install, "clang-format")
    table.insert(to_install, "codelldb")
  end
  return { ensure_installed = to_install, automatic_installation = { exclude = excluded } }
end

return {
  "williamboman/mason.nvim",
  cmd = {
    "Mason",
  },
  opts = get_opts(),
}
