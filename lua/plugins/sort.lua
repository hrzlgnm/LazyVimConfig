return {
  "sQVe/sort.nvim",
  config = function()
    require("sort").setup({
      -- Default delimiters contain ':' which would cause
      -- issues when sorting target_link_libraries in CMakeLists,
      -- therefore we omit the ':' here.
      delimiters = {
        ",",
        "|",
        ";",
        "s",
        "t",
      },
    })
  end,
}
