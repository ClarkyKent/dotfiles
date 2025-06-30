require("configs.nvchad.lspconfig").defaults()

local servers = { "html", "clangd" }

vim.lsp.config.clangd = {
  cmd = {
    "clangd",
    "--enable-config",
    "-j=2",
  },
  root_markers = { ".clangd", "compile_commands.json" },
  filetypes = { "c", "cpp" },
}

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
