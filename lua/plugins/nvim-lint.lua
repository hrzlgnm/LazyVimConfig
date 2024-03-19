return {
  "mfussenegger/nvim-lint",
  config = function()
    require("lint").linters_by_ft = {
      bitbake = { "oelint-adv" },
      systemd = { "systemdlint" },
    }
  end,
}
