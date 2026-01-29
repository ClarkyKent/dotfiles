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



---@param name string

function M.toggle(name, silent, values)

  if values then

    if vim.opt_local[name]:get() == values[1] then

      vim.opt_local[name] = values[2]

    else

      vim.opt_local[name] = values[1]

    end

  else

    vim.opt_local[name] = not vim.opt_local[name]:get()

  end

  if not silent then

    local status = vim.opt_local[name]:get()

    if type(status) == "boolean" then

      status = status and "Enabled" or "Disabled"

    end

    local icon = status == "Enabled" and "󰄲 " or "󰄱 "

    vim.notify(icon .. " " .. name .. " " .. status, vim.log.levels.INFO, { title = "Option" })

  end

end



---@param name string

---@param fn fun(state: boolean): boolean?

function M.toggle_fn(name, fn, silent)

  local state = fn()

  if not silent then

    local status = state and "Enabled" or "Disabled"

    local icon = status == "Enabled" and "󰄲 " or "󰄱 "

        vim.notify(icon .. " " .. name .. " " .. status, vim.log.levels.INFO, { title = "Toggle" })

      end

    end

    

    function M.toggle_diagnostics()

      local config = vim.diagnostic.config() or {}

      local virtual_text = config.virtual_text

      local new_value

      if virtual_text == false then

        new_value = true

      else

        new_value = false

      end

      vim.diagnostic.config({ virtual_text = new_value })

      local status = new_value and "Enabled" or "Disabled"

      local icon = new_value and "󰄲 " or "󰄱 "

      vim.notify(icon .. " Inline Diagnostics " .. status, vim.log.levels.INFO, { title = "LSP" })

    end

    

    return M

    
