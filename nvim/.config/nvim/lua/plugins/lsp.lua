local on_attach = require("util.lsp").on_attach
local icons = require("util.icons").diagnostics
local servers_lsp = require("plugins.lsp.servers")

local config = function()
  require("neoconf").setup({})
  local lsp = require("blink.cmp")
  local lspconfig = require("lspconfig")
  local capabilities = lsp.get_lsp_capabilities()

  local signs = { Error = icons.Error, Warn = icons.Warning, Hint = icons.Hint, Info = icons.Information }
  for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
  end

  for server, opts in pairs(servers_lsp) do
    opts.capabilities = capabilities
    opts.on_attach = on_attach

    ---@diagnostic disable-next-line: missing-fields
    lspconfig[server].setup(opts)
  end

  local prettier_d = require("efmls-configs.formatters.prettier_d")
  local luacheck = require("efmls-configs.linters.luacheck")
  local stylua = require("efmls-configs.formatters.stylua")
  local eslint = require("efmls-configs.linters.eslint")
  local fixjson = require("efmls-configs.formatters.fixjson")
  local shellcheck = require("efmls-configs.linters.shellcheck")
  local shfmt = require("efmls-configs.formatters.shfmt")
  local hadolint = require("efmls-configs.linters.hadolint")
  local clangformat = require("efmls-configs.formatters.clang_format")
  local ruff_sort = require('efmls-configs.formatters.ruff_sort')
  local ruff = require('efmls-configs.formatters.ruff')
  local rufflint = require('efmls-configs.linters.ruff')
  local clang_tidy = require('efmls-configs.linters.clang_tidy')

  -- configure efm server
  lspconfig.efm.setup({
    filetypes = {
      "lua",
      "python",
      "json",
      "jsonc",
      "sh",
      "markdown",
      "docker",
      "c",
      "cpp",
    },
    init_options = {
      documentFormatting = true,
      documentRangeFormatting = true,
      hover = true,
      documentSymbol = true,
      codeAction = true,
      completion = true,
    },
    settings = {
      rootMarkers = {".git/"},
      languages = {
        lua = { luacheck, stylua },
        python = { ruff, ruff_sort, rufflint },
        json = { eslint, fixjson },
        jsonc = { eslint, fixjson },
        sh = { shellcheck, shfmt },
        markdown = { prettier_d },
        docker = { hadolint, prettier_d },
        c = { clang_tidy, clangformat },
        cpp = { clang_tidy, clangformat },
      },
    },
  })
end

return {

  "neovim/nvim-lspconfig",
  config = config,
  lazy = false,
  dependencies = {
    "windwp/nvim-autopairs",
    "creativenull/efmls-configs-nvim",
    "saghen/blink.cmp",
    {
      "folke/lazydev.nvim",
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
}
