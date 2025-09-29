-- Enhanced treesitter configuration with context, textobjects, and refactor
return {
  -- Main treesitter plugin
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    build = ":TSUpdate",
    lazy = vim.fn.argc(-1) == 0,
    event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSInfo", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    opts_extend = { "ensure_installed" },
    opts = {
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        use_languagetree = true,
      },
      indent = { enable = true },
      auto_install = true,
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "cmake",
        "cuda",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "make",
        "markdown",
        "markdown_inline",
        "meson",
        "objc",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      
      -- Textobjects configuration
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",
            ["a/"] = "@comment.outer",
            ["i/"] = "@comment.inner",
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            ["as"] = "@statement.outer",
            ["is"] = "@scopename.inner",
            ["aS"] = "@scope.outer",
            ["iS"] = "@scope.inner",
          },
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },
          include_surrounding_whitespace = true,
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.inner",
            ["]o"] = "@loop.*",
            ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
            ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]A"] = "@parameter.inner",
            ["]O"] = "@loop.*",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.inner",
            ["[o"] = "@loop.*",
            ["[s"] = { query = "@scope", query_group = "locals", desc = "Previous scope" },
            ["[z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[A"] = "@parameter.inner",
            ["[O"] = "@loop.*",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
          },
        },
        lsp_interop = {
          enable = true,
          border = 'none',
          floating_preview_opts = {},
          peek_definition_code = {
            ["<leader>df"] = "@function.outer",
            ["<leader>dF"] = "@class.outer",
          },
        },
      },

      -- Refactor configurations
      refactor = {
        highlight_definitions = {
          enable = true,
          clear_on_cursor_move = true,
        },
        highlight_current_scope = { enable = true },
        smart_rename = {
          enable = true,
          keymaps = {
            smart_rename = "grr",
          },
        },
        navigation = {
          enable = true,
          keymaps = {
            goto_definition = "gnd",
            list_definitions = "gnD",
            list_definitions_toc = "gO",
            goto_next_usage = "<a-*>",
            goto_previous_usage = "<a-#>",
          },
        },
      },

      -- Incremental selection
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- Treesitter textobjects for enhanced text manipulation
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    dependencies = "nvim-treesitter/nvim-treesitter",
    -- Remove the custom config function that's causing issues
    -- The textobjects configuration is handled in the main treesitter config above
  },

  -- Treesitter context for showing current scope
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {
      enable = true,
      max_lines = 3,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = "outer",
      mode = "cursor",  -- Line used to calculate context. Choices: 'cursor', 'topline'
      separator = nil,
      zindex = 20,
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },
    keys = {
      {
        "<leader>tc",
        function()
          local tsc = require("treesitter-context")
          tsc.toggle()
        end,
        desc = "Toggle Treesitter Context",
      },
    },
  },

  -- Treesitter refactor module
  {
    "nvim-treesitter/nvim-treesitter-refactor",
    event = "VeryLazy",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },

  -- Show current function context in winbar/statusline
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    opts = {
      separator = " ",
      highlight = true,
      depth_limit = 5,
      lazy_update_context = true,
    },
  },

  -- Enhanced syntax highlighting for C/C++
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    opts = {
      inlay_hints = {
        inline = false,
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
  },

  -- Automatically add closing tags for HTML and JSX
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}