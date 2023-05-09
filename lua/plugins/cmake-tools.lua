return {
  {
    "hrzlgnm/cmake-tools.nvim",
    branch = "experimental",
    cmd = {
      "CMakeBuild",
      "CMakeClean",
      "CMakeClose",
      "CMakeDebug",
      "CMakeGenerate",
      "CMakeInstall",
      "CMakeOpen",
      "CMakeRun",
      "CMakeSelectBuildPreset",
      "CMakeSelectBuildTarget",
      "CMakeSelectBuildType",
      "CMakeSelectConfigurePresets",
      "CMakeSelectKit",
      "CMakeStop",
    },
    keys = {
      { "<leader>cb", "<cmd>CMakeBuild<cr>", desc = "[C]Make [B]uild" },
    },
    opts = {
      cmake_build_directory = "build",
      cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_show_console = "always",
      cmake_dap_configuration = { name = "cpp", type = "codelldb", reqest = "launch" },
    },
  },
}
