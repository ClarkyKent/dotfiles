return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    -- Was eagerly loaded (no lazy trigger), costing ~300ms of every startup
    -- even when opening no file at all. Server registration only needs to
    -- happen before the first real buffer is read.
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "LspInfo", "LspStart", "LspRestart", "LspMissing" },
    dependencies = {
      "williamboman/mason.nvim",
      "saghen/blink.cmp",
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    opts = {
      -- Options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = function(diagnostic)
            local icons = require("config.icons").diagnostics
            local severity = vim.diagnostic.severity
            local map = {
              [severity.ERROR] = icons.Error,
              [severity.WARN] = icons.Warn,
              [severity.HINT] = icons.Hint,
              [severity.INFO] = icons.Info,
            }
            return map[diagnostic.severity] or "●"
          end,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = require("config.icons").diagnostics.Error,
            [vim.diagnostic.severity.WARN] = require("config.icons").diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = require("config.icons").diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = require("config.icons").diagnostics.Info,
          },
        },
        float = {
          focused = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      },
      -- LSP Server Settings
      servers = {
        lua_ls = {
          cmd = { "lua-language-server" },
          filetypes = { "lua" },
          root_markers = {
            ".luarc.json",
            ".luarc.jsonc",
            ".luacheckrc",
            ".stylua.toml",
            "stylua.toml",
            "selene.toml",
            "selene.yml",
            ".git",
          },
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
          root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", "Makefile", "meson.build", ".git" },
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--pch-storage=memory",
            "--all-scopes-completion",
            "--pretty",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
            -- Fallback clang-tidy checks when .clang-tidy doesn't exist
            fallbackFlags = { "-Wall", "-Wextra", "-Wpedantic" },
          },
        },
        bashls = {
          cmd = { "bash-language-server", "start" },
          filetypes = { "sh", "bash" },
          root_markers = { ".git" },
        },
        dockerls = {
          cmd = { "docker-langserver", "--stdio" },
          filetypes = { "dockerfile" },
          root_markers = { "Dockerfile", ".git" },
        },
        jsonls = {
          cmd = { "vscode-json-language-server", "--stdio" },
          filetypes = { "json", "jsonc" },
          root_markers = { ".git" },
        },
        yamlls = {
          cmd = { "yaml-language-server", "--stdio" },
          filetypes = { "yaml", "yaml.docker-compose" },
          root_markers = { ".git" },
          settings = {
            yaml = {
              schemas = {
                ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = "azure-pipelines.yml",
              },
            },
          },
        },
        -- CMake is used for *parsing* only: some submodules ship
        -- CMakeLists.txt, but nothing here is built with CMake.
        cmake = {
          cmd = { "cmake-language-server" },
          filetypes = { "cmake" },
          root_markers = { "CMakeLists.txt", ".git" },
        },
        marksman = {
          cmd = { "marksman", "server" },
          filetypes = { "markdown" },
          root_markers = { ".marksman.toml", ".git" },
        },
        rust_analyzer = {
          cmd = { "rust-analyzer" },
          filetypes = { "rust" },
          root_markers = { "Cargo.toml", "rust-project.json", ".git" },
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- `checkOnSave` is a boolean in current rust-analyzer. The
              -- command/args moved to `check.*`; passing a table here is the
              -- pre-2023 shape and is rejected.
              checkOnSave = true,
              check = {
                command = "clippy",
                allTargets = true,
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
              inlayHints = {
                bindingModeHints = { enable = false },
                closureReturnTypeHints = { enable = "with_block" },
                lifetimeElisionHints = { enable = "skip_trivial" },
                parameterHints = { enable = true },
                typeHints = { enable = true },
              },
            },
          },
        },
        -- Python.
        --
        -- This project family standardises on ruff (declared in
        -- pyproject.toml); pyright is not provisioned anywhere. `ruff server`
        -- supplies diagnostics, code actions, import organisation and
        -- formatting from the exact ruff pinned by the project's .venv.
        --
        -- basedpyright is enabled opportunistically for type checking when it
        -- happens to be available -- ruff does not do type inference.
        ruff = {
          cmd = { "ruff", "server" },
          filetypes = { "python" },
          root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", "uv.lock", ".git" },
          init_options = {
            settings = { lineLength = 100 },
          },
        },
        basedpyright = {
          cmd = { "basedpyright-langserver", "--stdio" },
          filetypes = { "python" },
          root_markers = {
            "pyproject.toml",
            "uv.lock",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "pyrightconfig.json",
            ".git",
          },
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "standard",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticSeverityOverrides = {
                  -- ruff already reports these; avoid duplicate diagnostics.
                  reportUnusedImport = "none",
                  reportUnusedVariable = "none",
                },
              },
            },
          },
        },
        mesonlsp = {
          cmd = { "mesonlsp", "--lsp" },
          filetypes = { "meson" },
          root_markers = { "meson.build", "meson_options.txt", "meson.options", ".git" },
        },
        -- `just` is the primary task interface for this project (24KB .justfile)
        -- and devbox already ships just-lsp.
        just = {
          cmd = { "just-lsp" },
          filetypes = { "just" },
          root_markers = { ".justfile", "justfile", ".git" },
        },
        -- Robot Framework language server (robotframework-lsp).
        robotframework_ls = {
          cmd = { "robotframework_ls" },
          filetypes = { "robot", "resource" },
          root_markers = { "robot.yaml", "red.yaml", "pyproject.toml", ".git" },
          init_options = {
            settings = {
              robot = {
                -- Resolve libraries from the project virtualenv.
                python = {
                  executable = (function()
                    if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
                      return vim.env.VIRTUAL_ENV .. "/bin/python"
                    end
                    return vim.fn.exepath("python3")
                  end)(),
                },
                lint = { robocop = { enabled = true } },
              },
            },
          },
        },
      },
      setup = {
        -- Let lspconfig handle clangd normally, clangd_extensions will enhance it
      },
    },
    config = function(_, opts)
      -- Apply diagnostic options
      if opts.diagnostics then
        vim.diagnostic.config(opts.diagnostics)
      end

      -- Mason is the *fallback* provider. Tools coming from devbox/nix or the
      -- project's .venv are already on PATH (see lua/config/env.lua, which
      -- runs before lazy.nvim), so Mason's bin directory is appended, not
      -- prepended -- otherwise a stale Mason binary would shadow the exact
      -- version the project pins.
      require("mason").setup()
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
      if not string.find(vim.env.PATH or "", mason_bin, 1, true) then
        vim.env.PATH = (vim.env.PATH or "") .. ":" .. mason_bin
      end

      local servers = opts.servers
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Note: LSP keymaps are handled via LspAttach autocmd in lua/config/autocmds.lua

      local skipped = {}

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        -- Do not enable a server whose executable is absent. Previously every
        -- configured server was enabled unconditionally, so a dozen missing
        -- binaries produced spurious "server exited" errors on every buffer.
        local cmd = server_opts.cmd
        if type(cmd) == "table" and cmd[1] and vim.fn.executable(cmd[1]) == 0 then
          skipped[#skipped + 1] = ("%s (%s)"):format(server, cmd[1])
          return
        end

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end

        -- vim.lsp.config / vim.lsp.enable: the Neovim 0.11+ API
        vim.lsp.config(server, server_opts)
        vim.lsp.enable(server)
      end

      for server_name, _ in pairs(servers) do
        setup(server_name)
      end

      vim.api.nvim_create_user_command("LspMissing", function()
        if #skipped == 0 then
          vim.notify("All configured language servers are available", vim.log.levels.INFO, { title = "LSP" })
        else
          table.sort(skipped)
          vim.notify(
            "Language servers not found on PATH:\n  "
              .. table.concat(skipped, "\n  ")
              .. "\n\nProvide them via devbox/nix, or :MasonInstall them.",
            vim.log.levels.WARN,
            { title = "LSP" }
          )
        end
      end, { desc = "List configured language servers that are not installed" })

      -- Enable inlay hints if supported
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })

      -- Native LSP folding
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.foldmethod = "expr"
      vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
    end,
  },

  -- Mason
  -- NOTE: `ensure_installed` is NOT a mason.nvim option -- it was silently
  -- ignored here for as long as it existed. Tool provisioning is handled by
  -- mason-tool-installer in lua/plugins/tooling.lua, which only installs what
  -- devbox/nix does not already provide.
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {},
  },

  -- C/C++ clangd extras: AST inspection, symbol info, source/header switch.
  -- NOTE: the `inlay_hints` section this plugin used to provide is dead code
  -- since Neovim gained native inlay hints -- those are enabled from the
  -- LspAttach handler above. Only the clangd-specific LSP extensions remain.
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    keys = {
      { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header", ft = { "c", "cpp" } },
      { "<leader>cS", "<cmd>ClangdSymbolInfo<cr>", desc = "Symbol Info (clangd)", ft = { "c", "cpp" } },
      { "<leader>cT", "<cmd>ClangdTypeHierarchy<cr>", desc = "Type Hierarchy (clangd)", ft = { "c", "cpp" } },
      { "<leader>cw", "<cmd>ClangdAST<cr>", desc = "View AST (clangd)", ft = { "c", "cpp" } },
    },
    opts = {
      ast = {
        role_icons = {
          type = "",
          declaration = "",
          expression = "",
          specifier = "",
          statement = "",
          ["template argument"] = "",
        },
        kind_icons = {
          Compound = "",
          Recovery = "",
          TranslationUnit = "",
          PackExpansion = "",
          TemplateTypeParm = "",
          TemplateTemplateParm = "",
          TemplateParamObject = "",
        },
      },
    },
    config = function(_, opts)
      require("clangd_extensions").setup(opts)
    end,
  },
}
