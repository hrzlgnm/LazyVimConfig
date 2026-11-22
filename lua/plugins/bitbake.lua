-- Yocto/BitBake: language server from the Yocto Project VS Code extension
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bitbake_language_server = {
          mason = false, -- installed via mason.nvim ensure_installed (no mason-lspconfig mapping)
          cmd = { "language-server-bitbake", "--stdio" },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "bitbake" } },
  },
}
