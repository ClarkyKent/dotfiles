-- Linting (nvim-lint)
--
-- Only linters that complement the LSP layer are configured here. In
-- particular Python is *not* linted by nvim-lint: `ruff server` already
-- provides those diagnostics with code actions, and running both produced
-- duplicate signs.

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        dockerfile = { "hadolint" },
        markdown = { "markdownlint-cli2" },
        -- Sphinx docs: both tools are declared in the project's pyproject.toml.
        rst = { "doc8", "sphinx-lint" },
        yaml = { "yamllint" },
        cmake = { "cmakelint" },
        robot = { "robocop" },
      },
      linters = {
        -- doc8 is not bundled with nvim-lint.
        doc8 = {
          cmd = "doc8",
          stdin = false,
          args = { "--quiet" },
          stream = "stdout",
          ignore_exitcode = true,
          parser = function(output, bufnr)
            local diagnostics = {}
            local fname = vim.api.nvim_buf_get_name(bufnr)
            for line in output:gmatch("[^\n]+") do
              local file, lnum, code, msg = line:match("^(.-):(%d+):%s+(D%d+)%s+(.*)$")
              if file and vim.fn.fnamemodify(file, ":p") == fname then
                diagnostics[#diagnostics + 1] = {
                  lnum = tonumber(lnum) - 1,
                  col = 0,
                  severity = vim.diagnostic.severity.WARN,
                  source = "doc8",
                  code = code,
                  message = msg,
                }
              end
            end
            return diagnostics
          end,
        },
        ["sphinx-lint"] = {
          cmd = "sphinx-lint",
          stdin = false,
          args = {},
          stream = "stdout",
          ignore_exitcode = true,
          parser = function(output, bufnr)
            local diagnostics = {}
            local fname = vim.api.nvim_buf_get_name(bufnr)
            for line in output:gmatch("[^\n]+") do
              local file, lnum, msg = line:match("^(.-):(%d+):%s+(.*)$")
              if file and vim.fn.fnamemodify(file, ":p") == fname then
                diagnostics[#diagnostics + 1] = {
                  lnum = tonumber(lnum) - 1,
                  col = 0,
                  severity = vim.diagnostic.severity.WARN,
                  source = "sphinx-lint",
                  message = msg,
                }
              end
            end
            return diagnostics
          end,
        },
        -- Robocop: Robot Framework static analysis.
        robocop = {
          cmd = "robocop",
          stdin = false,
          args = { "--format", "{source}:{line}:{col}:{severity}:{rule_id}:{desc}", "--no-recursive" },
          stream = "stdout",
          ignore_exitcode = true,
          parser = function(output, bufnr)
            local severities = {
              E = vim.diagnostic.severity.ERROR,
              W = vim.diagnostic.severity.WARN,
              I = vim.diagnostic.severity.INFO,
            }
            local diagnostics = {}
            local fname = vim.api.nvim_buf_get_name(bufnr)
            for line in output:gmatch("[^\n]+") do
              local file, lnum, col, sev, rule, msg = line:match("^(.-):(%d+):(%d+):(%a):(%S+):(.*)$")
              if file and vim.fn.fnamemodify(file, ":p") == fname then
                diagnostics[#diagnostics + 1] = {
                  lnum = tonumber(lnum) - 1,
                  col = tonumber(col) - 1,
                  severity = severities[sev] or vim.diagnostic.severity.WARN,
                  source = "robocop",
                  code = rule,
                  message = msg,
                }
              end
            end
            return diagnostics
          end,
        },
      },
    },
    config = function(_, opts)
      local lint = require("lint")

      for name, linter in pairs(opts.linters or {}) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      ---Resolve a linter binary from the project virtualenv first, so the
      ---pinned version is used rather than whatever happens to be on PATH.
      local VENV_TOOLS = { doc8 = true, ["sphinx-lint"] = true, robocop = true, ruff = true }
      local function resolve_venv(name, dirname)
        if not VENV_TOOLS[name] then
          return nil
        end
        if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
          local candidate = vim.env.VIRTUAL_ENV .. "/bin/" .. name
          if vim.fn.executable(candidate) == 1 then
            return candidate
          end
        end
        for _, root in ipairs({ ".venv", "venv", "env" }) do
          local venv = vim.fn.finddir(root, dirname .. ";")
          if venv ~= "" then
            local candidate = venv .. "/bin/" .. name
            if vim.fn.executable(candidate) == 1 then
              return candidate
            end
          end
        end
        return nil
      end

      local function debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      local function try_lint()
        if vim.bo.buftype ~= "" then
          return
        end
        local names = lint.linters_by_ft[vim.bo.filetype] or {}
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")

        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            return false
          end
          -- Prefer the project's pinned copy when there is one.
          local resolved = resolve_venv(name, ctx.dirname)
          if resolved and type(linter) == "table" then
            linter.cmd = resolved
          end
          local cmd = type(linter) == "table" and linter.cmd or linter
          if type(cmd) == "function" then
            cmd = cmd()
          end
          if vim.fn.executable(cmd) == 0 then
            return false -- silently skip: tool not provisioned in this env
          end
          return not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = debounce(150, try_lint),
      })

      vim.api.nvim_create_user_command("LintInfo", function()
        local names = lint.linters_by_ft[vim.bo.filetype] or {}
        if #names == 0 then
          vim.notify("No linters configured for " .. vim.bo.filetype, vim.log.levels.INFO, { title = "lint" })
          return
        end
        local lines = {}
        for _, name in ipairs(names) do
          local linter = lint.linters[name]
          local cmd = type(linter) == "table" and linter.cmd or name
          local path = vim.fn.exepath(cmd)
          lines[#lines + 1] = ("  %-18s %s"):format(name, path ~= "" and path or "NOT INSTALLED")
        end
        vim.notify("Linters for " .. vim.bo.filetype .. ":\n" .. table.concat(lines, "\n"), vim.log.levels.INFO, {
          title = "lint",
        })
      end, { desc = "Show linters configured for the current filetype" })

      vim.api.nvim_create_user_command("Lint", try_lint, { desc = "Lint the current buffer now" })
    end,
  },
}
