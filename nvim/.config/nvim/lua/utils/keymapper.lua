local vim_modes = {
  n = "n",
  i = "i",
  v = "v",
}

local default_opts = {
  noremap = true,
  silent = true,
}

--- @param opts (table|nil)
--- @return table
local get_opts = function(opts)
  local all_opts = opts
  if all_opts == nil then
    all_opts = {}
  end
  for k, v in pairs(default_opts) do
    all_opts[k] = all_opts[k] or v
  end
  return all_opts
end

--- @param vimmode (string|nil)
--- @return string
local get_mode = function(vimmode)
  local modeString = vim_modes[vimmode]
  if modeString == nil then
    return "n"
  else
    return modeString
  end
end

--- @param command (string)
--- @return string
local get_cmd_string = function(command)
  return [[<cmd>]] .. command .. [[<CR>]]
end

--- @param keymaps string
--- @param command string
--- @param vimmode (string|nil)
--- @param options (table|nil)
--- @return nil
local mapvimkey = function(keymaps, command, vimmode, options)
  local mode = get_mode(vimmode)
  local lhs = keymaps
  local rhs = get_cmd_string(command)
  local opts = get_opts(options)
  vim.keymap.set(mode, lhs, rhs, opts)
end

--- @param keymaps string
--- @param cmd (function|string)
--- @param desc (string|nil)
--- @return table
local maplazykey = function(keymaps, cmd, desc)
  if type(cmd) ~= "function" then
    cmd = get_cmd_string(cmd)
  end
  return { keymaps, cmd, desc = desc }
end

--- @param mode string|table - Vim mode(s)
--- @param lhs string - Left-hand side (key combination)
--- @param command string - The command to execute (without <cmd> and <CR>)
--- @param opts table|nil - Options table (optional)
--- @return nil
local mapcmd = function(mode, lhs, command, opts)
  local rhs = get_cmd_string(command)
  local options = get_opts(opts)
  vim.keymap.set(mode, lhs, rhs, options)
end

--- @param lhs string - Left-hand side (key combination)
--- @param rhs string|function - Right-hand side (key sequence, function, or command)
--- @param mode string|table|nil - Vim mode(s), defaults to 'n'
--- @param opts table|nil - Options table (optional)
--- @return nil
local mapkey_general = function(lhs, rhs, mode, opts)
  local vim_mode = mode or "n"
  local options = get_opts(opts)
  vim.keymap.set(vim_mode, lhs, rhs, options)
end

return {
  mapvimkey = mapvimkey,
  maplazykey = maplazykey,
  mapcmd = mapcmd,
  mapkey_general = mapkey_general,
}
