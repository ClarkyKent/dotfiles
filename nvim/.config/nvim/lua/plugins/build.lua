-- Task running / build integration.
--
-- This project family is Meson + `just` + `invoke`, not CMake. CMake remains
-- relevant only as a *language* (submodules ship CMakeLists.txt that we want
-- parsed, linted and formatted) -- see plugins/lsp.lua, linting.lua and
-- formatting.lua. The cmake-tools.nvim build integration that used to live
-- here has been removed: it bound 12 keys under <leader>m for a workflow this
-- project never uses, and collided with the markdown group.

return {
  -- Task runner
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerRun",
      "OverseerToggle",
      "OverseerInfo",
      "OverseerQuickAction",
      "OverseerTaskAction",
      "OverseerBuild",
    },
    -- stylua: ignore
    keys = {
      { "<leader>oo", "<cmd>OverseerToggle<cr>", desc = "Task list" },
      { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run task" },
      { "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Quick action" },
      { "<leader>ot", "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
      { "<leader>oi", "<cmd>OverseerInfo<cr>", desc = "Overseer info" },
      { "<leader>ob", "<cmd>OverseerBuild<cr>", desc = "Build task (form)" },
      { "<leader>ol", function() require("overseer").run_template({ name = vim.g.overseer_last_task or "" }) end, desc = "Re-run last task" },
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
        min_height = 18,
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
      form = { border = "rounded", win_opts = { winblend = 0 } },
      confirm = { border = "rounded", win_opts = { winblend = 0 } },
      task_win = { border = "rounded", win_opts = { winblend = 0 } },
      component_aliases = {
        default = {
          { "display_duration", detail_level = 2 },
          "on_output_summarize",
          "on_exit_set_status",
          { "on_complete_notify", statuses = { "FAILURE" } },
          "on_complete_dispose",
        },
        -- Compiler diagnostics land in the quickfix list, matching the
        -- problem matcher the VS Code tasks.json defines.
        cc = {
          "default",
          {
            "on_output_parse",
            parser = {
              diagnostics = {
                { "extract", "^([^%s].-):(%d+):(%d+):%s+(%w+):%s+(.*)$", "filename", "lnum", "col", "type", "text" },
              },
            },
          },
          "on_result_diagnostics",
          { "on_result_diagnostics_quickfix", open = true },
        },
      },
      dap = false,
      log = {
        { type = "echo", level = vim.log.levels.WARN },
        { type = "file", filename = "overseer.log", level = vim.log.levels.WARN },
      },
    },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)
      require("config.tasks").register(overseer)
    end,
  },
}
