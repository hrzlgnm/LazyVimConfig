return {
  "williamboman/mason.nvim",
  cmd = {
    "Mason",
  },
  opts = {
    ensure_installed = {
      "black",
      "codelldb",
      "prettier",
      "stylua",
      "shellcheck",
      "shfmt",
      "flake8",
    },
  },
}
