return {
  "cdelledonne/vim-cmake",
  keys = {
    { "<leader>cb", "<cmd>CMakeBuild<cr>", desc = "[C]Make [B]uild" },
    { "<leader>cgr", "<cmd>CMakeGenerate Release<cr>", desc = "[C]Make [G]enerate [R]elease" },
    { "<leader>cgd", "<cmd>CMakeGenerate Debug<cr>", desc = "[C]Make [G]enerate [D]debug" },
  },
  config = function()
    local g = vim.g
    g.cmake_build_dir_location = "build"
  end,
}
