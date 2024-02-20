return {
  "williamboman/mason.nvim",
  cmd = {
    "Mason",
  },
  opts = {
    ensure_installed = {
      "bash-language-server",
      "clang-format",
      "cmakelint",
      "codelldb",
      "gersemi",
      "groovy-language-server",
      "hadolint",
      "markdownlint",
      "prettier",
      "quick-lint-js",
      "shellcheck",
      "shellharden",
      "shfmt",
      "stylua",
    },
  },
}
