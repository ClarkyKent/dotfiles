
local on_attach = require("util.lsp").on_attach
local diagnostic_signs = require("util.icons").diagnostic_signs


local config = function()
	require("neoconf").setup({})
	local lsp = require("blink.cmp")
	local lspconfig = require("lspconfig")
	local capabilities = lsp.get_lsp_capabilities()


  -- lua
	lspconfig.lua_ls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = { -- custom settings for lua
			Lua = {
				-- make the language server recognize "vim" global
				diagnostics = {
					globals = { "vim" },
				},
        format = {
                            enable = true,
                            defaultConfig = {
                                align_continuous_assign_statement = false,
                                align_continuous_rect_table_field = false,
                                align_array_table = false,
                            },
                        },
				workspace = {
					library = {
						vim.fn.expand("$VIMRUNTIME/lua"),
						vim.fn.expand("$XDG_CONFIG_HOME") .. "/nvim/lua",
					},
				},
			},
		},
	})

  -- json
	lspconfig.jsonls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "json", "jsonc" },
	})

	-- python
	lspconfig.pyright.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			-- pyright = {
			-- 	disableOrganizeImports = false,
			-- 	analysis = {
			-- 		useLibraryCodeForTypes = true,
			-- 		autoSearchPaths = true,
			-- 		diagnosticMode = "workspace",
			-- 		autoImportCompletions = true,
			-- 	},
			-- },
		},
	})


	-- bash
	lspconfig.bashls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "sh", "aliasrc" },
	})

	-- docker
	lspconfig.dockerls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	-- C/C++
	lspconfig.clangd.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		cmd = {
			"clangd",
			"--offset-encoding=utf-16",
		},
	})

	-- for type, icon in pairs(diagnostic_signs) do
	-- 	local hl = "DiagnosticSign" .. type
	-- 	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	-- end

	local solhint = require("efmls-configs.linters.solhint")
	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")
	local flake8 = require("efmls-configs.linters.flake8")
	local black = require("efmls-configs.formatters.black")
	local eslint = require("efmls-configs.linters.eslint")
	local fixjson = require("efmls-configs.formatters.fixjson")
	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")
	local hadolint = require("efmls-configs.linters.hadolint")
	local cpplint = require("efmls-configs.linters.cpplint")
	local clangformat = require("efmls-configs.formatters.clang_format")
  local ruff_sort = require('efmls-configs.formatters.ruff_sort')
  local ruff = require('efmls-configs.formatters.ruff')
  local rufflint = require('efmls-configs.linters.ruff')
  local clang_tidy = require('efmls-configs.linters.clang_tidy')

	-- configure efm server
	lspconfig.efm.setup({
		filetypes = {
			"lua",
			"python",
			"json",
			"jsonc",
			"sh",
			"markdown",
			"docker",
			"c",
			"cpp",
		},
		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
			hover = true,
			documentSymbol = true,
			codeAction = true,
			completion = true,
		},
		settings = {
			languages = {
				lua = { luacheck, stylua },
				python = {ruff, ruff_sort, rufflint },
				json = { eslint, fixjson },
				jsonc = { eslint, fixjson },
				sh = { shellcheck, shfmt },
				markdown = { prettier_d },
				docker = { hadolint, prettier_d },
				c = { clangformat, clnag_tidy },
				cpp = { clangformat, clnag_tidy },
			},
		},
	})
end

return {

    "neovim/nvim-lspconfig",
  config = config,
	lazy = false,
    dependencies = {
    "windwp/nvim-autopairs",
		"creativenull/efmls-configs-nvim",
		"hrsh7th/cmp-buffer",
    "saghen/blink.cmp",
      {
        "folke/lazydev.nvim",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
}
