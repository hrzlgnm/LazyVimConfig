return {
  "williamboman/mason.nvim",
  cmd = {
    "Mason",
  },
  opts = {
    ensure_installed = {
      "black",
      "codelldb",
      "prettierd",
      "stylua",
      "shellcheck",
      "shfmt",
      "flake8",
    },
  },
}
