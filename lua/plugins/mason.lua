return {
  "williamboman/mason.nvim",
  cmd = {
    "Mason",
  },
  opts = {
    ensure_installed = {
      "prettierd",
      "stylua",
      "shellcheck",
      "shfmt",
      "flake8",
    },
  },
}
