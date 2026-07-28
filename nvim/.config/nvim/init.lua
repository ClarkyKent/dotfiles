-- Set leader keys FIRST (before any plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load the direnv/devbox environment SYNCHRONOUSLY, before lazy.nvim and
-- therefore before any LSP server is spawned. See lua/config/env.lua for why
-- the async direnv.vim approach does not work.
require("config.env").setup()

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load configuration modules from config directory
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Load plugins
require("lazy").setup("plugins")
