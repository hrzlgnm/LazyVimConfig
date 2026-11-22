return {
  "lambdalisue/suda.vim",
  -- smart edit hooks BufReadCmd/FileReadCmd, so it has to be loaded at startup
  lazy = false,
  init = function()
    vim.g.suda_smart_edit = 1
  end,
}
