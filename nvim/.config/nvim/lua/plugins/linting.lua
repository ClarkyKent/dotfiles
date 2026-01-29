return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        python = { "ruff" },
        sh = { "shellcheck" },
        dockerfile = { "hadolint" },
        markdown = { "markdownlint-cli2" },
        rst = { "rstcheck" },
        json = { "jsonlint" },
        yaml = { "yamllint" },
        cmake = { "cmakelint" },
      },
    },
    config = function(_, opts)
      local M = {}

      local lint = require("lint")
      for name, linter in pairs(opts.linters or {}) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      function M.debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      function M.lint()
        local names = lint.linters_by_ft[vim.bo.filetype] or {}
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            vim.notify("Linter not found: " .. name, vim.log.levels.WARN)
            return false
          end
          -- Check if the linter command is executable
          local cmd = type(linter) == "table" and linter.cmd or linter
          if vim.fn.executable(cmd) == 0 then
            return false
          end
          return not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        -- Dynamic resolution for ruff
        if vim.tbl_contains(names, "ruff") then
          local roots = { ".venv", "venv", "env" }
          local found_ruff = "ruff"
          for _, root in ipairs(roots) do
            local venv = vim.fn.finddir(root, ctx.dirname .. ";")
            if venv ~= "" then
              local candidate = venv .. "/bin/ruff"
              if vim.fn.executable(candidate) == 1 then
                found_ruff = candidate
                break
              end
            end
          end
          if lint.linters.ruff then
            lint.linters.ruff.cmd = found_ruff
          end
        end

        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = M.debounce(100, M.lint),
      })

      -- Command to generate default markdownlint-cli2 config
      vim.api.nvim_create_user_command("MarkdownlintInit", function()
        local root = vim.fn.getcwd()
        local file = ".markdownlint-cli2.yaml"
        local path = root .. "/" .. file
        local content = [[# .markdownlint-cli2.yaml
config:
  default: true
  line-length: false
  no-duplicate-heading: { siblings_only: true }
  no-inline-html: false

globs:
  - "**/*.md"
  - "!.git"
  - "!node_modules"
]]
        if vim.fn.filereadable(path) == 0 then
          local f = io.open(path, "w")
          if f then
            f:write(content)
            f:close()
            vim.notify("Created " .. file, vim.log.levels.INFO)
          end
        else
          vim.notify(file .. " already exists", vim.log.levels.WARN)
        end
      end, { desc = "Initialize default markdownlint-cli2 config" })
    end,
  },
}
