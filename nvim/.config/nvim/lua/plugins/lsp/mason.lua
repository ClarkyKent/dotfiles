local auto_install = require('utils.util').get_user_config('auto_install', true)
local installed_servers = {}
if auto_install then
    installed_servers = require('plugins.treesitter_parsers').lsp_servers
end

-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP specification.
--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
local capabilities = vim.lsp.protocol.make_client_capabilities()
local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, blink_capabilities)



return {
	"williamboman/mason.nvim",
	 dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
	config = function()
		local mason = require("mason")
      	local mason_lspconfig = require("mason-lspconfig")
		local lspconfig = require("lspconfig")
		
		local default_setup = function(server)
			lspconfig[server].setup({
				capabilities = capabilities,
			})
		end

		mason.setup()
		mason_lspconfig.setup({
			ensure_installed = installed_servers, -- will be installed by mason
			automatic_installation = false,
			handlers = { default_setup },
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
				border = "bold",
				width = 0.8,
				height = 0.8,
			},
		})
	end,
}