local util = {}

-- Load color from highlight colors and return as hex
function util.getColor(group, attr)
  local hl = vim.api.nvim_get_hl(0, { name = group })
  if not hl then
    return nil
  end

  local color = string.format("#%06x", hl[attr] or 0)
  return color
end

function util.newColorWithBase(hl, base, overrides)
  overrides = overrides or {}
  local new_color = {}
  new_color.link = nil
  -- Copy all properties from base highlight group
  local subst = vim.api.nvim_get_hl(0, { name = base })
  for k, v in pairs(subst) do
    new_color[k] = v
  end

  -- Override with everything else given
  for k, v in pairs(overrides) do
    new_color[k] = v
  end
  vim.api.nvim_set_hl(0, hl, new_color)
end



util.get_user_config = function(key, default)
    local status_ok, user = pcall(require, 'user')
    if not status_ok then
        return default
    end

    local user_config = user[key]
    if user_config == nil then
        return default
    end
    return user_config
end

util.get_root_dir = function()
    local bufname = vim.fn.expand('%:p')
    if vim.fn.filereadable(bufname) == 0 then
        return
    end

    local parent = vim.fn.fnamemodify(bufname, ':h')
    local git_root = vim.fn.systemlist('git -C ' .. parent .. ' rev-parse --show-toplevel')
    if #git_root > 0 and git_root[1] ~= '' then
        return git_root[1]
    else
        return parent
    end
end

util.get_file_path = function()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if vim.fn.filereadable(buf_name) == 1 then
        return buf_name
    end

    local dir_name = vim.fn.fnamemodify(buf_name, ':p:h')
    if vim.fn.isdirectory(dir_name) == 1 then
        return dir_name
    end

    return vim.loop.cwd()
end

util.get_file_type_cmd = function(extension)
    local root = util.get_root_dir()

    if extension == 'arb' and root then
        local gemfile_exists = vim.fn.filereadable(root .. '/Gemfile') == 1
        local pubspec_exists = vim.fn.filereadable(root .. '/pubspec.yaml') == 1
        if gemfile_exists then
            return 'setfiletype ruby'
        end
        if pubspec_exists then
            return 'setfiletype json'
        end
    end
    return ''
end

util.is_present = function(bin)
    return vim.fn.executable(bin) == 1
end

local function lsp_highlight_document(client, bufnr)
  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup("lsp_document_highlight", {
      clear = false
    })
    vim.api.nvim_clear_autocmds({
      buffer = bufnr,
      group = "lsp_document_highlight",
    })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

local function lsp_keymaps(client, bufnr)
  local keymap = function(mode, key, action, desc)
    vim.keymap.set(mode, key, action, { buffer = bufnr, desc = desc })
  end

  -- Peek definition
  -- You can edit the file containing the definition in the floating window
  -- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
  -- It also supports tagstack
  -- Use <C-t> to jump back
  keymap("n", "gD", vim.lsp.buf.declaration, "Goto declaration")

  -- Go to definition
  keymap("n", "gd", vim.lsp.buf.definition, "Go to definition")

  -- Diagnostic jump
  -- You can use <C-o> to jump back to your previous location
  keymap("n", "[d", vim.diagnostic.goto_prev, "Go to previous diagnostic")
  keymap("n", "]d", vim.diagnostic.goto_next, "Go to next diagnostic")

  -- If you want to keep the hover window in the top right hand corner,
  -- you can pass the ++keep argument
  -- Note that if you use hover with ++keep, pressing this key again will
  -- close the hover window. If you want to jump to the hover window
  -- you should use the wincmd command "<C-w>w"

  keymap("n", "K", vim.lsp.buf.hover)
end

util.on_attach = function(client, bufnr)
  lsp_keymaps(client, bufnr)
  lsp_highlight_document(client, bufnr)
end


local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.semanticHighlighting = true
capabilities.offsetEncoding = "utf-8"
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

util.capabilities = capabilities


return util