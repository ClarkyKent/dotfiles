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
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },

  -- Project detection and switching
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = {
      manual_mode = false,
      detection_methods = { "lsp", "pattern" },
      patterns = {
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
        "package.json",
        "meson.build",
        "CMakeLists.txt",
      },
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
      {
        "<leader>fp",
        function()
          require("fzf-lua").projects()
        end,
        desc = "Projects",
      },
    },
  },

  -- Task runner (Overseer) lives in lua/plugins/build.lua. It used to also
  -- be declared here with a second, conflicting spec (different task_list
  -- sizing, different keymaps, and a second `config` function registering
  -- ad-hoc Meson templates that duplicated what config.tasks.lua already
  -- provides). lazy.nvim merging two specs for the same plugin made the
  -- winning `opts`/`config` depend on file load order -- the same class of
  -- bug already fixed once for nvim-coverage (see plugins/testing.lua).
}
