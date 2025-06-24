local icons = require('utils.icons').diagnostics


return {
  {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim

      "williamboman/mason-lspconfig.nvim",

      -- Useful status updates for LSP.
      -- LSP and notify updates in the down right corner
      {
        "j-hui/fidget.nvim",
        opts = {
          notification = {
            override_vim_notify = true,
          },
        },
      },

      -- Allows extra capabilities provided by nvim-cmp
      "saghen/blink.cmp",
    },
    config = function()


      -- Make hover window have borders
      local floating_border_style = "rounded"

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = floating_border_style,
      })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = floating_border_style,
      })

      vim.diagnostic.config({
        float = { border = floating_border_style },
      })

      -- Show window/showMessage requests using vim.notify instead of logging to messages
      vim.lsp.handlers["window/showMessage"] = function(_, params, ctx)
        local message_type = params.type
        local message = params.message
        local client_id = ctx.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local client_name = client and client.name or string.format("id=%d", client_id)
        if not client then
          vim.notify("LSP[" .. client_name .. "] client has shut down after sending " .. message, vim.log.levels.ERROR)
        end
        if message_type == vim.lsp.protocol.MessageType.Error then
          vim.notify("LSP[" .. client_name .. "] " .. message, vim.log.levels.ERROR)
        else
          message = ("LSP[%s][%s] %s\n"):format(client_name, vim.lsp.protocol.MessageType[message_type], message)
          vim.notify(message, vim.log.levels[message_type])
        end
        return params
      end

      -- Change diagnostic symbols in the sign column (gutter)
      local signs = { ERROR = icons.Error , WARN = icons.Warning, INFO = icons.Information, HINT = icons.Hint }
      local diagnostic_signs = {}
      for type, icon in pairs(signs) do
        diagnostic_signs[vim.diagnostic.severity[type]] = icon
      end
      vim.diagnostic.config({ signs = { text = diagnostic_signs } })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, blink_capabilities)

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        clangd = {
        keys = {
          { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
        },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern(
            "Makefile",
            "configure.ac",
            "configure.in",
            "config.h.in",
            "meson.build",
            "meson_options.txt",
            "meson.options",
            "build.ninja"
          )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
            fname
          ) or require("lspconfig.util").find_git_ancestor(fname)
        end,
        capabilities = {
          offsetEncoding = { "utf-16" },
        },
        -- cmd = {
        --   "clangd",
        --   "--background-index",
        --   "--clang-tidy",
        --   "--header-insertion=iwyu",
        --   "--completion-style=detailed",
        --   "--function-arg-placeholders",
        --   "--fallback-style=llvm",
        -- },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      },
        -- gopls = {},
        pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},
        --

        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              diagnostics = { disable = { "missing-fields" } },
            },
          },
        },
        -- Markdown
        marksman = {},
        -- TypeScript, JavaScript
        ts_ls = {},
        -- TOML
        taplo = {},
        -- PHP
        -- intelephense = {},
        phpactor = {},
        -- Bash/Shell
        shellcheck = {},
        bashls = {},
        -- Docker
        dockerls = {},
        docker_compose_language_service = {},
        -- Helm
        helm_ls = {},
        yamlls = {
          -- FIXME: yamlls produces a lot of false positives for helm files
          -- due to template syntax at the moment. It is loaded nevertheless.
          -- Therefore we need to ensure it is not attached for those files
          filetypes = { "yaml" },
          on_attach = function(client, bufnr)
            local patterns = { "*/templates/*.yaml", "*/templates/*.tpl", "values.yaml", "Chart.yaml" }
            local fname = vim.fn.expand("%:p")
            for _, pattern in ipairs(patterns) do
              local lua_pattern = pattern:gsub("*", ".*"):gsub("/", "/.*")
              if fname:match(lua_pattern) then
                vim.lsp.buf_detach_client(bufnr, client.id)
                return
              end
            end
          end,
        },
        jsonls = {},
        tailwindcss = {},

        -- Rust
        -- Handled by rustacean.vim
        -- rust_analyzer = {},
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require("mason").setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua", -- Used to format Lua code
        "prettierd", -- Used to format JavaScript/TypeScript code
        "clang-format", -- Used to format C/C++ code
        "ruff", -- Used to format Python code
        "isort", -- Used to sort Python imports
        "black", -- Used to format Python code
        "clangd"
      })

      require("mason-tool-installer").setup({
        ensure_installed = ensure_installed,
      })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
        ensure_installed = {},
        automatic_installation = true,
      })
    end,
  },
}
