return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      clangd = function(_, opts)
        opts.capabilities.offsetEncoding = { "utf-16" }
      end,
    },
    on_new_config = function(new_config, _)
      local ok, cmake = pcall(require, "cmake-tools")
      if ok then
        cmake.clangd_on_new_config(new_config)
      end
    end,
  },
}
