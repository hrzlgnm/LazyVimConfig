return {
  "williamboman/mason.nvim",
  cmd = {
    "Mason",
  },
  opts = {
    ensure_installed = {
      "codelldb",
      "prettierd",
      "stylua",
      "shellcheck",
      "shfmt",
      "flake8",
    },
  },
}
