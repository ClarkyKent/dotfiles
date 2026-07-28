-- Tool provisioning (hybrid model)
--
-- Precedence, highest first:
--   1. The project's virtualenv (.venv) -- pinned Python tooling
--   2. devbox / nix, loaded by lua/config/env.lua before anything else
--   3. Mason -- editor-only tools that no devbox.json is likely to carry
--
-- Mason's bin directory is *appended* to PATH (see plugins/lsp.lua) so it can
-- never shadow a version the project deliberately pins.
--
-- Only tools absent from the firmware devbox.json are listed here. Anything
-- devbox already provides (clangd, clang-format, clang-tidy, rust-analyzer,
-- ruff, mesonlsp, just-lsp, gcovr, lcov, arm-none-eabi-gdb, sonarlint-ls,
-- markdownlint-cli2, prettier, stylua, ...) is deliberately NOT installed by
-- Mason.

---Tools Mason should provide when they are not already on PATH.
local MASON_TOOLS = {
  -- Language servers
  "lua-language-server",
  "bash-language-server",
  "yaml-language-server",
  "json-lsp",
  "marksman",
  "dockerfile-language-server",
  "cmake-language-server",
  -- Formatters
  "shfmt",
  "taplo",
  -- Linters
  "shellcheck",
  "hadolint",
  "yamllint",
  "cmakelint",
}

---Executable produced by each Mason package, for the "is it already here?"
---check. Mason package names and binary names often differ.
local BINARY = {
  ["lua-language-server"] = "lua-language-server",
  ["bash-language-server"] = "bash-language-server",
  ["yaml-language-server"] = "yaml-language-server",
  ["json-lsp"] = "vscode-json-language-server",
  ["marksman"] = "marksman",
  ["dockerfile-language-server"] = "docker-langserver",
  ["cmake-language-server"] = "cmake-language-server",
  ["shfmt"] = "shfmt",
  ["taplo"] = "taplo",
  ["shellcheck"] = "shellcheck",
  ["hadolint"] = "hadolint",
  ["yamllint"] = "yamllint",
  ["cmakelint"] = "cmakelint",
}

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    config = function()
      -- Filter out anything the environment already supplies. Without this,
      -- Mason would download a second clangd/ruff/stylua and -- depending on
      -- PATH order -- silently disagree with the project's pinned version.
      local wanted = {}
      for _, pkg in ipairs(MASON_TOOLS) do
        local bin = BINARY[pkg] or pkg
        if vim.fn.executable(bin) == 0 then
          wanted[#wanted + 1] = pkg
        end
      end

      require("mason-tool-installer").setup({
        ensure_installed = wanted,
        auto_update = false,
        run_on_start = false, -- installs are explicit; see :ToolsInstall
        start_delay = 0,
      })

      vim.api.nvim_create_user_command("ToolsInstall", function()
        if #wanted == 0 then
          vim.notify("Every tool is already provided by the environment", vim.log.levels.INFO, { title = "tools" })
          return
        end
        vim.notify("Installing via Mason: " .. table.concat(wanted, ", "), vim.log.levels.INFO, { title = "tools" })
        vim.cmd("MasonToolsInstall")
      end, { desc = "Install editor tools that devbox/nix does not provide" })
    end,
  },

  -- ── Tool inventory ──────────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    optional = true,
    config = function(_, opts)
      require("mason").setup(opts)

      vim.api.nvim_create_user_command("CheckTools", function()
        local groups = {
          ["C / C++ (embedded)"] = {
            "clangd",
            "clang-format",
            "clang-tidy",
            "include-what-you-use",
            "arm-none-eabi-gcc",
            "arm-none-eabi-gdb",
            "gdb",
          },
          ["Build / tasks"] = { "meson", "ninja", "just", "just-lsp", "mesonlsp", "cmake-language-server", "inv" },
          ["Rust"] = { "cargo", "rust-analyzer", "rustfmt", "clippy-driver" },
          ["Python / test"] = { "python", "ruff", "pytest", "robot", "robotidy", "robocop", "debugpy" },
          ["Docs"] = { "doc8", "sphinx-lint", "rstfmt", "markdownlint-cli2", "prettier", "marksman" },
          ["Coverage"] = { "gcovr", "lcov", "genhtml" },
          ["Quality"] = { "sonarlint-ls", "sonar-scanner", "shellcheck", "yamllint", "cmakelint", "hadolint" },
          ["Editor"] = { "tree-sitter", "lua-language-server", "stylua", "shfmt", "taplo" },
          ["Emulation / probe"] = { "renode", "JLinkGDBServerCLExe", "openocd" },
        }

        local order = {
          "C / C++ (embedded)",
          "Build / tasks",
          "Rust",
          "Python / test",
          "Docs",
          "Coverage",
          "Quality",
          "Editor",
          "Emulation / probe",
        }

        local lines = {
          "Environment:",
          "  devbox root:  " .. (vim.env.DEVBOX_PROJECT_ROOT or "(not in a devbox project)"),
          "  virtualenv:   " .. (vim.env.VIRTUAL_ENV or "(none)"),
          "",
        }

        local missing = 0
        for _, group in ipairs(order) do
          lines[#lines + 1] = group .. ":"
          for _, tool in ipairs(groups[group]) do
            local path = vim.fn.exepath(tool)
            local origin
            if path == "" then
              origin = "MISSING"
              missing = missing + 1
            elseif path:find("/.venv/", 1, true) then
              origin = "venv"
            elseif path:find("/.devbox/", 1, true) or path:find("/nix/store/", 1, true) then
              origin = "devbox"
            elseif path:find("/mason/", 1, true) then
              origin = "mason"
            else
              origin = "system"
            end
            lines[#lines + 1] = ("  %-24s %-8s %s"):format(tool, origin, path)
          end
          lines[#lines + 1] = ""
        end
        lines[#lines + 1] = ("%d tool(s) missing."):format(missing)

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        vim.bo[buf].bufhidden = "wipe"
        local width = math.min(110, math.floor(vim.o.columns * 0.9))
        local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.85))
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          border = "rounded",
          title = " Tool inventory ",
          title_pos = "center",
        })
        vim.wo[win].wrap = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
        vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
      end, { desc = "Show where every external tool resolves from" })
    end,
  },
}
