return {
  {
    "Civitasv/cmake-tools.nvim",
    event = "BufRead",
    opts = {
      cmake_build_directory = "build",
      cmake_build_directory_prefix = "",
      cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1", "-GNinja" },
      cmake_always_use_terminal = true,
      cmake_dap_configuration = { name = "cpp", type = "codelldb", reqest = "launch" },
      cmake_compile_commands_from_lsp = true,
    },
  },
}
