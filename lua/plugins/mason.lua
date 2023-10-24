return {
  "williamboman/mason.nvim",
  cmd = {
    "Mason",
  },
  opts = {
    ensure_installed = {
      "black",
      "codelldb",
      "flake8",
      "groovy-language-server",
      "prettier",
      "shellcheck",
      "shfmt",
      "stylua",
    },
  },
}
