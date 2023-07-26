if false then
  return {}
end

return {
  {
    "hrzlgnm/cmake-tools.nvim",
    branch = "experimental",
    event = "BufRead",
    keys = {
      { "<leader>cb", "<cmd>CMakeBuild<cr>", desc = "[C]Make [B]uild" },
    },
    opts = {
      cmake_build_directory = "build",
      cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1", "-GNinja" },
      cmake_show_console = "always",
      cmake_dap_configuration = { name = "cpp", type = "codelldb", reqest = "launch" },
    },
  },
}
