return {
  -- Markdown preview in browser
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = ":call mkdp#util#install()",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
    config = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_browser = ""
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_preview_options = {
        maid = { theme = "default" },
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
      }
    end,
  },

  -- In-editor markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Render" },
    },
    opts = {
      heading = {
        enabled = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        enabled = true,
        sign = false,
        style = "full",
        width = "block",
        border = "thin",
      },
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
      },
      quote = { enabled = true },
      pipe_table = {
        enabled = true,
        style = "full",
      },
      link = {
        enabled = true,
        hyperlink = "󰌹 ",
        custom = {
          web = { pattern = "^http", icon = "󰖟 " },
        },
      },
    },
  },

  -- RST/Sphinx preview (using sphinx-autobuild externally)
  -- Preview RST with: sphinx-autobuild docs docs/_build/html
}
