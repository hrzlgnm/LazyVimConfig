return {
  "williamboman/mason.nvim",
  cmds = {
    "Mason",
  },
  opts = {
    ensure_installed = {
      "stylua",
      "shellcheck",
      "shfmt",
      "flake8",
    },
  },
}
