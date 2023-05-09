return {
  "Shatur/neovim-tasks",
  opts = {
    default_params = {
      cmake = {
        cmd = "cmake", -- CMake executable to use, can be changed using `:Task set_module_param cmake cmd`.
        build_dir = tostring(require("plenary.path"):new("{cwd}", "build", "{os}-{build_type}")), -- Build directory. The expressions `{cwd}`, `{os}` and `{build_type}` will be expanded with the corresponding text values. Could be a function that return the path to the build directory.
        build_type = "Debug", -- Build type, can be changed using `:Task set_module_param cmake build_type`.
        dap_name = "codelldb", -- DAP configuration name from `require('dap').configurations`. If there is no such configuration, a new one with this name as `type` will be created.
        args = { -- Task default arguments.
          configure = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1", "-G", "Ninja" },
        },
      },
    },
    save_before_run = true, -- Save current buffer before running a task.
    params_file = ".nvim-tasks.json",
    dap_open_command = function()
      return require("dapui").repl.open()
    end,
  },
}
