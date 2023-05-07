return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
        clangd = {},
        cmake = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        tsserver = {},
        rust_analyzer = {},
        jsonls = {},
        vimls = {},
        yamlls = {},
      },
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.offsetEncoding = { "utf-16" }
      require("lspconfig").clangd.setup({ capabilities = capabilities })
    end,
  },
}
