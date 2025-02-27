local function get_opts()
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
    "clangd",
    "clang-format",
    "codelldb",
  }
  return { ensure_installed = to_install, automatic_installation = {} }
end

return {
  "williamboman/mason.nvim",
  cmd = {
    "Mason",
  },
  opts = get_opts(),
}
