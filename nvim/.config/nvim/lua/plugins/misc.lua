return {
  { 'brenoprata10/nvim-highlight-colors' },
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
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<CR>", { desc = "Telescope Undo" })
    end,
  },


 {
	"tpope/vim-sleuth",
	-- No further initialization needed, as this is a real "vim" not a lua
	-- plugin.
},
{
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate")
    end,
  },
  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Open Fugitive Panel" })
    end,
  },
  "tpope/vim-repeat",
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "aaronhallaert/advanced-git-search.nvim",
    dependencies = {
      "tpope/vim-fugitive",
      "tpope/vim-rhubarb",
    },
  },
}
