return {
  -- Test coverage visualization.
  --
  -- Coverage is produced out-of-band (`just coverage` -> gcovr/lcov); this
  -- plugin only renders the resulting report.
  {
    "andythigpen/nvim-coverage",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "Coverage",
      "CoverageLoad",
      "CoverageLoadLcov",
      "CoverageShow",
      "CoverageHide",
      "CoverageToggle",
      "CoverageSummary",
      "CoverageClear",
      "CoverageWhere",
    },
    -- stylua: ignore
    keys = {
      { "<leader>tc", "<cmd>CoverageToggle<cr>", desc = "Toggle coverage signs" },
      { "<leader>tC", "<cmd>CoverageSummary<cr>", desc = "Coverage summary" },
      { "<leader>tv", "<cmd>CoverageLoad<cr>", desc = "Load coverage report" },
      { "<leader>tV", function()
          local file = vim.fn.input("Coverage file: ", require("config.coverage").find() or "", "file")
          if file ~= "" then vim.cmd("CoverageLoadLcov " .. vim.fn.fnameescape(file)) end
        end, desc = "Load coverage (pick file)" },
      { "<leader>tx", "<cmd>CoverageClear<cr>", desc = "Clear coverage" },
    },
    opts = {
      auto_reload = true,
      lang = {},
      signs = {
        covered = { hl = "CoverageCovered", text = "▎" },
        uncovered = { hl = "CoverageUncovered", text = "▎" },
        partial = { hl = "CoveragePartial", text = "▎" },
      },
      highlights = {
        covered = { fg = "#a6e3a1" },
        uncovered = { fg = "#f38ba8" },
        partial = { fg = "#f9e2af" },
      },
      summary = {
        min_coverage = 80.0,
      },
      load_coverage_cb = function(ftype)
        vim.notify("Loaded " .. ftype .. " coverage", vim.log.levels.INFO, { title = "coverage" })
      end,
    },
    config = function(_, opts)
      local coverage_file = require("config.coverage").find()

      opts.lang = vim.tbl_deep_extend("force", opts.lang or {}, {
        c = { coverage_file = coverage_file },
        cpp = { coverage_file = coverage_file },
        python = {
          coverage_file = ".coverage",
          coverage_command = "coverage json --fail-under=0 -q -o -",
        },
        rust = {
          coverage_command = "grcov . -s . --binary-path ./target/debug/ -t coveralls "
            .. "--branch --ignore-not-existing -o -",
        },
      })

      require("coverage").setup(opts)

      vim.api.nvim_create_user_command("CoverageWhere", function()
        local found = require("config.coverage").find()
        vim.notify(found and ("Using: " .. found) or "No coverage report found", vim.log.levels.INFO, {
          title = "coverage",
        })
      end, { desc = "Show which coverage report would be loaded" })
    end,
  },
}
