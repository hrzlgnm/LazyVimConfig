return {
  "Pocco81/auto-save.nvim",
  config = function()
    require("auto-save").setup({
      debounce_delay = 1000,
      trigger_events = { "InsertLeave" },
    })
  end,
}
