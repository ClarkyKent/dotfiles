return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "tpope/vim-sleuth",
    -- No further initialization needed, as this is a real "vim" not a lua
    -- plugin.
  },

  { import = "plugins.ui" },
  { import = "plugins.lsp" },
  { import = "plugins.editor" },
  { import = "plugins.tools" },
  { import = "plugins.git" },
}
