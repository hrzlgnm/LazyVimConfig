return {
  {
    "theprimeagen/harpoon",
    keys = {
      {
        "<leader>ha",
        function()
          require("harpoon.mark").add_file()
        end,
        desc = { "[H]arpoon [A]dd File" },
      },
      {
        "<leader>ht",
        function()
          require("harpoon.ui").toggle_quick_menu()
        end,
        desc = { "[H]arpoon [T]oggle Quickmenu" },
      },
      {
        "<M-1>",
        function()
          require("harpoon.ui").nav_file(1)
        end,
        desc = { "Harpoon jump to file 1" },
      },
      {
        "<M-2>",
        function()
          require("harpoon.ui").nav_file(2)
        end,
        desc = { "Harpoon jump to file 2" },
      },
      {
        "<M-3>",
        function()
          require("harpoon.ui").nav_file(3)
        end,
        desc = { "Harpoon jump to file 3" },
      },
      {
        "<M-4>",
        function()
          require("harpoon.ui").nav_file(4)
        end,
        desc = { "Harpoon jump to file 4" },
      },
    },
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("telescope").load_extension("harpoon")
    end,
  },
}
