return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-plenary",
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-vim-test",
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-jest",
    "nvim-lua/plenary.nvim",
    "vim-test/vim-test",
  },
  keys = {
    {
      "<leader>tt",
      function()
        require("neotest").run.run()
      end,
      desc = "[t]est neares[t]",
    },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      desc = "[t]est [f]ile",
    },
    {
      "<leader>ts",
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      desc = "[t]est [f]ile",
    },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-python")({
          dap = { justMyCode = false },
        }),
        require("neotest-jest"),
        require("neotest-plenary"),
        require("neotest-vim-test")({
          allow_file_types = { "javascript" },
        }),
      },
    })
    require("neodev").setup({
      library = {
        plugins = { "neotest" },
        types = true,
      },
    })
    local g = vim.g
    g["test#javascript#mocha#options"] = "--ui tdd"
  end,
}
