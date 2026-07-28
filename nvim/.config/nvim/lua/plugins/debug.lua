-- Debug Adapter Protocol
--
-- This configuration targets the workflow this machine actually uses:
--   * ARM Cortex-M firmware (STM32H7) over a J-Link GDB server, debugged with
--     the devbox-provided `arm-none-eabi-gdb`.
--   * Host-side unit tests (CppUTest / CMocka / plain C) with system `gdb`.
--   * Python tooling and Robot Framework helpers with the project `.venv`.
--
-- The previous configuration only defined `codelldb`, which is not installed
-- and cannot drive a Cortex-M target over JTAG anyway.

---Resolve an executable, preferring the project/devbox environment.
---@param names string[]
---@return string|nil
local function resolve(names)
  for _, name in ipairs(names) do
    local path = vim.fn.exepath(name)
    if path ~= "" then
      return path
    end
  end
  return nil
end

---Find the project's Python interpreter (.venv first, then system).
local function python_path()
  if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
    local p = vim.env.VIRTUAL_ENV .. "/bin/python"
    if vim.fn.executable(p) == 1 then
      return p
    end
  end
  local cwd = vim.fn.getcwd()
  for _, dir in ipairs({ ".venv", "venv", "env" }) do
    local p = cwd .. "/" .. dir .. "/bin/python"
    if vim.fn.executable(p) == 1 then
      return p
    end
  end
  return resolve({ "python3", "python" }) or "python3"
end

---Locate ELF artefacts under the build directory so the user picks from a
---list instead of typing a path (the old `vim.fn.input` behaviour).
local function pick_executable(patterns)
  local cwd = vim.fn.getcwd()
  local results = {}
  for _, pat in ipairs(patterns) do
    for _, f in ipairs(vim.fn.glob(cwd .. "/" .. pat, false, true)) do
      if vim.fn.executable(f) == 1 or f:match("%.elf$") then
        results[#results + 1] = f
      end
    end
  end
  if #results == 0 then
    return coroutine.create(function(co)
      vim.ui.input({ prompt = "Path to executable: ", default = cwd .. "/", completion = "file" }, function(input)
        coroutine.resume(co, input)
      end)
    end)
  end
  if #results == 1 then
    return results[1]
  end
  return coroutine.create(function(co)
    vim.ui.select(results, {
      prompt = "Select executable:",
      format_item = function(item)
        return vim.fn.fnamemodify(item, ":.")
      end,
    }, function(choice)
      coroutine.resume(co, choice)
    end)
  end)
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    cmd = {
      "DapLoadLaunchJson",
      "CortexServerStart",
      "CortexServerStop",
      "CortexPeripherals",
      "CortexRegisters",
      "CortexMemory",
      "CortexDisassemble",
      "CortexReload",
      "CortexInfo",
    },
    -- stylua: ignore
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional Breakpoint" },
      { "<leader>dL", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "Log Point" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue / Start" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dj", function() require("dap").down() end, desc = "Frame Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Frame Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session Info" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Hover Widget" },
      { "<leader>dx", function() require("dap").clear_breakpoints() end, desc = "Clear All Breakpoints" },
      -- Cortex-M / embedded
      { "<leader>dP", function() require("config.cortex").peripherals() end, desc = "SVD Peripherals" },
      { "<leader>dR", function() require("config.cortex").core_registers() end, desc = "Core Registers" },
      { "<leader>dM", function() require("config.cortex").memory_view() end, desc = "Read Memory" },
      { "<leader>dD", function() require("config.cortex").disassemble() end, desc = "Disassemble" },
      { "<leader>dG", "<cmd>CortexServerStart<cr>", desc = "Start GDB Server" },
      { "<leader>dS", "<cmd>CortexServerStop<cr>", desc = "Stop GDB Server" },
    },
    config = function()
      local dap = require("dap")

      -- ══════════════════════════════════════════════════════════════════
      -- Adapters
      -- ══════════════════════════════════════════════════════════════════

      -- Native GDB DAP. GDB has spoken DAP directly since 14.x, which removes
      -- the need for cpptools/OpenDebugAD7 entirely. Used for host-side tests.
      local gdb = resolve({ "gdb" })
      if gdb then
        dap.adapters.gdb = {
          type = "executable",
          command = gdb,
          args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
        }
      end

      -- Cortex-M via arm-none-eabi-gdb talking to a J-Link / OpenOCD GDB
      -- server. `target extended-remote` is issued through `postRunCommands`.
      local arm_gdb = resolve({ "arm-none-eabi-gdb", "gdb-multiarch" })
      if arm_gdb then
        dap.adapters.cortex_gdb = {
          type = "executable",
          command = arm_gdb,
          args = { "--interpreter=dap" },
        }
      end

      -- codelldb, if it ever gets provisioned (host-side Rust/C++ only).
      local codelldb = resolve({ "codelldb" })
      if codelldb then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = { command = codelldb, args = { "--port", "${port}" } },
        }
      end

      -- Python: use the project virtualenv, not a hardcoded `python3`.
      dap.adapters.python = function(cb)
        cb({
          type = "executable",
          command = python_path(),
          args = { "-m", "debugpy.adapter" },
        })
      end

      -- ══════════════════════════════════════════════════════════════════
      -- Configurations
      -- ══════════════════════════════════════════════════════════════════

      local cortex_settings = require("config.cortex")

      dap.configurations.c = {
        {
          name = "Firmware: attach to J-Link GDB server",
          type = "cortex_gdb",
          request = "attach",
          program = function()
            return cortex_settings.pick_elf()
          end,
          cwd = "${workspaceFolder}",
          -- `target extended-remote` must run *after* the adapter starts.
          postRunCommands = function()
            return cortex_settings.attach_commands()
          end,
        },
        {
          name = "Firmware: flash and run (J-Link)",
          type = "cortex_gdb",
          request = "attach",
          program = function()
            return cortex_settings.pick_elf()
          end,
          cwd = "${workspaceFolder}",
          postRunCommands = function()
            local cmds = cortex_settings.attach_commands()
            vim.list_extend(cmds, { "load", "monitor reset halt" })
            return cmds
          end,
          stopAtBeginningOfMainSubprogram = true,
        },
        {
          name = "Unit test: launch host binary (gdb)",
          type = "gdb",
          request = "launch",
          program = function()
            return pick_executable({
              "_buildresults/**/*-test",
              "_buildresults/**/*_test",
              "_buildresults/**/test_*",
              "_buildresults_test/**/*-test",
              "builddir/**/*-test",
              "build/**/*-test",
            })
          end,
          cwd = "${workspaceFolder}",
          stopAtBeginningOfMainSubprogram = false,
        },
        {
          name = "Unit test: launch with arguments",
          type = "gdb",
          request = "launch",
          program = function()
            return pick_executable({ "_buildresults/**/*test*", "builddir/**/*test*" })
          end,
          args = function()
            local input = vim.fn.input("Arguments: ")
            return vim.split(input, " +", { trimempty = true })
          end,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Attach to running process (gdb)",
          type = "gdb",
          request = "attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Core dump (gdb)",
          type = "gdb",
          request = "launch",
          program = function()
            return pick_executable({ "_buildresults/**/*" })
          end,
          coreDumpPath = function()
            return vim.fn.input("Core dump path: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
        },
      }

      dap.configurations.cpp = dap.configurations.c

      dap.configurations.rust = {
        {
          name = "Launch (gdb)",
          type = "gdb",
          request = "launch",
          program = function()
            return pick_executable({ "target/debug/*", "tools/**/target/debug/*" })
          end,
          cwd = "${workspaceFolder}",
        },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch current file",
          program = "${file}",
          console = "integratedTerminal",
          cwd = "${workspaceFolder}",
          justMyCode = false,
          pythonPath = python_path,
        },
        {
          type = "python",
          request = "launch",
          name = "Launch module",
          module = function()
            return vim.fn.input("Module name: ")
          end,
          console = "integratedTerminal",
          cwd = "${workspaceFolder}",
          justMyCode = false,
          env = { PYTHONPATH = "${workspaceFolder}" },
          pythonPath = python_path,
        },
        {
          type = "python",
          request = "launch",
          name = "Robot Framework suite",
          module = "robot",
          args = function()
            local target = vim.fn.input("Robot suite/file: ", vim.fn.expand("%"), "file")
            return { "--outputdir", "output", target }
          end,
          console = "integratedTerminal",
          cwd = "${workspaceFolder}",
          justMyCode = false,
          pythonPath = python_path,
        },
        {
          type = "python",
          request = "attach",
          name = "Attach to remote debugpy",
          connect = function()
            local host = vim.fn.input("Host [127.0.0.1]: ")
            local port = tonumber(vim.fn.input("Port [5678]: ")) or 5678
            return { host = host ~= "" and host or "127.0.0.1", port = port }
          end,
        },
      }

      dap.configurations.robot = dap.configurations.python

      -- ══════════════════════════════════════════════════════════════════
      -- Signs
      -- ══════════════════════════════════════════════════════════════════
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      vim.fn.sign_define(
        "DapStopped",
        { text = "󰁕", texthl = "DiagnosticWarn", linehl = "Visual", numhl = "DiagnosticWarn" }
      )

      -- ══════════════════════════════════════════════════════════════════
      -- Import VS Code launch.json
      -- ══════════════════════════════════════════════════════════════════
      -- The firmware repo maintains .vscode/launch.json; reuse it so both
      -- editors stay in sync. cortex-debug/cppdbg entries are translated to
      -- the adapters defined above.
      pcall(function()
        require("dap.ext.vscode").load_launchjs(nil, {
          gdb = { "c", "cpp", "rust" },
          cortex_gdb = { "c", "cpp" },
          cppdbg = { "c", "cpp" },
          python = { "python" },
        })
      end)

      vim.api.nvim_create_user_command("DapLoadLaunchJson", function()
        require("dap.ext.vscode").load_launchjs(nil, {
          gdb = { "c", "cpp", "rust" },
          cortex_gdb = { "c", "cpp" },
          python = { "python" },
        })
        vim.notify("Reloaded .vscode/launch.json", vim.log.levels.INFO, { title = "DAP" })
      end, { desc = "Reload debug configurations from .vscode/launch.json" })

      -- ══════════════════════════════════════════════════════════════════
      -- Cortex-M commands (cortex-debug equivalents)
      -- ══════════════════════════════════════════════════════════════════
      local cmd = vim.api.nvim_create_user_command
      cmd("CortexServerStart", cortex_settings.server_start, { desc = "Start the J-Link/OpenOCD GDB server" })
      cmd("CortexServerStop", cortex_settings.server_stop, { desc = "Stop the GDB server" })
      cmd("CortexPeripherals", cortex_settings.peripherals, { desc = "Browse SVD peripheral registers" })
      cmd("CortexRegisters", cortex_settings.core_registers, { desc = "Show core registers" })
      cmd("CortexMemory", cortex_settings.memory_view, { desc = "Read target memory" })
      cmd("CortexDisassemble", cortex_settings.disassemble, { desc = "Disassemble around PC" })
      cmd("CortexReload", cortex_settings.reload, { desc = "Reload .nvim-cortex.json / SVD" })
      cmd("CortexInfo", function()
        local cfg = cortex_settings.config()
        vim.notify(
          table.concat({
            "device:     " .. tostring(cfg.device),
            "server:     " .. tostring(cfg.server),
            "interface:  " .. tostring(cfg.interface),
            "address:    " .. (cfg.ipAddress or "localhost") .. ":" .. cfg.gdbPort,
            "svd:        " .. tostring(cfg.svdFile),
            "gdb:        " .. tostring(arm_gdb),
            "elf:        " .. table.concat(cortex_settings.elf_candidates(), "\n            "),
          }, "\n"),
          vim.log.levels.INFO,
          { title = "cortex" }
        )
      end, { desc = "Show resolved Cortex-M debug configuration" })
    end,
  },

  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dapui").toggle({}) end, desc = "Toggle DAP UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Evaluate Expression" },
      { "<leader>dE", function() require("dapui").eval(vim.fn.input("Expression: ")) end, desc = "Evaluate Input" },
    },
    opts = {
      controls = {
        element = "repl",
        enabled = true,
        icons = {
          disconnect = "",
          pause = "",
          play = "",
          run_last = "",
          step_back = "",
          step_into = "",
          step_out = "",
          step_over = "",
          terminate = "",
        },
      },
      expand_lines = true,
      floating = {
        border = "rounded",
        mappings = { close = { "q", "<Esc>" } },
      },
      force_buffers = true,
      icons = { collapsed = "", current_frame = "", expanded = "" },
      layouts = {
        {
          -- Registers and watches matter far more than stacks in firmware work.
          elements = {
            { id = "scopes", size = 0.35 },
            { id = "watches", size = 0.25 },
            { id = "breakpoints", size = 0.20 },
            { id = "stacks", size = 0.20 },
          },
          position = "left",
          size = 46,
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          position = "bottom",
          size = 12,
        },
      },
      mappings = {
        edit = "e",
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        repl = "r",
        toggle = "t",
      },
      render = { indent = 1, max_value_lines = 100 },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
      end
    end,
  },

  -- Virtual text for DAP
  {
    "theHamsta/nvim-dap-virtual-text",
    -- Was eagerly loaded (no lazy trigger), pulling dap + dapui + nio into
    -- every startup for ~37ms. It is only meaningful once dap loads.
    lazy = true,
    opts = {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,
      only_first_definition = true,
      all_references = false,
      clear_on_continue = false,
      display_callback = function(variable, _, _, _, options)
        if options.virt_text_pos == "inline" then
          return " = " .. variable.value
        end
        return variable.name .. " = " .. variable.value
      end,
      virt_text_pos = "inline",
      all_frames = false,
      virt_lines = false,
      virt_text_win_col = nil,
    },
  },
}
