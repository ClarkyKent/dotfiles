return {
  -- Test coverage visualization (reads pre-generated lcov reports)
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
    },
    keys = {
      { "<leader>tc", "<cmd>CoverageToggle<cr>", desc = "Toggle Coverage" },
      { "<leader>tC", "<cmd>CoverageSummary<cr>", desc = "Coverage Summary" },
      { "<leader>tl", "<cmd>CoverageLoad<cr>", desc = "Load Coverage" },
      { "<leader>tL", function()
          local file = vim.fn.input("Coverage file: ", "coverage.info", "file")
          if file ~= "" then
            vim.cmd("CoverageLoadLcov " .. file)
          end
        end, desc = "Load Coverage (custom file)" },
      { "<leader>tx", "<cmd>CoverageClear<cr>", desc = "Clear Coverage" },
    },
    opts = {
      auto_reload = true,
      -- C/C++ coverage via lcov
      -- Configured in config() function below to dynamically find coverage file
      lang = {},
      -- Sign column indicators
      signs = {
        covered = { hl = "CoverageCovered", text = "▎" },
        uncovered = { hl = "CoverageUncovered", text = "▎" },
        partial = { hl = "CoveragePartial", text = "▎" },
      },
      -- Catppuccin-inspired colors
      highlights = {
        covered = { fg = "#a6e3a1" },   -- Green
        uncovered = { fg = "#f38ba8" }, -- Red
        partial = { fg = "#f9e2af" },   -- Yellow
      },
      -- Summary panel
      summary = {
        min_coverage = 80.0, -- Highlight red if below this threshold
      },
      -- Load coverage on entering buffer
      load_coverage_cb = function(ftype)
        vim.notify("Loaded " .. ftype .. " coverage", vim.log.levels.INFO)
      end,
    },
    config = function(_, opts)
      -- Helper to find coverage file
      local function find_coverage_file()
        if vim.g.coverage_file and vim.fn.filereadable(vim.g.coverage_file) == 1 then
          return vim.g.coverage_file
        end

        local cwd = vim.fn.getcwd()
        local possible_locs = {
          "builddir/meson-logs/coverage.info",
          "_buildresults/meson-logs/coverage.info",
          "build/meson-logs/coverage.info",
          "meson-logs/coverage.info",
          "coverage.info",
        }

        for _, loc in ipairs(possible_locs) do
          if vim.fn.filereadable(cwd .. "/" .. loc) == 1 then
            return loc
          end
        end
        return "builddir/meson-logs/coverage.info" -- Default fallback
      end

      local coverage_file = find_coverage_file()

      opts.lang = opts.lang or {}
      opts.lang.cpp = { coverage_file = coverage_file }
      opts.lang.c = { coverage_file = coverage_file }

      require("coverage").setup(opts)
    end,
  },
}
