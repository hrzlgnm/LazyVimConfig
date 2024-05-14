return {
  "tpope/vim-dadbod",
  "kristijanhusak/vim-dadbod-completion",
  "kristijanhusak/vim-dadbod-ui",
  config = function()
    local cmp = require("cmp")
    cmp.setup.filetype({ "sql" }, {
      sources = {
        { name = "vim-dadbod-completion" },
        { name = "buffer" },
      },
    })
  end,
}
