return { -- Autoformat
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
   config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          lua = { "stylua" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          json = { { "prettierd", "prettier", stop_after_first = true } },
          markdown = { { "prettierd", "prettier", stop_after_first = true } },
          erb = { "htmlbeautifier" },
          html = { "htmlbeautifier" },
          bash = { "beautysh" },
          proto = { "buf" },
          rust = { "rustfmt" },
          yaml = { "yamlfix" },
          toml = { "taplo" },
          sh = { "shellcheck" },
          python = { "riff_fix", "ruff_format", "ruff_organize_imports" },
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "[C]ode [F]ormat or range (in visual mode)" })
    end,
  }