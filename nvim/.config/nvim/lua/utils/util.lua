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

return util