local icons = require('utils.icons').diagnostics
local util = require('utils.util')

local auto_install = require('utils.util').get_user_config('auto_install', true)
local installed_servers = {}
if auto_install then
    installed_servers = require('plugins.treesitter_parsers').lsp_servers
end




return {
  {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
     opts = {
      inlay_hints = { enabled = true },
    },
    dependencies = {
      -- Useful status updates for LSP.
      -- LSP and notify updates in the down right corner
      {
        "j-hui/fidget.nvim",
        opts = {
          notification = {
            override_vim_notify = true,
          },
        },
      },

      -- Allows extra capabilities provided by nvim-cmp
      "saghen/blink.cmp",
    },
    config = function()

      local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
      blink_capabilities = vim.tbl_deep_extend("force", util.capabilities, blink_capabilities)

      local lspconfig = require("lspconfig")


      -- Make hover window have borders
      local floating_border_style = "rounded"

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = floating_border_style,
      })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = floating_border_style,
      })

      vim.diagnostic.config({
        float = { border = floating_border_style },
      })

      -- Show window/showMessage requests using vim.notify instead of logging to messages
      vim.lsp.handlers["window/showMessage"] = function(_, params, ctx)
        local message_type = params.type
        local message = params.message
        local client_id = ctx.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local client_name = client and client.name or string.format("id=%d", client_id)
        if not client then
          vim.notify("LSP[" .. client_name .. "] client has shut down after sending " .. message, vim.log.levels.ERROR)
        end
        if message_type == vim.lsp.protocol.MessageType.Error then
          vim.notify("LSP[" .. client_name .. "] " .. message, vim.log.levels.ERROR)
        else
          message = ("LSP[%s][%s] %s\n"):format(client_name, vim.lsp.protocol.MessageType[message_type], message)
          vim.notify(message, vim.log.levels[message_type])
        end
        return params
      end

      -- Change diagnostic symbols in the sign column (gutter)
      local signs = { ERROR = icons.Error , WARN = icons.Warning, INFO = icons.Information, HINT = icons.Hint }
      local diagnostic_signs = {}
      for type, icon in pairs(signs) do
        diagnostic_signs[vim.diagnostic.severity[type]] = icon
      end
      vim.diagnostic.config({ signs = { text = diagnostic_signs } })

       for _, server in ipairs(installed_servers) do
        lspconfig[server].setup({
          on_attach = util.on_attach,
          capabilities = blink_capabilities,
        })
      end
    end,
  },
}
