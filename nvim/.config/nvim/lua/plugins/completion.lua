return {
  {
    "saghen/blink.cmp",
    version = "*",
    dependencies = {
      -- LuaSnip is required by neogen (`snippet_engine = "luasnip"`), which
      -- previously failed outright because the plugin was never installed.
      -- It also unlocks the friendly-snippets collection, which was installed
      -- but never wired to anything.
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = (function()
          -- jsregexp enables LSP-standard snippet transforms. Optional.
          if vim.fn.executable("make") == 1 then
            return "make install_jsregexp"
          end
        end)(),
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
              -- Project-local snippets, e.g. firmware register-access idioms.
              require("luasnip.loaders.from_vscode").lazy_load({
                paths = { vim.fn.stdpath("config") .. "/snippets" },
              })
            end,
          },
        },
        opts = {
          history = true,
          delete_check_events = "TextChanged",
          updateevents = "TextChanged,TextChangedI",
        },
        keys = {
          {
            "<tab>",
            function()
              return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
            end,
            expr = true,
            silent = true,
            mode = "i",
          },
          {
            "<tab>",
            function()
              require("luasnip").jump(1)
            end,
            mode = "s",
          },
          {
            "<s-tab>",
            function()
              require("luasnip").jump(-1)
            end,
            mode = { "i", "s" },
          },
        },
      },
    },
    opts = {
      keymap = {
        preset = "default",
        ["<C-y>"] = { "select_and_accept" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        -- Documentation popup: the single biggest gap versus VSCode/Zed when
        -- exploring an unfamiliar HAL or driver API.
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
        menu = {
          border = "rounded",
          draw = { treesitter = { "lsp" } },
        },
        ghost_text = { enabled = false }, -- would fight Copilot's inline suggestions
      },
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },
    },
  },
}
