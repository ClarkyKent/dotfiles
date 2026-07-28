-- Overseer task templates driven by what the project actually uses:
--   * `just`  -- recipes are discovered dynamically from the .justfile
--   * Meson   -- build directory is detected, not hardcoded
--   * invoke  -- `inv` tasks used for cross builds / unit tests
--
-- The previous Meson templates hardcoded `builddir`; the firmware project
-- builds into `_buildresults`, so all three templates were dead.

local M = {}

---Directories Meson might have configured, most specific first.
local MESON_BUILD_DIRS = { "_buildresults", "_buildresults_test", "builddir", "build" }

---@return string|nil root
local function project_root()
  local marker = vim.fs.find(
    { ".justfile", "justfile", "meson.build", "CMakeLists.txt", ".git" },
    { upward = true, path = vim.fn.getcwd() }
  )[1]
  return marker and vim.fs.dirname(marker) or vim.fn.getcwd()
end

---@return string|nil
function M.meson_build_dir()
  local root = project_root()
  for _, dir in ipairs(MESON_BUILD_DIRS) do
    -- A configured Meson build dir always contains build.ninja.
    if vim.fn.filereadable(root .. "/" .. dir .. "/build.ninja") == 1 then
      return dir
    end
  end
  -- Not configured yet -- fall back to the conventional name for this project.
  for _, dir in ipairs(MESON_BUILD_DIRS) do
    if vim.fn.isdirectory(root .. "/" .. dir) == 1 then
      return dir
    end
  end
  return nil
end

---Parse `just --dump --dump-format json` for recipe names, docs and params.
---Falls back to `just --summary` if the JSON dump is unavailable.
---@param root string
---@return table[]
local function just_recipes(root)
  local recipes = {}

  local dump = vim
    .system({ "just", "--unstable", "--dump", "--dump-format", "json" }, { cwd = root, text = true })
    :wait(5000)

  if dump.code == 0 and dump.stdout and dump.stdout ~= "" then
    local ok, decoded = pcall(vim.json.decode, dump.stdout)
    if ok and type(decoded) == "table" and type(decoded.recipes) == "table" then
      for name, recipe in pairs(decoded.recipes) do
        -- Skip private recipes (leading underscore), matching just's own
        -- `--summary` behaviour.
        if not vim.startswith(name, "_") then
          local params = {}
          for _, p in ipairs(recipe.parameters or {}) do
            params[#params + 1] = { name = p.name, default = p.default }
          end
          recipes[#recipes + 1] = {
            name = name,
            doc = recipe.doc,
            params = params,
          }
        end
      end
      table.sort(recipes, function(a, b)
        return a.name < b.name
      end)
      return recipes
    end
  end

  local summary = vim.system({ "just", "--summary" }, { cwd = root, text = true }):wait(5000)
  if summary.code == 0 and summary.stdout then
    for name in summary.stdout:gmatch("%S+") do
      recipes[#recipes + 1] = { name = name, params = {} }
    end
  end
  return recipes
end

---Recipes that should surface compiler diagnostics in the quickfix list.
local BUILD_LIKE = {
  build = true,
  build_all = true,
  build_debug = true,
  build_release = true,
  build_secure = true,
  build_native = true,
  build_tests = true,
  build_boot_debug = true,
  build_nimble = true,
  build_nimble_debug = true,
  build_nimble_spi = true,
  tidy = true,
  iwyu = true,
  test = true,
  run_tests = true,
  test_renode = true,
  ["test-lint"] = true,
}

function M.register(overseer)
  local root = project_root()

  -- ── just ──────────────────────────────────────────────────────────────
  overseer.register_template({
    name = "just",
    condition = {
      callback = function()
        return vim.fn.executable("just") == 1
          and (
            vim.fn.filereadable(project_root() .. "/.justfile") == 1
            or vim.fn.filereadable(project_root() .. "/justfile") == 1
          )
      end,
    },
    generator = function(_, cb)
      local r = project_root()
      local templates = {}
      for _, recipe in ipairs(just_recipes(r)) do
        templates[#templates + 1] = {
          name = "just " .. recipe.name,
          desc = recipe.doc,
          tags = BUILD_LIKE[recipe.name] and { overseer.TAG.BUILD } or nil,
          params = (function()
            if #recipe.params == 0 then
              return {}
            end
            local p = {}
            for _, param in ipairs(recipe.params) do
              p[param.name] = {
                type = "string",
                optional = param.default ~= nil,
                default = param.default,
              }
            end
            return p
          end)(),
          builder = function(params)
            local args = { recipe.name }
            for _, param in ipairs(recipe.params) do
              local value = params[param.name]
              if value and value ~= "" then
                args[#args + 1] = value
              end
            end
            vim.g.overseer_last_task = "just " .. recipe.name
            return {
              cmd = { "just" },
              args = args,
              cwd = r,
              components = BUILD_LIKE[recipe.name] and { "cc" } or { "default" },
            }
          end,
        }
      end
      cb(templates)
    end,
  })

  -- ── Meson ─────────────────────────────────────────────────────────────
  local function meson_condition()
    return vim.fn.executable("meson") == 1 and vim.fn.filereadable(project_root() .. "/meson.build") == 1
  end

  overseer.register_template({
    name = "meson setup",
    tags = { overseer.TAG.BUILD },
    condition = { callback = meson_condition },
    params = {
      builddir = { type = "string", default = M.meson_build_dir() or "_buildresults" },
      buildtype = {
        type = "enum",
        choices = { "debug", "debugoptimized", "release", "minsize", "plain" },
        default = "debug",
      },
    },
    builder = function(params)
      return {
        cmd = { "meson" },
        args = { "setup", params.builddir, "--buildtype", params.buildtype, "--reconfigure" },
        cwd = project_root(),
        components = { "cc" },
      }
    end,
  })

  overseer.register_template({
    name = "meson compile",
    tags = { overseer.TAG.BUILD },
    condition = { callback = meson_condition },
    params = {
      builddir = { type = "string", default = M.meson_build_dir() or "_buildresults" },
      target = { type = "string", optional = true },
    },
    builder = function(params)
      local args = { "compile", "-C", params.builddir }
      if params.target and params.target ~= "" then
        args[#args + 1] = params.target
      end
      return {
        cmd = { "meson" },
        args = args,
        cwd = project_root(),
        components = { "cc" },
      }
    end,
  })

  overseer.register_template({
    name = "meson test",
    tags = { overseer.TAG.TEST },
    condition = { callback = meson_condition },
    params = {
      builddir = { type = "string", default = M.meson_build_dir() or "_buildresults" },
      suite = { type = "string", optional = true },
      verbose = { type = "boolean", default = true },
    },
    builder = function(params)
      local args = { "test", "-C", params.builddir }
      if params.verbose then
        args[#args + 1] = "--print-errorlogs"
      end
      if params.suite and params.suite ~= "" then
        vim.list_extend(args, { "--suite", params.suite })
      end
      return {
        cmd = { "meson" },
        args = args,
        cwd = project_root(),
        components = { "cc" },
      }
    end,
  })

  -- ── invoke (inv) ──────────────────────────────────────────────────────
  overseer.register_template({
    name = "invoke",
    condition = {
      callback = function()
        return vim.fn.executable("inv") == 1
          and (
            vim.fn.filereadable(project_root() .. "/tasks.py") == 1
            or vim.fn.isdirectory(project_root() .. "/tools") == 1
          )
      end,
    },
    params = {
      task = { type = "string", desc = "invoke task, e.g. cross.runut" },
    },
    builder = function(params)
      return {
        cmd = { "inv" },
        args = vim.split(params.task, " +", { trimempty = true }),
        cwd = project_root(),
        components = { "cc" },
      }
    end,
  })

  -- ── Robot Framework ───────────────────────────────────────────────────
  overseer.register_template({
    name = "robot: run suite",
    tags = { overseer.TAG.TEST },
    condition = { filetype = { "robot" } },
    params = {
      target = { type = "string", default = "${file}" },
      outputdir = { type = "string", default = "output" },
    },
    builder = function(params)
      local target = params.target:gsub("%${file}", vim.fn.expand("%:p"))
      return {
        cmd = { "python", "-m", "robot" },
        args = { "--report", "NONE", "--outputdir", params.outputdir, target },
        cwd = project_root(),
        components = { "default" },
      }
    end,
  })

  _ = root
end

return M
