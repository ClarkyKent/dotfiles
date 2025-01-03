return {
  -- {
  -- 	"xiyaowong/nvim-transparent",
  -- 	lazy = false,
  -- 	priority = 999,
  -- },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("solarized-osaka").setup({
        transparent = true,
        terminal_colors = false, -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
        style = "moon",
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          -- Background styles. Can be "dark", "transparent" or "normal"
          sidebars = "normal", -- style for sidebars, see below
          floats = "normal",   -- style for floating windows
        },
      })
      vim.cmd.colorscheme("solarized-osaka")
    end,
  },
}
