-- Runtime toggle for format-on-save.
--
-- conform's `format_on_save` used to be an unconditional table, so there was
-- no way to temporarily disable formatting -- awkward when touching vendored
-- or generated sources that a project-wide .clang-format would rewrite.
local M = {}

---@param buf? boolean operate on the current buffer instead of globally
---@return boolean
function M.enabled(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.b[bufnr].format_on_save ~= nil then
    return vim.b[bufnr].format_on_save
  end
  if vim.g.format_on_save == nil then
    return true
  end
  return vim.g.format_on_save
end

---@param buf? boolean toggle buffer-local rather than global
function M.toggle(buf)
  if buf then
    local bufnr = vim.api.nvim_get_current_buf()
    local current = M.enabled(bufnr)
    vim.b[bufnr].format_on_save = not current
    vim.notify(
      (not current and "󰄲  Format on save enabled (buffer)" or "󰄱  Format on save disabled (buffer)"),
      vim.log.levels.INFO,
      { title = "conform" }
    )
  else
    local current = vim.g.format_on_save
    if current == nil then
      current = true
    end
    vim.g.format_on_save = not current
    vim.notify(
      (not current and "󰄲  Format on save enabled (global)" or "󰄱  Format on save disabled (global)"),
      vim.log.levels.INFO,
      { title = "conform" }
    )
  end
end

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.b.format_on_save = false
  else
    vim.g.format_on_save = false
  end
end, { desc = "Disable format-on-save (! for current buffer only)", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.format_on_save = nil
  vim.g.format_on_save = true
end, { desc = "Re-enable format-on-save" })

return M
