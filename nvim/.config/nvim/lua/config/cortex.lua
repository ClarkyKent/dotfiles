-- Cortex-M debug support: target selection, GDB server lifecycle, and an SVD
-- peripheral register viewer.
--
-- This fills the gap left by VS Code's cortex-debug extension, which the
-- firmware project relies on (.vscode/launch.json defines J-Link launches for
-- an STM32H725AG with SVD files under .ozone/SVD/).
--
-- Per-project overrides live in `.nvim-cortex.json` at the project root, e.g.
--
--   {
--     "device":     "STM32H725AG",
--     "interface":  "jtag",
--     "server":     "jlink",
--     "serverPath": "/home/me/JLink_Linux_V866_x86_64/JLinkGDBServerCLExe",
--     "ipAddress":  "10.18.76.71",
--     "gdbPort":    2331,
--     "svdFile":    ".ozone/SVD/STM32H725.svd",
--     "elf": [
--       "_buildresults/src/apps/app_sag_record/Quara_fw.elf",
--       "_buildresults/src/apps/app_boot/wolfboot.elf"
--     ]
--   }

local M = {}

-- Neovim runs LuaJIT (Lua 5.1): the `<<`, `>>` and `&` operators do not exist.
-- Use LuaJIT's `bit` library, and mask results back to unsigned 32-bit for
-- display since bit.* returns signed 32-bit integers.
local bit = require("bit")

---@param value integer
---@return integer
local function u32(value)
  local n = bit.band(value, 0xFFFFFFFF)
  if n < 0 then
    n = n + 0x100000000
  end
  return n
end

---Extract a bitfield.
---@param value integer
---@param offset integer
---@param width integer
---@return integer
local function extract(value, offset, width)
  local mask = width >= 32 and 0xFFFFFFFF or (bit.lshift(1, width) - 1)
  return u32(bit.band(bit.rshift(value, offset), mask))
end

local DEFAULTS = {
  device = nil,
  interface = "swd",
  server = "jlink", -- "jlink" | "openocd" | "external"
  serverPath = nil,
  ipAddress = nil, -- remote J-Link server; nil means spawn locally
  gdbPort = 2331,
  svdFile = nil,
  elf = {},
  openocdConfig = {}, -- e.g. { "interface/stlink.cfg", "target/stm32h7x.cfg" }
}

local state = {
  config = nil,
  root = nil,
  server_job = nil,
}

---@return string|nil
local function project_root()
  local marker = vim.fs.find(
    { ".nvim-cortex.json", ".git", "meson.build", "CMakeLists.txt" },
    { upward = true, path = vim.fn.getcwd() }
  )[1]
  return marker and vim.fs.dirname(marker) or vim.fn.getcwd()
end

---Extract cortex-debug settings from a `.vscode/launch.json`.
---
---Deliberately pattern-based rather than JSON-based: these files are JSONC
---(comments + trailing commas) and in practice are often outright malformed --
---the firmware repo's own launch.json closes its `inputs` array with `}`.
---VS Code tolerates it, `vim.json.decode` does not.
---@param path string
---@param root string
---@return table
local function scrape_launch_json(path)
  local out = { elf = {} }
  if vim.fn.filereadable(path) == 0 then
    return out
  end
  local raw = table.concat(vim.fn.readfile(path), "\n")

  -- Split into brace-delimited configuration blocks and keep the ones that
  -- declare cortex-debug.
  for block in raw:gmatch("{(.-)\n%s*}") do
    if block:match('"type"%s*:%s*"cortex%-debug"') then
      local function field(key)
        local v = block:match('"' .. key .. '"%s*:%s*"([^"]*)"')
        if v == nil or v == "" then
          return nil
        end
        return v
      end
      out.device = out.device or field("device")
      out.interface = out.interface or field("interface")
      out.server = out.server or field("servertype")
      out.serverPath = out.serverPath or field("serverpath")
      out.ipAddress = out.ipAddress or field("ipAddress")
      out.svdFile = out.svdFile or field("svdFile")
      local exe = field("executable")
      if exe then
        out.elf[#out.elf + 1] = exe
      end
      local gdb_port = block:match('"gdbTarget"%s*:%s*"[^:]*:(%d+)"')
      out.gdbPort = out.gdbPort or (gdb_port and tonumber(gdb_port))
    end
  end
  return out
end

---Expand VS Code's ${workspaceFolder} / ${workspaceRoot} placeholders.
---@param value string|nil
---@param root string
---@return string|nil
local function expand_vars(value, root)
  if not value then
    return nil
  end
  return (value:gsub("%${workspaceFolder}", root):gsub("%${workspaceRoot}", root))
end

---Load `.nvim-cortex.json`, falling back to sensible defaults and, where
---possible, to the project's existing `.vscode/launch.json` cortex-debug entry.
---@param force? boolean
---@return table
function M.config(force)
  if state.config and not force then
    return state.config
  end

  local root = project_root()
  state.root = root
  local cfg = vim.deepcopy(DEFAULTS)

  local file = root .. "/.nvim-cortex.json"
  if vim.fn.filereadable(file) == 1 then
    local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(file), "\n"))
    if ok and type(decoded) == "table" then
      cfg = vim.tbl_deep_extend("force", cfg, decoded)
    else
      vim.notify("Could not parse " .. file, vim.log.levels.WARN, { title = "cortex" })
    end
  else
    -- Derive from .vscode/launch.json so an existing cortex-debug setup works
    -- with no extra configuration.
    local scraped = scrape_launch_json(root .. "/.vscode/launch.json")
    for _, key in ipairs({ "device", "interface", "server", "serverPath", "ipAddress", "gdbPort" }) do
      if scraped[key] ~= nil then
        cfg[key] = scraped[key]
      end
    end
    cfg.svdFile = expand_vars(scraped.svdFile, root) or cfg.svdFile
    if #scraped.elf > 0 then
      cfg.elf = vim.tbl_map(function(p)
        return expand_vars(p, root)
      end, scraped.elf)
    end
  end

  state.config = cfg
  return cfg
end

---Absolute paths of candidate ELF files, from config plus a build-dir glob.
---@return string[]
function M.elf_candidates()
  local cfg = M.config()
  local root = state.root or vim.fn.getcwd()
  local seen, out = {}, {}

  local function add(p)
    if p == "" or seen[p] then
      return
    end
    if not vim.startswith(p, "/") then
      p = root .. "/" .. p
    end
    if vim.fn.filereadable(p) == 1 and not seen[p] then
      seen[p] = true
      out[#out + 1] = p
    end
  end

  for _, p in ipairs(cfg.elf or {}) do
    add(p)
  end
  for _, pattern in ipairs({
    "_buildresults/**/*.elf",
    "builddir/**/*.elf",
    "build/**/*.elf",
    "target/**/*.elf",
  }) do
    for _, p in ipairs(vim.fn.glob(root .. "/" .. pattern, false, true)) do
      add(p)
    end
  end
  return out
end

---Prompt for (or auto-select) the ELF to debug. Returns a coroutine when a
---prompt is needed, as nvim-dap expects.
function M.pick_elf()
  local candidates = M.elf_candidates()
  if #candidates == 0 then
    return coroutine.create(function(co)
      vim.ui.input(
        { prompt = "Path to .elf: ", default = (state.root or vim.fn.getcwd()) .. "/", completion = "file" },
        function(input)
          coroutine.resume(co, input)
        end
      )
    end)
  end
  if #candidates == 1 then
    return candidates[1]
  end
  return coroutine.create(function(co)
    vim.ui.select(candidates, {
      prompt = "Select firmware ELF:",
      format_item = function(item)
        return vim.fn.fnamemodify(item, ":." .. (state.root or ""))
      end,
    }, function(choice)
      coroutine.resume(co, choice)
    end)
  end)
end

---GDB commands issued after the adapter starts, to connect to the probe.
---@return string[]
function M.attach_commands()
  local cfg = M.config()
  local host = cfg.ipAddress or "localhost"
  local cmds = {
    "set architecture arm",
    "set mem inaccessible-by-default off",
    ("target extended-remote %s:%d"):format(host, cfg.gdbPort),
  }
  if cfg.server == "jlink" or cfg.server == "openocd" then
    vim.list_extend(cmds, { "monitor halt" })
  end
  return cmds
end

-- ══════════════════════════════════════════════════════════════════════
-- GDB server lifecycle
-- ══════════════════════════════════════════════════════════════════════

function M.server_start()
  if state.server_job then
    vim.notify("GDB server already running", vim.log.levels.WARN, { title = "cortex" })
    return
  end

  local cfg = M.config()
  if cfg.ipAddress then
    vim.notify(
      ("Configured to use a remote GDB server at %s:%d -- nothing to start."):format(cfg.ipAddress, cfg.gdbPort),
      vim.log.levels.INFO,
      { title = "cortex" }
    )
    return
  end

  local cmd
  if cfg.server == "jlink" then
    local bin = cfg.serverPath or vim.fn.exepath("JLinkGDBServerCLExe")
    if bin == "" or bin == nil or vim.fn.executable(bin) == 0 then
      vim.notify(
        "J-Link GDB server not found. Set `serverPath` in .nvim-cortex.json",
        vim.log.levels.ERROR,
        { title = "cortex" }
      )
      return
    end
    if not cfg.device then
      vim.notify("No `device` configured in .nvim-cortex.json", vim.log.levels.ERROR, { title = "cortex" })
      return
    end
    cmd = {
      bin,
      "-device",
      cfg.device,
      "-if",
      cfg.interface:upper(),
      "-speed",
      "4000",
      "-port",
      tostring(cfg.gdbPort),
      "-nogui",
      "-singlerun",
    }
  elseif cfg.server == "openocd" then
    local bin = cfg.serverPath or vim.fn.exepath("openocd")
    if bin == "" or vim.fn.executable(bin) == 0 then
      vim.notify("openocd not found", vim.log.levels.ERROR, { title = "cortex" })
      return
    end
    cmd = { bin }
    for _, f in ipairs(cfg.openocdConfig or {}) do
      vim.list_extend(cmd, { "-f", f })
    end
    vim.list_extend(cmd, { "-c", ("gdb_port %d"):format(cfg.gdbPort) })
  else
    vim.notify("server type is 'external'; start it yourself", vim.log.levels.INFO, { title = "cortex" })
    return
  end

  state.server_job = vim.fn.jobstart(cmd, {
    cwd = state.root,
    on_exit = function(_, code)
      state.server_job = nil
      vim.schedule(function()
        vim.notify(("GDB server exited (%d)"):format(code), vim.log.levels.INFO, { title = "cortex" })
      end)
    end,
  })
  vim.notify(
    ("Started %s GDB server on port %d"):format(cfg.server, cfg.gdbPort),
    vim.log.levels.INFO,
    { title = "cortex" }
  )
end

function M.server_stop()
  if not state.server_job then
    vim.notify("No GDB server running", vim.log.levels.WARN, { title = "cortex" })
    return
  end
  vim.fn.jobstop(state.server_job)
  state.server_job = nil
end

-- ══════════════════════════════════════════════════════════════════════
-- SVD peripheral register viewer
-- ══════════════════════════════════════════════════════════════════════

local svd_cache = nil

---Minimal SVD parser: peripherals -> registers -> fields.
---Full XML parsing is overkill here; SVD files are machine-generated and
---extremely regular.
---@param path string
local function parse_svd(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local xml = f:read("*a")
  f:close()

  local peripherals = {}
  for block in xml:gmatch("<peripheral[^>]*>(.-)</peripheral>") do
    local name = block:match("<name>(.-)</name>")
    local base = block:match("<baseAddress>(.-)</baseAddress>")
    if name and base then
      local regs = {}
      for rblock in block:gmatch("<register>(.-)</register>") do
        local rname = rblock:match("<name>(.-)</name>")
        local offset = rblock:match("<addressOffset>(.-)</addressOffset>")
        local desc = rblock:match("<description>(.-)</description>")
        if rname and offset then
          local fields = {}
          for fblock in rblock:gmatch("<field>(.-)</field>") do
            local fname = fblock:match("<name>(.-)</name>")
            local bitoff = fblock:match("<bitOffset>(.-)</bitOffset>")
            local bitwidth = fblock:match("<bitWidth>(.-)</bitWidth>")
            if fname and bitoff then
              fields[#fields + 1] = {
                name = fname,
                offset = tonumber(bitoff),
                width = tonumber(bitwidth) or 1,
              }
            end
          end
          regs[#regs + 1] = {
            name = rname,
            offset = tonumber(offset) or 0,
            description = desc and desc:gsub("%s+", " ") or nil,
            fields = fields,
          }
        end
      end
      peripherals[#peripherals + 1] = {
        name = name,
        base = tonumber(base) or 0,
        registers = regs,
      }
    end
  end
  table.sort(peripherals, function(a, b)
    return a.name < b.name
  end)
  return peripherals
end

---@return table|nil
function M.svd()
  if svd_cache then
    return svd_cache
  end
  local cfg = M.config()
  local path = cfg.svdFile
  if not path then
    -- Look for any SVD in the usual places.
    for _, pattern in ipairs({ ".ozone/SVD/*.svd", "svd/*.svd", "*.svd" }) do
      local hits = vim.fn.glob((state.root or ".") .. "/" .. pattern, false, true)
      if #hits > 0 then
        path = hits[1]
        break
      end
    end
  end
  if not path then
    vim.notify("No SVD file found. Set `svdFile` in .nvim-cortex.json", vim.log.levels.WARN, { title = "cortex" })
    return nil
  end
  if not vim.startswith(path, "/") then
    path = (state.root or ".") .. "/" .. path
  end
  svd_cache = parse_svd(path)
  if not svd_cache then
    vim.notify("Failed to read SVD: " .. path, vim.log.levels.ERROR, { title = "cortex" })
  end
  return svd_cache
end

---Read `count` words of target memory through the active DAP session.
---@param addr integer
---@param count integer
---@param cb fun(values: integer[]|nil)
local function read_memory(addr, count, cb)
  local dap = require("dap")
  local session = dap.session()
  if not session then
    cb(nil)
    return
  end
  -- `x/<count>xw <addr>` via the REPL evaluate request works across gdb-dap.
  session:request("evaluate", {
    expression = ("x/%dxw 0x%08x"):format(count, addr),
    context = "repl",
  }, function(err, resp)
    if err or not resp or not resp.result then
      cb(nil)
      return
    end
    local values = {}
    for word in resp.result:gmatch("0x(%x+)") do
      values[#values + 1] = tonumber(word, 16)
    end
    cb(values)
  end)
end

---Browse peripherals -> registers, showing live values when a session is up.
function M.peripherals()
  local svd = M.svd()
  if not svd then
    return
  end

  vim.ui.select(svd, {
    prompt = "Peripheral:",
    format_item = function(p)
      return ("%-14s 0x%08X  (%d registers)"):format(p.name, p.base, #p.registers)
    end,
  }, function(periph)
    if not periph then
      return
    end

    local lines = { ("%s @ 0x%08X"):format(periph.name, periph.base), "" }
    local session = require("dap").session()

    local function render(values)
      for i, reg in ipairs(periph.registers) do
        local addr = periph.base + reg.offset
        local value = values and values[i]
        lines[#lines + 1] = value and ("  %-18s 0x%08X = 0x%08X"):format(reg.name, addr, value)
          or ("  %-18s 0x%08X"):format(reg.name, addr)
        if value then
          for _, fld in ipairs(reg.fields) do
            local fv = extract(value, fld.offset, fld.width)
            if fv ~= 0 then
              lines[#lines + 1] = ("      %-22s [%2d:%2d] = 0x%X"):format(
                fld.name,
                fld.offset + fld.width - 1,
                fld.offset,
                fv
              )
            end
          end
        end
        if reg.description then
          lines[#lines + 1] = ("      %s"):format(reg.description)
        end
      end

      vim.schedule(function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        vim.bo[buf].filetype = "cortex-peripherals"
        vim.bo[buf].bufhidden = "wipe"
        local width = math.min(100, math.floor(vim.o.columns * 0.8))
        local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.8))
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          border = "rounded",
          title = " " .. periph.name .. " ",
          title_pos = "center",
        })
        vim.wo[win].wrap = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
        vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
      end)
    end

    if session and #periph.registers > 0 then
      -- Registers are usually contiguous; read the whole window in one go.
      local max_offset = 0
      for _, r in ipairs(periph.registers) do
        max_offset = math.max(max_offset, r.offset)
      end
      read_memory(periph.base, math.floor(max_offset / 4) + 1, function(words)
        local values = nil
        if words then
          values = {}
          for i, reg in ipairs(periph.registers) do
            values[i] = words[math.floor(reg.offset / 4) + 1]
          end
        end
        render(values)
      end)
    else
      render(nil)
    end
  end)
end

-- ══════════════════════════════════════════════════════════════════════
-- Misc views
-- ══════════════════════════════════════════════════════════════════════

---Send a raw command to the debugger REPL and show the result.
---@param expr string
function M.eval(expr)
  local session = require("dap").session()
  if not session then
    vim.notify("No active debug session", vim.log.levels.WARN, { title = "cortex" })
    return
  end
  session:request("evaluate", { expression = expr, context = "repl" }, function(err, resp)
    vim.schedule(function()
      if err then
        vim.notify(tostring(err.message or err), vim.log.levels.ERROR, { title = "cortex" })
      else
        vim.notify(resp and resp.result or "(no output)", vim.log.levels.INFO, { title = expr })
      end
    end)
  end)
end

function M.core_registers()
  M.eval("info registers")
end

function M.disassemble()
  M.eval("disassemble /s")
end

function M.memory_view()
  vim.ui.input({ prompt = "Address (e.g. 0x20000000): " }, function(addr)
    if not addr or addr == "" then
      return
    end
    vim.ui.input({ prompt = "Words to read [16]: " }, function(count)
      M.eval(("x/%dxw %s"):format(tonumber(count) or 16, addr))
    end)
  end)
end

function M.reload()
  state.config = nil
  svd_cache = nil
  M.config(true)
  vim.notify("Reloaded cortex configuration", vim.log.levels.INFO, { title = "cortex" })
end

return M
