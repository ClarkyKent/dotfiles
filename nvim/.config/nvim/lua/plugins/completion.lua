return {
  {
    "saghen/blink.cmp",
    version = "v0.*",
    opts = {
      keymap = {
        preset = "default",
        ["<C-y>"] = { "select_and_accept" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },
}
