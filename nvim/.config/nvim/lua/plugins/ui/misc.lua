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
	"tpope/vim-sleuth",
	-- No further initialization needed, as this is a real "vim" not a lua
	-- plugin.
},



}
