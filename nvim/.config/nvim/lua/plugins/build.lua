return {
  -- CMake integration (for future projects)
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = {
      "CMakeGenerate",
      "CMakeBuild",
      "CMakeRun",
      "CMakeDebug",
      "CMakeSelectBuildType",
      "CMakeSelectBuildTarget",
      "CMakeSelectLaunchTarget",
      "CMakeSelectKit",
      "CMakeOpen",
      "CMakeClose",
      "CMakeInstall",
      "CMakeClean",
      "CMakeStop",
    },
    keys = {
      { "<leader>mg", "<cmd>CMakeGenerate<cr>", desc = "CMake Generate" },
      { "<leader>mb", "<cmd>CMakeBuild<cr>", desc = "CMake Build" },
      { "<leader>mr", "<cmd>CMakeRun<cr>", desc = "CMake Run" },
      { "<leader>md", "<cmd>CMakeDebug<cr>", desc = "CMake Debug" },
      { "<leader>mt", "<cmd>CMakeSelectBuildType<cr>", desc = "CMake Select Build Type" },
      { "<leader>mT", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake Select Build Target" },
      { "<leader>ml", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "CMake Select Launch Target" },
      { "<leader>mo", "<cmd>CMakeOpen<cr>", desc = "CMake Open" },
      { "<leader>mc", "<cmd>CMakeClose<cr>", desc = "CMake Close" },
      { "<leader>mi", "<cmd>CMakeInstall<cr>", desc = "CMake Install" },
      { "<leader>mC", "<cmd>CMakeClean<cr>", desc = "CMake Clean" },
      { "<leader>ms", "<cmd>CMakeStop<cr>", desc = "CMake Stop" },
    },
    opts = {
      cmake_command = "cmake",
      ctest_command = "ctest",
      cmake_use_preset = true,
      cmake_regenerate_on_save = false,
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_build_options = {},
      cmake_build_directory = function()
        if vim.fn.has("win32") == 1 then
          return "build\\${variant:buildType}"
        end
        return "build/${variant:buildType}"
      end,
      cmake_soft_link_compile_commands = true,
      cmake_compile_commands_from_lsp = false,
      cmake_kits_path = nil,
      cmake_variants_message = {
        short = { show = true },
        long = { show = true, max_length = 40 },
      },
      cmake_dap_configuration = {
        name = "cpp",
        type = "codelldb",
        request = "launch",
        stopOnEntry = false,
        runInTerminal = true,
        console = "integratedTerminal",
      },
      cmake_executor = {
        name = "quickfix",
        opts = {},
        default_opts = {
          quickfix = {
            show = "always",
            position = "belowright",
            size = 10,
            encoding = "utf-8",
            auto_close_when_success = true,
          },
          toggleterm = {
            direction = "float",
            close_on_exit = false,
            auto_scroll = true,
            singleton = true,
          },
          overseer = {
            new_task_opts = {
              strategy = {
                "toggleterm",
                direction = "horizontal",
                autos_croll = true,
                quit_on_exit = "success",
              },
            },
            on_new_task = function(task)
              require("overseer").open({ enter = false, direction = "right" })
            end,
          },
          terminal = {
            name = "Main Terminal",
            prefix_name = "[CMakeTools]: ",
            split_direction = "horizontal",
            split_size = 11,
            single_terminal_per_instance = true,
            single_terminal_per_tab = true,
            keep_terminal_static_location = true,
            auto_resize = true,
            start_insert = false,
            focus = false,
            do_not_add_newline = false,
          },
        },
      },
      cmake_runner = {
        name = "terminal",
        opts = {},
        default_opts = {
          quickfix = {
            show = "always",
            position = "belowright",
            size = 10,
            encoding = "utf-8",
            auto_close_when_success = true,
          },
          toggleterm = {
            direction = "float",
            close_on_exit = false,
            auto_scroll = true,
            singleton = true,
          },
          overseer = {
            new_task_opts = {
              strategy = {
                "toggleterm",
                direction = "horizontal",
                autos_croll = true,
                quit_on_exit = "success",
              },
            },
            on_new_task = function(task) end,
          },
          terminal = {
            name = "Main Terminal",
            prefix_name = "[CMakeTools]: ",
            split_direction = "horizontal",
            split_size = 11,
            single_terminal_per_instance = true,
            single_terminal_per_tab = true,
            keep_terminal_static_location = true,
            auto_resize = true,
            start_insert = false,
            focus = false,
            do_not_add_newline = false,
          },
        },
      },
      cmake_notifications = {
        runner = { enabled = true },
        executor = { enabled = true },
        spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
        refresh_rate_ms = 100,
      },
      cmake_virtual_text_support = true,
    },
  },
}
