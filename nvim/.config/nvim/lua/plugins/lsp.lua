-- LSP configuration (LazyVim style - Updated for nvim 0.11+)
return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    opts = function()
      ---@class PluginLspOpts
      local ret = {
        -- options for vim.diagnostic.config()
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = "✘",
              [vim.diagnostic.severity.WARN] = "▲",
              [vim.diagnostic.severity.HINT] = "⚑",
              [vim.diagnostic.severity.INFO] = "»",
            },
          },
          float = {
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "if_many",
            header = "",
            prefix = "",
          },
        },
        -- Enable inlay hints (requires LSP server support)
        inlay_hints = {
          enabled = true,
          exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
        },
        -- Enable code lens (requires LSP server support)
        codelens = {
          enabled = false,
        },
        -- Enable folds (requires LSP server support)
        folds = {
          enabled = true,
        },
        -- add any global capabilities here
        capabilities = {
          textDocument = {
            semanticTokens = {
              dynamicRegistration = false,
              tokenTypes = {
                "namespace",
                "type", "class", "enum", "interface", "struct", "typeParameter",
                "parameter", "variable", "property", "enumMember", "event", "function",
                "method", "macro", "keyword", "modifier", "comment", "string", "number",
                "regexp", "operator",
              },
              tokenModifiers = {
                "declaration", "definition", "readonly", "static", "deprecated",
                "abstract", "async", "modification", "documentation", "defaultLibrary",
              },
              formats = { "relative" },
              requests = {
                range = true,
                full = {
                  delta = true,
                },
              },
            },
          },
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        -- options for vim.lsp.buf.format
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        -- LSP Server Settings
        ---@type table<string, vim.lsp.Config|boolean>
        servers = {
          lua_ls = {
            -- mason = false, -- set to false if you don't want this server to be installed with mason
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = "Replace",
                },
                doc = {
                  privateName = { "^_" },
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
          jsonls = {
            -- lazy-load schemastore when needed
            on_new_config = function(new_config)
              new_config.settings.json.schemas = new_config.settings.json.schemas or {}
              vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
            end,
            settings = {
              json = {
                format = {
                  enable = true,
                },
                validate = { enable = true },
              },
            },
          },
          yamlls = {
            -- Have to add this for yamlls to understand that we support line folding
            capabilities = {
              textDocument = {
                foldingRange = {
                  dynamicRegistration = false,
                  lineFoldingOnly = true,
                },
              },
            },
            -- lazy-load schemastore when needed
            on_new_config = function(new_config)
              new_config.settings.yaml.schemas = new_config.settings.yaml.schemas or {}
              vim.list_extend(new_config.settings.yaml.schemas, require("schemastore").yaml.schemas())
            end,
            settings = {
              redhat = { telemetry = { enabled = false } },
              yaml = {
                keyOrdering = false,
                format = {
                  enable = true,
                },
                validate = true,
                schemaStore = {
                  -- Must disable built-in schemaStore support to use
                  -- schemas from SchemaStore.nvim plugin
                  enable = false,
                  -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                  url = "",
                },
              },
            },
          },
        },
        -- you can do any additional lsp server setup here
        -- return true if you don't want this server to be setup with lspconfig
        ---@type table<string, fun(server:string, opts: vim.lsp.Config):boolean?>
        setup = {
          -- example to setup with typescript.nvim
          -- tsserver = function(_, opts)
          --   require("typescript").setup({ server = opts })
          --   return true
          -- end,
          -- Specify * to use this function as a fallback for any server
          -- ["*"] = function(server, opts) end,
        },
      }
      return ret
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
      -- Setup keymaps
      local function on_attach(client, buffer)
        -- LSP keymaps
        local keys = {
          { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
          { "gr", vim.lsp.buf.references, desc = "References" },
          { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
          { "gy", vim.lsp.buf.type_definition, desc = "Goto Type Definition" },
          { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
          { "K", vim.lsp.buf.hover, desc = "Hover" },
          { "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },
          { "<c-k>", vim.lsp.buf.signature_help, desc = "Signature Help", mode = "i" },
          { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
          { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" } },
          { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh Codelens" },
          { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
        }

        -- Enhanced keymaps with fzf-lua if available
        local has_fzf, fzf = pcall(require, "fzf-lua")
        if has_fzf then
          keys[2] = { "gr", fzf.lsp_references, desc = "References (FZF)" }
          keys[1] = { "gd", fzf.lsp_definitions, desc = "Definitions (FZF)" }
          keys[3] = { "gI", fzf.lsp_implementations, desc = "Implementations (FZF)" }
          keys[4] = { "gy", fzf.lsp_typedefs, desc = "Type Definitions (FZF)" }
          vim.keymap.set("n", "<leader>ds", fzf.lsp_document_symbols, { buffer = buffer, desc = "Document Symbols" })
          vim.keymap.set("n", "<leader>ws", fzf.lsp_workspace_symbols, { buffer = buffer, desc = "Workspace Symbols" })
        end

        for _, key in pairs(keys) do
          local opts_key = { buffer = buffer, desc = key.desc, silent = true }
          if key.mode then
            vim.keymap.set(key.mode, key[1], key[2], opts_key)
          else
            vim.keymap.set("n", key[1], key[2], opts_key)
          end
        end
      end

      -- inlay hints
      if opts.inlay_hints.enabled then
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local buffer = args.buf ---@type number
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client:supports_method("textDocument/inlayHint") then
              if
                vim.api.nvim_buf_is_valid(buffer)
                and vim.bo[buffer].buftype == ""
                and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
              then
                vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
              end
            end
          end,
        })
      end

      -- folds
      if opts.folds.enabled then
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client:supports_method("textDocument/foldingRange") then
              vim.wo.foldmethod = "expr"
              vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
            end
          end,
        })
      end

      -- code lens
      if opts.codelens.enabled and vim.lsp.codelens then
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local buffer = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client:supports_method("textDocument/codeLens") then
              vim.lsp.codelens.refresh()
              vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                buffer = buffer,
                callback = vim.lsp.codelens.refresh,
              })
            end
          end,
        })
      end

      -- diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      if opts.capabilities then
        vim.lsp.config("*", { capabilities = opts.capabilities })
      end

      -- Get all the servers that are available through mason-lspconfig
      local have_mason = pcall(require, "mason-lspconfig")
      local mason_all = {}
      if have_mason then
        local ok, mappings = pcall(require, "mason-lspconfig.mappings")
        if ok and mappings.get_mason_map then
          mason_all = vim.tbl_keys(mappings.get_mason_map().lspconfig_to_package) or {}
        end
      end
      local mason_exclude = {} ---@type string[]

      ---@return boolean? exclude automatic setup
      local function configure(server)
        local sopts = opts.servers[server]
        sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts

        if sopts.enabled == false then
          mason_exclude[#mason_exclude + 1] = server
          return
        end

        local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)

        local setup = opts.setup[server] or opts.setup["*"]
        if setup and setup(server, sopts) then
          mason_exclude[#mason_exclude + 1] = server
        else
          vim.lsp.config(server, sopts) -- configure the server using new API
          if not use_mason then
            vim.lsp.enable(server)
          end
        end
        return use_mason
      end

      -- Setup on_attach for all servers
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          on_attach(client, buffer)
        end,
      })

      local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
      if have_mason then
        require("mason-lspconfig").setup({
          ensure_installed = install,
          automatic_enable = { exclude = mason_exclude },
        })
      end
    end,
  },

  -- cmdline tools and lsp servers
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          vim.api.nvim_exec_autocmds("FileType", {
            buffer = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() and not p:is_installing() then
            p:install()
          end
        end
      end)
    end,
  },
}