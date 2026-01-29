return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
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
      -- Enable this to show formatters used in a notification
      -- Useful for debugging formatter issues
      format_notify = false,
      -- Automatic formatting is handled by conform.nvim
      
      -- LSP Server Settings
      servers = {
        lua_ls = {
          cmd = { "lua-language-server" },
          filetypes = { "lua" },
          root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
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
        robotframework_ls = {
          cmd = { "robotframework_ls" },
          filetypes = { "robot", "resource" },
          root_markers = { ".git", "robot.yaml" },
        },
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
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
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
            },
          },
        },
        pyright = {
          cmd = { "pyright-langserver", "--stdio" },
          filetypes = { "python" },
          root_markers = { "pyproject.toml", "uv.lock", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
        },
        mesonlsp = {
          cmd = { "mesonlsp", "--lsp" },
          filetypes = { "meson" },
          root_markers = { "meson.build", "meson_options.txt", "meson.options", ".git" },
        },
        esbonio = {
          cmd = { "esbonio" },
          filetypes = { "rst" },
          root_markers = { "conf.py", "setup.py", "pyproject.toml", ".git" },
          settings = {
            esbonio = {
              sphinx = {
                buildDir = "${workspaceRoot}/_build",
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

      -- Setup Mason first
      require("mason").setup()

      -- Ensure Mason bin is in PATH
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
      if not string.find(vim.env.PATH or "", mason_bin) then
        vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
      end
      
      -- Note: Automatic installation via Mason is disabled per user preference.
      -- Packages should be provided by the environment (devbox/nix) or installed manually.

      -- Setup Servers
      local servers = opts.servers
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Note: LSP keymaps are handled via LspAttach autocmd in lua/config/autocmds.lua

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end

        -- Use vim.lsp.config API for nvim 0.11+
        vim.lsp.config(server, server_opts)
        vim.lsp.enable(server)
      end

      -- Setup all configured servers
      for server_name, _ in pairs(servers) do
        setup(server_name)
      end

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
      if vim.fn.has("nvim-0.10") == 1 then
        vim.o.foldmethod = "expr"
        vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
      else
        vim.o.foldmethod = "indent"
      end
    end,
  },

  -- Mason
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
  },

  -- C/C++ Extensions (inlay hints, code lens, etc.)
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    opts = {
      inlay_hints = {
        inline = vim.fn.has("nvim-0.10") == 1,
        only_current_line = false,
        only_current_line_autocmd = { "CursorHold" },
        show_parameter_hints = true,
        parameter_hints_prefix = "<- ",
        other_hints_prefix = "=> ",
        max_len_align = false,
        max_len_align_padding = 1,
        right_align = false,
        right_align_padding = 7,
        highlight = "Comment",
        priority = 100,
      },
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

      -- Enable inlay hints automatically
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "clangd" then
            -- Enable inlay hints if supported
            if vim.lsp.inlay_hint then
              vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
            end
          end
        end,
      })

      -- Default config file templates
      local default_clangd = [[
CompileFlags:
  Add:
    - -Wall
    - -Wextra
    - -Wpedantic
  Compiler: clang

Diagnostics:
  ClangTidy:
    Add:
      - bugprone-*
      - modernize-*
      - performance-*
      - readability-*
    Remove:
      - modernize-use-trailing-return-type
      - readability-identifier-length
  UnusedIncludes: Strict

InlayHints:
  Enabled: Yes
  ParameterNames: Yes
  DeducedTypes: Yes
]]

      local default_clang_tidy = [[
Checks: >
  -*,
  bugprone-*,
  modernize-*,
  performance-*,
  readability-*,
  -modernize-use-trailing-return-type,
  -readability-identifier-length

WarningsAsErrors: ''
HeaderFilterRegex: '.*'
FormatStyle: file
]]

      local default_clang_format = [[
BasedOnStyle: LLVM
IndentWidth: 4
TabWidth: 4
UseTab: Never
ColumnLimit: 100
AccessModifierOffset: -4
AlignAfterOpenBracket: Align
AlignConsecutiveAssignments: false
AlignConsecutiveDeclarations: false
AlignOperands: true
AlignTrailingComments: true
AllowAllParametersOfDeclarationOnNextLine: true
AllowShortBlocksOnASingleLine: false
AllowShortCaseLabelsOnASingleLine: false
AllowShortFunctionsOnASingleLine: Empty
AllowShortIfStatementsOnASingleLine: false
AllowShortLoopsOnASingleLine: false
AlwaysBreakAfterReturnType: None
AlwaysBreakBeforeMultilineStrings: false
AlwaysBreakTemplateDeclarations: Yes
BinPackArguments: true
BinPackParameters: true
BreakBeforeBinaryOperators: None
BreakBeforeBraces: Attach
BreakBeforeTernaryOperators: true
BreakConstructorInitializers: BeforeColon
BreakStringLiterals: true
Cpp11BracedListStyle: true
DerivePointerAlignment: false
IncludeBlocks: Regroup
IndentCaseLabels: true
IndentPPDirectives: AfterHash
KeepEmptyLinesAtTheStartOfBlocks: false
MaxEmptyLinesToKeep: 1
NamespaceIndentation: None
PointerAlignment: Left
ReflowComments: true
SortIncludes: true
SortUsingDeclarations: true
SpaceAfterCStyleCast: false
SpaceAfterLogicalNot: false
SpaceAfterTemplateKeyword: true
SpaceBeforeAssignmentOperators: true
SpaceBeforeCpp11BracedList: false
SpaceBeforeCtorInitializerColon: true
SpaceBeforeInheritanceColon: true
SpaceBeforeParens: ControlStatements
SpaceBeforeRangeBasedForLoopColon: true
SpaceInEmptyParentheses: false
SpacesBeforeTrailingComments: 2
SpacesInAngles: false
SpacesInCStyleCastParentheses: false
SpacesInContainerLiterals: false
SpacesInParentheses: false
SpacesInSquareBrackets: false
Standard: c++17
]]

      -- Command to generate default C/C++ config files
      vim.api.nvim_create_user_command("ClangdConfigInit", function()
        local root = vim.fn.getcwd()
        local files = {
          { name = ".clangd", content = default_clangd },
          { name = ".clang-tidy", content = default_clang_tidy },
          { name = ".clang-format", content = default_clang_format },
        }

        for _, file in ipairs(files) do
          local path = root .. "/" .. file.name
          if vim.fn.filereadable(path) == 0 then
            local f = io.open(path, "w")
            if f then
              f:write(file.content)
              f:close()
              vim.notify("Created " .. file.name, vim.log.levels.INFO)
            end
          else
            vim.notify(file.name .. " already exists, skipping", vim.log.levels.WARN)
          end
        end
        vim.notify("Run :LspRestart to apply new config", vim.log.levels.INFO)
      end, { desc = "Initialize default clangd config files (.clangd, .clang-tidy, .clang-format)" })
    end,
  },
}
