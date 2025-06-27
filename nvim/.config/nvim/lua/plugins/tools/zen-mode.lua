return {
  "folke/zen-mode.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  keys = {
    {
      "<leader>uz",
      function()
        require("zen-mode").toggle()
      end,
      mode = { "n" },
      desc = "[U]i Toggle [Z]en Mode",
    },
  },
  opts = {
    backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
    window = {
      width = 120,
      options = {
        signcolumn = "no",
        number = false,
        relativenumber = false,
        cursorcolumn = false,
      },
    },
    on_open = function()
      ---@diagnostic disable-next-line: undefined-global
      Snacks.indent.disable()
    end,
    on_close = function()
      ---@diagnostic disable-next-line: undefined-global
      Snacks.indent.enable()
    end,
  },
}