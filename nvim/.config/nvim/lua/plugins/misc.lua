return {
    {
  "folke/which-key.nvim",
        event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
},

-- Autopairs
{
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {},
},

-- comment
{
  "numToStr/Comment.nvim",
  event = "VeryLazy",
  opts = {
    mappings = {
      basic = true,
      extra = true,
      extended = false,
    },
  },

   {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    -- Default configuration. See
    -- https://github.com/folke/todo-comments.nvim#%EF%B8%8F-configuration for
    -- details
  },
},
 {
  -- Vim plugin no further initialization needed
  "mbbill/undotree",
  lazy = false,
},
  {
  {
    "echasnovski/mini.ai",
    opts = {},
  },
  {
    "echasnovski/mini.bracketed",
    opts = {},
  },
},

 {
	"tpope/vim-sleuth",
	-- No further initialization needed, as this is a real "vim" not a lua
	-- plugin.
},
}
