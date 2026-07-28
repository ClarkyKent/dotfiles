return {
  "https://gitlab.com/schrieveslaach/sonarlint.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  -- "js"/"ts" are not real Neovim filetypes; they matched nothing.
  ft = { "python", "c", "cpp", "java", "javascript", "typescript", "html", "php", "sh", "lua" },
  opts = function()
    -- Resolve the language server the same way everything else does:
    -- devbox/nix first (this project ships sonarlint-ls), Mason as fallback.
    local function resolve_server()
      local bin = vim.fn.exepath("sonarlint-ls")
      if bin ~= "" then
        return { cmd = { bin, "-stdio" }, kind = "binary" }
      end
      local jar = vim.fn.stdpath("data")
        .. "/mason/packages/sonarlint-language-server/extension/server/sonarlint-ls.jar"
      if vim.fn.filereadable(jar) == 1 and vim.fn.executable("java") == 1 then
        return { cmd = { "java", "-jar", jar, "-stdio" }, kind = "jar", jar = jar }
      end
      return nil
    end

    -- Parse a Java .properties file into a Lua table
    local function parse_properties(path)
      local props = {}
      local f = io.open(path, "r")
      if not f then
        return props
      end
      for line in f:lines() do
        -- Skip blank lines and comments (# or !)
        if not line:match("^%s*[#!]") and not line:match("^%s*$") then
          local k, v = line:match("^([^=]+)=(.*)$")
          if k then
            props[vim.trim(k)] = vim.trim(v)
          end
        end
      end
      f:close()
      return props
    end

    -- Walk up from cwd looking for the project's Sonar configuration.
    -- `sonar-project.properties` is the file SonarScanner actually uses;
    -- the previous code looked for `sonarlint-project.properties`, which
    -- does not exist in any of these repos.
    local props, props_file = {}, nil
    for _, name in ipairs({ "sonar-project.properties", "sonarlint-project.properties" }) do
      local found = vim.fs.find(name, { upward = true, path = vim.fn.getcwd(), type = "file" })[1]
      if found then
        props_file = found
        props = parse_properties(found)
        break
      end
    end

    -- Priority: properties file > env vars (.envrc exports these) > defaults
    local server_url = props["sonar.host.url"] or vim.env.SONAR_SERVER_URL or "https://sonarcloud.io"
    local token = props["sonar.token"] or vim.env.SONAR_TOKEN or ""
    local project_key = props["sonar.projectKey"]

    local connected_mode = {
      connections = {
        sonarqube = {
          {
            connectionId = "project",
            serverUrl = server_url,
            token = token,
          },
        },
      },
    }

    -- Only set project binding when projectKey is known
    if project_key then
      connected_mode.project = {
        connectionId = "project",
        projectKey = project_key,
      }
    end

    -- SonarLint cannot analyse C/C++ without a compilation database. VSCode
    -- sets this explicitly (`sonarlint.pathToCompileCommands`); we resolve it
    -- from the usual Meson/CMake build directories.
    local compile_commands
    for _, candidate in ipairs({
      "compile_commands.json",
      "_buildresults/compile_commands.json",
      "builddir/compile_commands.json",
      "build/compile_commands.json",
    }) do
      local found = vim.fs.find(candidate, { upward = true, path = vim.fn.getcwd(), type = "file" })[1]
        or (vim.fn.filereadable(vim.fn.getcwd() .. "/" .. candidate) == 1 and vim.fn.getcwd() .. "/" .. candidate)
      if found then
        compile_commands = vim.fn.fnamemodify(found, ":p")
        break
      end
    end

    local server = resolve_server()

    return {
      _resolved = server,
      _props_file = props_file,
      server = server and { cmd = server.cmd } or { cmd = {} },
      filetypes = { "python", "c", "cpp", "java", "javascript", "typescript", "html", "php", "sh", "lua" },
      settings = {
        sonarlint = {
          connectedMode = connected_mode,
          pathToCompileCommands = compile_commands,
        },
      },
    }
  end,

  config = function(_, opts)
    if not opts._resolved then
      vim.notify(
        "SonarLint server not found.\n"
          .. "Provide `sonarlint-ls` via devbox/nix, or run :MasonInstall sonarlint-language-server",
        vim.log.levels.WARN,
        { title = "SonarLint" }
      )
      return
    end

    if opts._props_file then
      vim.notify("SonarLint: loaded " .. opts._props_file, vim.log.levels.INFO, { title = "SonarLint" })
    end

    local scrubbed = vim.deepcopy(opts)
    scrubbed._resolved, scrubbed._props_file = nil, nil
    require("sonarlint").setup(scrubbed)

    -- Allow toggling SonarLint diagnostics without stopping the server.
    local original_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
    vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if client and client.name == "sonarlint" and _G._sonarlint_enabled == false then
        return
      end
      original_handler(err, result, ctx, config)
    end
  end,

  keys = {
    -- Was <leader>us, which collided with the spell-toggle in plugins/ui.lua.
    {
      "<leader>uq",
      function()
        require("config.util").toggle_sonarlint()
      end,
      desc = "Toggle SonarLint Diagnostics",
    },
  },
}
