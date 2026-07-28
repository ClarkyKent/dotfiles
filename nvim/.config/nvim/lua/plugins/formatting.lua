-- Formatting (conform.nvim)
--
-- Tool resolution order is deliberate: project virtualenv -> devbox/nix on
-- PATH -> Mason. `lua/config/env.lua` guarantees the devbox environment is
-- loaded before any of this runs.

---Find a binary inside a local venv, falling back to PATH.
---@param ctx table conform context
---@param bin string
---@return string
local function venv_bin(ctx, bin)
  if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
    local candidate = vim.env.VIRTUAL_ENV .. "/bin/" .. bin
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  for _, root in ipairs({ ".venv", "venv", "env" }) do
    local venv = vim.fn.finddir(root, (ctx and ctx.dirname or vim.fn.getcwd()) .. ";")
    if venv ~= "" then
      local candidate = venv .. "/bin/" .. bin
      if vim.fn.executable(candidate) == 1 then
        return candidate
      end
    end
  end
  return bin
end

return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    -- stylua: ignore
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, mode = { "n", "v" }, desc = "Format buffer/selection" },
      { "<leader>cF", function() require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 }) end, mode = { "n", "v" }, desc = "Format injected langs" },
      { "<leader>uf", function() require("config.format").toggle() end, desc = "Toggle format-on-save (global)" },
      { "<leader>uF", function() require("config.format").toggle(true) end, desc = "Toggle format-on-save (buffer)" },
    },
    opts = {
      -- format_on_save is a function so it can be toggled at runtime and can
      -- bail out on very large generated files. Previously it was an
      -- unconditional 3s blocking write hook with no escape hatch.
      format_on_save = function(bufnr)
        if not require("config.format").enabled(bufnr) then
          return nil
        end
        -- Meson `configure_file` templates are not valid C; clang-format
        -- mangles them. VS Code disables formatting on these too.
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name:match("%.h%.in$") or name:match("%.in$") then
          return nil
        end
        if vim.api.nvim_buf_line_count(bufnr) > 20000 then
          return nil
        end
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        python = { "ruff_format", "ruff_organize_imports" },
        rust = { "rustfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        cmake = { "cmake_format" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        toml = { "taplo" },
        meson = { "meson_format", lsp_format = "fallback" },
        just = { "just_format" },
        -- Sphinx docs: rstfmt is declared in the project's pyproject.toml.
        rst = { "rstfmt" },
        robot = { "robotidy" },
        ["_"] = { "trim_whitespace" },
      },
      formatters = {
        injected = { options = { ignore_errors = true } },

        ["clang-format"] = {
          -- --style=file makes clang-format honour the project's
          -- .clang-format, which every repo here provides.
          prepend_args = { "--style=file" },
        },

        meson_format = {
          command = function(_, ctx)
            return venv_bin(ctx, "meson")
          end,
          args = function(_, ctx)
            local args = { "format", "-i", "-e" }
            local config_file = vim.fn.findfile("meson.format", ctx.dirname .. ";")
            if config_file ~= "" then
              table.insert(args, "-c")
              table.insert(args, config_file)
            end
            table.insert(args, "$FILENAME")
            return args
          end,
          stdin = false,
          tempfile_format = ".XXXXXX.meson.build",
        },

        -- devbox ships just-formatter; `just --fmt` is the official entrypoint.
        just_format = {
          command = "just",
          args = { "--unstable", "--fmt", "--justfile", "$FILENAME" },
          stdin = false,
        },

        ruff_format = {
          command = function(_, ctx)
            return venv_bin(ctx, "ruff")
          end,
        },
        ruff_organize_imports = {
          command = function(_, ctx)
            return venv_bin(ctx, "ruff")
          end,
        },

        rstfmt = {
          command = function(_, ctx)
            return venv_bin(ctx, "rstfmt")
          end,
          args = { "--line-length", "100" },
          stdin = true,
        },

        -- Robotidy ships with robotframework-tidy; resolved from the venv.
        robotidy = {
          command = function(_, ctx)
            return venv_bin(ctx, "robotidy")
          end,
          args = { "--no-overwrite", "-" },
          stdin = true,
        },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
