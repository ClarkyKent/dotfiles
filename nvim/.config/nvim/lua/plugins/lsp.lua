
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
				workspace = {
					library = {
						vim.fn.expand("$VIMRUNTIME/lua"),
						vim.fn.expand("$XDG_CONFIG_HOME") .. "/nvim/lua",
					},
				},
			},
		},
	})
end

return {
  
    "neovim/nvim-lspconfig",
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
  config = config,
  
}
