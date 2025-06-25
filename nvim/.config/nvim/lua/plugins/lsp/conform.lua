return { -- Autoformat
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile", "InsertEnter", "LspAttach"},
  opts = {
		formatters_by_ft = {
			json = { "biome" },
			html = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },
			lua = { "stylua" },
			python = { "ruff" },
      cpp = { "clang-format" },
      c = { "clang-format" },
		},
		format_on_save = {
			lsp_fallback = true,
			async = false,
			timeout_ms = 1000,
		},
	},
  keys = {
		{
			mode = { "n", "v" },
			"<leader>cfm",
			function()
				require("conform").format({
					lsp_fallback = true,
					timeout_ms = 1000,
				})
			end,
			desc = "[C]ode [F]ormat [M]anually (Conform)",
		},
	},
}
