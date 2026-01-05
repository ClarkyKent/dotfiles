return {
  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
      options = { "buffers", "curdir", "tabpages", "winsize", "globals" },
      pre_save = nil,
    },
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },

  -- Project detection and switching
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = {
      manual_mode = false,
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "meson.build", "CMakeLists.txt" },
      ignore_lsp = {},
      exclude_dirs = {},
      show_hidden = false,
      silent_chdir = true,
      scope_chdir = "global",
      datapath = vim.fn.stdpath("data"),
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      -- Integrate with fzf-lua
      require("fzf-lua").register_ui_select()
    end,
    keys = {
      { "<leader>fp", function() require("fzf-lua").projects() end, desc = "Projects" },
    },
  },

  -- Task runner (Meson/CMake builds)
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerInfo" },
    keys = {
      { "<leader>oo", "<cmd>OverseerToggle<cr>", desc = "Overseer Toggle" },
      { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Overseer Run Task" },
      { "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Overseer Quick Action" },
      { "<leader>ot", "<cmd>OverseerTaskAction<cr>", desc = "Overseer Task Action" },
      { "<leader>oi", "<cmd>OverseerInfo<cr>", desc = "Overseer Info" },
    },
    opts = {
      strategy = {
        "toggleterm",
        direction = "horizontal",
        open_on_start = true,
        quit_on_exit = "success",
      },
      templates = { "builtin" },
      task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
        bindings = {
          ["?"] = "ShowHelp",
          ["g?"] = "ShowHelp",
          ["<CR>"] = "RunAction",
          ["<C-e>"] = "Edit",
          ["o"] = "Open",
          ["<C-v>"] = "OpenVsplit",
          ["<C-s>"] = "OpenSplit",
          ["<C-f>"] = "OpenFloat",
          ["<C-q>"] = "OpenQuickFix",
          ["p"] = "TogglePreview",
          ["<C-l>"] = "IncreaseDetail",
          ["<C-h>"] = "DecreaseDetail",
          ["L"] = "IncreaseAllDetail",
          ["H"] = "DecreaseAllDetail",
          ["["] = "DecreaseWidth",
          ["]"] = "IncreaseWidth",
          ["{"] = "PrevTask",
          ["}"] = "NextTask",
          ["<C-k>"] = "ScrollOutputUp",
          ["<C-j>"] = "ScrollOutputDown",
          ["q"] = "Close",
        },
      },
      form = {
        border = "rounded",
        win_opts = {
          winblend = 0,
        },
      },
      confirm = {
        border = "rounded",
        win_opts = {
          winblend = 0,
        },
      },
      task_win = {
        border = "rounded",
        win_opts = {
          winblend = 0,
        },
      },
      component_aliases = {
        default = {
          { "display_duration", detail_level = 2 },
          "on_output_summarize",
          "on_exit_set_status",
          { "on_complete_notify", statuses = { "FAILURE" } },
          "on_complete_dispose",
        },
        default_vscode = {
          "default",
          "on_result_diagnostics_quickfix",
        },
      },
      dap = false,
      log = {
        {
          type = "echo",
          level = vim.log.levels.WARN,
        },
        {
          type = "file",
          filename = "overseer.log",
          level = vim.log.levels.DEBUG,
        },
      },
    },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)

      -- Add custom templates for Meson
      overseer.register_template({
        name = "Meson Configure",
        builder = function()
          return {
            cmd = { "meson" },
            args = { "setup", "builddir" },
            cwd = vim.fn.getcwd(),
            components = { "default" },
          }
        end,
        condition = {
          filetype = { "c", "cpp" },
          callback = function()
            return vim.fn.filereadable("meson.build") == 1
          end,
        },
      })

      overseer.register_template({
        name = "Meson Compile",
        builder = function()
          return {
            cmd = { "meson" },
            args = { "compile", "-C", "builddir" },
            cwd = vim.fn.getcwd(),
            components = { "default" },
          }
        end,
        condition = {
          filetype = { "c", "cpp" },
          callback = function()
            return vim.fn.isdirectory("builddir") == 1
          end,
        },
      })

      overseer.register_template({
        name = "Meson Test",
        builder = function()
          return {
            cmd = { "meson" },
            args = { "test", "-C", "builddir" },
            cwd = vim.fn.getcwd(),
            components = { "default" },
          }
        end,
        condition = {
          filetype = { "c", "cpp" },
          callback = function()
            return vim.fn.isdirectory("builddir") == 1
          end,
        },
      })
    end,
  },
}
