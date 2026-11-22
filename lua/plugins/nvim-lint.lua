return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      bitbake = { "oelint-adv" },
      systemd = { "systemdlint" },
    },
  },
}
