local function get_opts()
  local to_install = {
    "bash-language-server",
    "clang-format",
    "clangd",
    "codelldb",
    "gersemi",
    "groovy-language-server",
    "hadolint",
    "json-lsp",
    "markdownlint",
    "quick-lint-js",
    "shellcheck",
    "shellharden",
    "shfmt",
    "stylua",
  }
  return { ensure_installed = to_install, automatic_installation = {} }
end

return {
  "mason-org/mason.nvim",
  opts = get_opts(),
}
