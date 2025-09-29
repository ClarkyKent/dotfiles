-- LazyVim-style clangd configuration for C/C++ development
return {
  -- clangd extensions for enhanced functionality
  {
    "p00f/clangd_extensions.nvim",
    lazy = true,
    config = function() end,
    opts = {
      inlay_hints = {
        inline = false,
      },
      ast = {
        -- These require codicons (https://github.com/microsoft/vscode-codicons)
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
  },

  -- Correctly setup lspconfig for clangd 🚀
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Ensure servers table exists
      opts.servers = opts.servers or {}
      
      -- Add clangd server configuration
      opts.servers.clangd = {
        keys = {
          { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
        },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern(
            "compile_commands.json",
            "compile_flags.txt",
            "configure.ac", -- AutoTools
            "Makefile",
            "configure.ac",
            "configure.in",
            "config.h.in",
            "meson.build",
            "meson_options.txt",
            "build.ninja",
            ".git"
          )(fname)
        end,
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
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      }

      -- Ensure setup table exists
      opts.setup = opts.setup or {}
      
      -- Add clangd setup function
      opts.setup.clangd = function(_, server_opts)
        local has_clangd_ext, clangd_ext = pcall(require, "clangd_extensions")
        if has_clangd_ext then
          clangd_ext.setup(vim.tbl_deep_extend("force", {}, { server = server_opts }))
          return false -- Don't use default lspconfig setup
        end
        return true -- Use default setup if clangd_extensions not available
      end
    end,
  },

  -- Enhanced blink.cmp integration for clangd
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      -- Add clangd-specific completion scoring if available
      local has_clangd_ext, clangd_ext = pcall(require, "clangd_extensions")
      if has_clangd_ext and clangd_ext.cmp_scores then
        opts.sources = opts.sources or {}
        opts.sources.providers = opts.sources.providers or {}
        
        -- Add clangd-specific provider configuration
        opts.sources.providers.clangd = {
          name = "clangd",
          module = "blink.cmp.sources.lsp",
          score_offset = 100, -- Prioritize clangd completions
        }
      end
    end,
  },

  -- Add Mason configuration to ensure clangd is installed
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "clangd" })
    end,
  },

  -- Optional: DAP configuration for C/C++ debugging
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "codelldb" })
        end,
      },
    },
    opts = function()
      local dap = require("dap")
      
      -- Configure codelldb adapter if not already configured
      if not dap.adapters["codelldb"] then
        dap.adapters["codelldb"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "codelldb",
            args = {
              "--port",
              "${port}",
            },
          },
        }
      end
      
      -- Configure debug configurations for C/C++
      for _, lang in ipairs({ "c", "cpp" }) do
        dap.configurations[lang] = {
          {
            type = "codelldb",
            request = "launch",
            name = "Launch file",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
          },
          {
            type = "codelldb",
            request = "attach",
            name = "Attach to process",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },
}