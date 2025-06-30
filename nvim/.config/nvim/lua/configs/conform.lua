local options = {
  formatters_by_ft = {
    json = { "biome" },
    html = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    lua = { "stylua" },
    python = { "ruff" },
    cpp = { "clang-format" },
    c = { "clang-format" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    async = false,
    lsp_fallback = true,
  },
}
return options
