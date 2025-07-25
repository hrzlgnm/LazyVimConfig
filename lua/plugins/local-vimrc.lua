return {
  "MarcWeber/vim-addon-local-vimrc",
  config = function()
    local g = vim.g
    g.local_vimrc = { names = { ".vimrc", ".vimrc.lua" }, hash_fun = "LVRHashOfFile" }
  end,
}
