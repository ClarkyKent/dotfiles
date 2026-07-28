-- Synchronous direnv/devbox environment loading.
--
-- Why this exists:
--   `direnv.vim` hooks `VimEnter` and exports asynchronously. When you run
--   `nvim src/foo.c`, the buffer is read (and LSP servers are spawned) during
--   startup -- *before* `VimEnter` fires and long before an async export
--   completes. clangd/rust-analyzer/ruff therefore resolve against the
--   pre-direnv PATH and silently fail to start.
--
--   This module runs `direnv export json` synchronously from `init.lua`,
--   before lazy.nvim (and therefore before any LSP config) is loaded.
--
--   If nvim was launched from a shell that already has the direnv hook active,
--   `direnv export json` emits an empty diff and this costs ~15ms.

local M = {}

---Keys we must never let a subshell clobber, since changing them mid-session
---breaks nvim itself.
local PROTECTED = {
  VIM = true,
  VIMRUNTIME = true,
  NVIM = true,
  NVIM_LOG_FILE = true,
  NVIM_APPNAME = true,
}

---@param json string
---@return integer count number of variables applied
local function apply(json)
  if json == nil or vim.trim(json) == "" then
    return 0
  end

  local ok, decoded = pcall(vim.json.decode, json, { luanil = { object = true } })
  if not ok or type(decoded) ~= "table" then
    return 0
  end

  local count = 0
  for key, value in pairs(decoded) do
    if not PROTECTED[key] then
      -- direnv encodes "unset this variable" as JSON null, which decodes to
      -- vim.NIL (or is dropped entirely with luanil=true).
      if value == vim.NIL then
        vim.env[key] = nil
      else
        vim.env[key] = tostring(value)
      end
      count = count + 1
    end
  end
  return count
end

---@param dir string
---@return boolean
local function has_envrc(dir)
  return vim.fs.find(".envrc", { path = dir, upward = true, type = "file" })[1] ~= nil
end

---True when the parent shell already exported this directory's environment
---(i.e. you launched nvim from a shell with `direnv hook` active). Re-running
---the export in that case costs ~600ms and changes nothing.
---@param dir string
---@return boolean
local function already_active(dir)
  local active = vim.env.DIRENV_DIR
  if not active or active == "" then
    return false
  end
  -- DIRENV_DIR is the loaded root prefixed with '-', e.g. "-/home/me/project"
  local root = active:gsub("^%-", "")
  local resolved = vim.uv.fs_realpath(dir) or dir
  return resolved == root or vim.startswith(resolved .. "/", root .. "/")
end

---Load the direnv environment for `dir` into the current nvim process.
---@param dir? string defaults to cwd
---@param opts? { notify?: boolean, timeout?: integer, force?: boolean }
---@return boolean loaded
function M.load(dir, opts)
  opts = opts or {}
  dir = dir or vim.uv.cwd()
  if not dir then
    return false
  end

  if vim.fn.executable("direnv") == 0 then
    return false
  end

  if not has_envrc(dir) then
    return false
  end

  if not opts.force and already_active(dir) then
    return false
  end

  -- `direnv export json` writes the env diff to stdout and status chatter to
  -- stderr. A non-zero exit usually means the .envrc is not `direnv allow`ed.
  local ok, result = pcall(function()
    return vim
      .system({ "direnv", "export", "json" }, {
        cwd = dir,
        text = true,
        env = { DIRENV_LOG_FORMAT = "" }, -- silence "direnv: loading ..." noise
      })
      :wait(opts.timeout or 30000)
  end)

  if not ok or not result then
    return false
  end

  if result.code ~= 0 then
    if opts.notify then
      vim.notify(
        ("direnv export failed (exit %d).\nRun `direnv allow` in %s"):format(result.code, dir),
        vim.log.levels.WARN,
        { title = "direnv" }
      )
    end
    return false
  end

  local count = apply(result.stdout)
  if count > 0 and opts.notify then
    vim.notify(("Loaded %d vars from direnv"):format(count), vim.log.levels.INFO, { title = "direnv" })
  end

  return count > 0
end

---Re-run the export and restart any running LSP clients so they pick up the
---new PATH. Used on `:cd` and by `:DirenvReload`.
function M.reload(dir)
  local loaded = M.load(dir, { notify = true, force = true })
  if loaded then
    -- Servers started against the old PATH need to be respawned.
    for _, client in ipairs(vim.lsp.get_clients()) do
      client:stop()
    end
    vim.defer_fn(function()
      vim.cmd.edit()
    end, 200)
  end
  return loaded
end

function M.setup()
  -- Initial, synchronous load. Must happen before lazy.nvim.
  M.load()

  vim.api.nvim_create_autocmd("DirChanged", {
    group = vim.api.nvim_create_augroup("direnv_env", { clear = true }),
    callback = function(args)
      M.load(args.file, { notify = true })
    end,
  })

  vim.api.nvim_create_user_command("DirenvReload", function()
    M.reload()
  end, { desc = "Reload direnv environment and restart LSP clients" })

  vim.api.nvim_create_user_command("DirenvStatus", function()
    local lines = {
      "cwd:          " .. (vim.uv.cwd() or "?"),
      "DEVBOX_ROOT:  " .. (vim.env.DEVBOX_PROJECT_ROOT or "(not in devbox)"),
      "VIRTUAL_ENV:  " .. (vim.env.VIRTUAL_ENV or "(none)"),
      "",
      "Resolved tools:",
    }
    for _, tool in ipairs({
      "clangd",
      "clang-format",
      "clang-tidy",
      "arm-none-eabi-gdb",
      "gdb",
      "rust-analyzer",
      "ruff",
      "meson",
      "mesonlsp",
      "just",
      "just-lsp",
      "gcovr",
      "sonarlint-ls",
    }) do
      local path = vim.fn.exepath(tool)
      lines[#lines + 1] = ("  %-20s %s"):format(tool, path ~= "" and path or "MISSING")
    end
    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "direnv" })
  end, { desc = "Show direnv/devbox environment status" })
end

return M
