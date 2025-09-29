-- Utility functions for configuration
local M = {}

-- LSP utilities
M.lsp = {}

-- Simple on_attach registry
local on_attach_callbacks = {}

function M.lsp.on_attach(callback)
  table.insert(on_attach_callbacks, callback)
end

function M.lsp.get_on_attach_callbacks()
  return on_attach_callbacks
end

return M