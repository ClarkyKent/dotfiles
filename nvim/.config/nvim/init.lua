local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins.editor" },
		{ import = "plugins.fs" },
		{ import = "plugins.ui" },
		{ import = "plugins.git_helpers" },
		{ import = "plugins.lsp" },
		{ import = "plugins.tools" },
	},
  change_detection = {
    notify = false,
  },
  -- ui config
	ui = {
		border = "bold",
		size = {
			width = 0.8,
			height = 0.8,
		},
	},

	checker = {
		enabled = true,
		notify = false,
	},
})

require("core.globals")
require("core.keymaps")
require("core.autocmds")
require("core.helpers")
require("core.snippets")
require("core.options")

vim.cmd("colorscheme gruvbox")
vim.cmd('hi IlluminatedWordText guibg=none gui=underline')
vim.cmd('hi IlluminatedWordRead guibg=none gui=underline')
vim.cmd('hi IlluminatedWordWrite guibg=none gui=underline')
require('nvim-highlight-colors').setup({
  enable_named_colors = false,
})
