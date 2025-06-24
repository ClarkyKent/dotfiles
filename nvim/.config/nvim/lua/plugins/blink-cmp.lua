return {
  "saghen/blink.cmp",
  -- optional: provides snippets for the snippet source
  dependencies = {  'rafamadriz/friendly-snippets' ,
                    -- "giuxtaposition/blink-cmp-copilot",
                  },

  -- use a release tag to download pre-built binaries
  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
     keymap = { preset = 'default' },
   
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },

    completion = {
      menu = {
        border = "rounded",
      },
      ghost_text = {
        enabled = true,
      },
      -- trigger = {
      --   -- Disable if preset super-tab is used
      --   show_in_snippet = true,
      -- },

      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        -- update_delay_ms = 0,

        window = {
          border = "rounded",
          desired_min_width = 30,
          -- direction_priority = {
          --   menu_north = { "s", "n", "e", "w" },
          --   menu_south = { "n", "s", "e", "w" },
          -- },
        },
      },
    },

    signature = { enabled = true },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      -- providers = {
      --   copilot = {
      --     enabled = function()
      --       return vim.g.copilot_completion_enabled
      --     end,
      --     name = "copilot",
      --     module = "blink-cmp-copilot",
      --     score_offset = 100,
      --     should_show_items = true,
      --   },
      -- },
    },
  },

  config = function(_, opts)
    local U = require("utils.util")
    U.newColorWithBase("CmpGhostText", "NonText")
    require("blink-cmp").setup(opts)
  end,
}