return {
  {
    "theprimeagen/harpoon",
    keys = {
      { "<leader>ha", '<cmd>lua require("harpoon.mark").add_file()<cr>', desc = { "[H]arpoon [A]dd File" } },
      {
        "<leader>ht",
        '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>',
        desc = { "[H]arpoon [T]oggle Quickmenu" },
      },
      { "<M-1>", '<cmd>lua require("harpoon.ui").nav_file(1)<cr>' },
      { "<M-2>", '<cmd>lua require("harpoon.ui").nav_file(2)<cr>' },
      { "<M-3>", '<cmd>lua require("harpoon.ui").nav_file(3)<cr>' },
      { "<M-4>", '<cmd>lua require("harpoon.ui").nav_file(4)<cr>' },
    },
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    setup = function()
      require("telescope").load_extension("harpoon")
    end,
  },
}
