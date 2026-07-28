return {
  -- Testing framework
  --
  -- Adapter set matches the frameworks actually in use here: pytest and
  -- Robot Framework for the Python/integration side, Rust for the tooling
  -- crates. C/C++ unit tests (CppUTest / CMocka) are driven through Meson
  -- and `just`, so they are exposed as Overseer tasks rather than neotest
  -- adapters -- see lua/config/tasks.lua.
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
    },
    -- stylua: ignore
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
      { "<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run all tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show test output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop test" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
      { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Watch file tests" },
      { "]t", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next failed test" },
      { "[t", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Prev failed test" },
    },
    opts = function()
      return {
        adapters = {
          ["neotest-python"] = {
            dap = { justMyCode = false },
            runner = "pytest",
            -- Use the project's pinned pytest from .venv.
            python = function()
              if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
                return vim.env.VIRTUAL_ENV .. "/bin/python"
              end
              return vim.fn.exepath("python3")
            end,
          },
          ["neotest-rust"] = {
            args = { "--no-capture" },
          },
          -- No maintained neotest adapter exists for Robot Framework.
          -- Robot suites run through Overseer ("robot: run suite" template in
          -- lua/config/tasks.lua) and are debuggable via the "Robot Framework
          -- suite" DAP configuration in lua/plugins/debug.lua.
        },
        benchmark = { enabled = true },
        consumers = {},
        default_strategy = "integrated",
        diagnostic = { enabled = true, severity = vim.diagnostic.severity.ERROR },
        discovery = { concurrent = 0, enabled = true },
        floating = { border = "rounded", max_height = 0.6, max_width = 0.6, options = {} },
        highlights = {
          adapter_name = "NeotestAdapterName",
          border = "NeotestBorder",
          dir = "NeotestDir",
          expand_marker = "NeotestExpandMarker",
          failed = "NeotestFailed",
          file = "NeotestFile",
          focused = "NeotestFocused",
          indent = "NeotestIndent",
          marked = "NeotestMarked",
          namespace = "NeotestNamespace",
          passed = "NeotestPassed",
          running = "NeotestRunning",
          select_win = "NeotestWinSelect",
          skipped = "NeotestSkipped",
          target = "NeotestTarget",
          test = "NeotestTest",
          unknown = "NeotestUnknown",
        },
        icons = {
          child_indent = "│",
          child_prefix = "├",
          collapsed = "─",
          expanded = "╮",
          failed = "",
          final_child_indent = " ",
          final_child_prefix = "╰",
          non_collapsible = "─",
          passed = "",
          running = "",
          running_animated = { "/", "|", "\\", "-", "/", "|", "\\", "-" },
          skipped = "",
          unknown = "",
        },
        jump = { enabled = true },
        log_level = vim.log.levels.WARN,
        output = { enabled = true, open_on_run = "short" },
        output_panel = { enabled = true, open = "botright split | resize 15" },
        projects = {},
        quickfix = { enabled = true, open = false },
        run = { enabled = true },
        running = { concurrent = true },
        state = { enabled = true },
        status = { enabled = true, signs = true, virtual_text = false },
        strategies = { integrated = { height = 40, width = 120 } },
        summary = {
          animated = true,
          enabled = true,
          expand_errors = true,
          follow = true,
          mappings = {
            attach = "a",
            clear_marked = "M",
            clear_target = "T",
            debug = "d",
            debug_marked = "D",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            jumpto = "i",
            mark = "m",
            next_failed = "J",
            output = "o",
            prev_failed = "K",
            run = "r",
            run_marked = "R",
            short = "O",
            stop = "u",
            target = "t",
            watch = "w",
          },
          open = "botright vsplit | vertical resize 50",
        },
      }
    end,
    config = function(_, opts)
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          end,
        },
      }, neotest_ns)

      -- Instantiate adapters, skipping any that fail to load rather than
      -- taking the whole of neotest down with them.
      local adapters = {}
      for name, config in pairs(opts.adapters or {}) do
        local ok, adapter = pcall(require, name)
        if ok then
          adapters[#adapters + 1] = type(config) == "table" and adapter(config) or adapter
        else
          vim.schedule(function()
            vim.notify("neotest adapter unavailable: " .. name, vim.log.levels.DEBUG, { title = "neotest" })
          end)
        end
      end
      opts.adapters = adapters

      opts.consumers = opts.consumers or {}
      -- Refresh and auto-close trouble after running tests
      ---@type neotest.Consumer
      opts.consumers.trouble = function(client)
        client.listeners.results = function(adapter_id, results, partial)
          if partial then
            return
          end
          local tree = assert(client:get_position(nil, { adapter = adapter_id }))

          local failed = 0
          for pos_id, result in pairs(results) do
            if result.status == "failed" and tree:get_key(pos_id) then
              failed = failed + 1
            end
          end
          vim.schedule(function()
            local ok, trouble = pcall(require, "trouble")
            if ok and trouble.is_open() then
              trouble.refresh()
              if failed == 0 then
                trouble.close()
              end
            end
          end)
          return {}
        end
      end

      require("neotest").setup(opts)
    end,
  },

  -- NOTE: nvim-coverage lives in lua/plugins/coverage.lua. It used to be
  -- declared here as well, which made lazy.nvim merge two specs with
  -- conflicting `lang` tables, conflicting highlight palettes, and
  -- `<leader>tc` / `<leader>tl` bound to different commands.
}
