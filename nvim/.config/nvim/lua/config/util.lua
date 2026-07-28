-- Small helpers shared across the configuration.
local M = {}

---Toggle a vim option, optionally cycling between two explicit values.
---@param name string option name
---@param silent? boolean suppress the notification
---@param values? string[] two values to cycle between, instead of boolean
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

  if silent then
    return
  end

  local status = vim.opt_local[name]:get()
  if type(status) == "boolean" then
    status = status and "Enabled" or "Disabled"
  end
  local icon = status == "Enabled" and "󰄲 " or "󰄱 "
  vim.notify(icon .. " " .. name .. " " .. tostring(status), vim.log.levels.INFO, { title = "Option" })
end

---Report the result of an external toggle function.
---@param name string
---@param fn fun(): boolean?
---@param silent? boolean
function M.toggle_fn(name, fn, silent)
  local state = fn()
  if silent then
    return
  end
  local status = state and "Enabled" or "Disabled"
  local icon = state and "󰄲 " or "󰄱 "
  vim.notify(icon .. " " .. name .. " " .. status, vim.log.levels.INFO, { title = "Toggle" })
end

---Toggle inline (virtual text) diagnostics.
function M.toggle_diagnostics()
  local config = vim.diagnostic.config() or {}
  local new_value = config.virtual_text == false
  vim.diagnostic.config({ virtual_text = new_value })
  local icon = new_value and "󰄲 " or "󰄱 "
  vim.notify(
    icon .. " Inline Diagnostics " .. (new_value and "Enabled" or "Disabled"),
    vim.log.levels.INFO,
    { title = "LSP" }
  )
end

---Suppress or restore SonarLint diagnostics without stopping the server.
function M.toggle_sonarlint()
  if _G._sonarlint_enabled == nil then
    _G._sonarlint_enabled = true
  end
  _G._sonarlint_enabled = not _G._sonarlint_enabled

  if not _G._sonarlint_enabled then
    for _, client in ipairs(vim.lsp.get_clients({ name = "sonarlint" })) do
      local ns = vim.lsp.diagnostic.get_namespace(client.id)
      for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        vim.diagnostic.reset(ns, buffer)
      end
    end
  end

  local icon = _G._sonarlint_enabled and "󰄲 " or "󰄱 "
  vim.notify(
    icon .. " SonarLint Diagnostics " .. (_G._sonarlint_enabled and "Enabled" or "Disabled"),
    vim.log.levels.INFO,
    { title = "SonarQube" }
  )
end

return M
