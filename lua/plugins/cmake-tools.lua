local generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=ON", "-G", "Ninja" }
if vim.loop.os_uname().sysname == "Windows_NT" then
  generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=ON" }
end
return {
  {
    "Civitasv/cmake-tools.nvim",
    event = "LazyFile",
    cmd = { "CMakeBuild", "CMakeGenerate", "CMakeRun", "CMakeDebug" },
    config = function()
      require("cmake-tools").setup({
        cmake_build_directory = "build",
        cmake_generate_options = generate_options,
        cmake_soft_link_compile_commands = true,
      })
    end,
  },
}
