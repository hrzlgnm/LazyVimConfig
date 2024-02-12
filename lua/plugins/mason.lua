return {
  "williamboman/mason.nvim",
  cmd = {
    "Mason",
  },
  opts = {
    ensure_installed = {
      "bash-language-server",
      "black",
      "clang-format",
      "cmakelint",
      "codelldb",
      "flake8",
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
