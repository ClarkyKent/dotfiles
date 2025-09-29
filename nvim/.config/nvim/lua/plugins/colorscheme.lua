-- Enhanced colorscheme configurations
return {
  -- Tokyo Night theme (current default)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "storm",
      on_highlights = function(highlights, colors)
        -- Enhanced C/C++ syntax highlighting
        highlights["@function.call"] = { fg = colors.blue }
        highlights["@function.builtin"] = { fg = colors.cyan }
        highlights["@function.method"] = { fg = colors.blue }
        highlights["@function.method.call"] = { fg = colors.blue }
        
        -- Variables and parameters
        highlights["@variable"] = { fg = colors.fg }
        highlights["@variable.builtin"] = { fg = colors.red }
        highlights["@variable.parameter"] = { fg = colors.orange }
        highlights["@variable.member"] = { fg = colors.green1 }
        
        -- Types and constants
        highlights["@type"] = { fg = colors.yellow }
        highlights["@type.builtin"] = { fg = colors.cyan }
        highlights["@constant"] = { fg = colors.orange }
        highlights["@constant.builtin"] = { fg = colors.red1 }
        
        -- Keywords and operators
        highlights["@keyword"] = { fg = colors.purple }
        highlights["@keyword.function"] = { fg = colors.magenta }
        highlights["@operator"] = { fg = colors.blue5 }
        
        -- Semantic tokens (LSP)
        highlights["@lsp.type.function"] = { fg = colors.blue }
        highlights["@lsp.type.method"] = { fg = colors.blue }
        highlights["@lsp.type.variable"] = { fg = colors.fg }
        highlights["@lsp.type.parameter"] = { fg = colors.orange }
        highlights["@lsp.type.property"] = { fg = colors.green1 }
        highlights["@lsp.type.macro"] = { fg = colors.cyan }
        highlights["@lsp.type.type"] = { fg = colors.yellow }
        highlights["@lsp.type.class"] = { fg = colors.yellow }
        highlights["@lsp.type.struct"] = { fg = colors.yellow }
        highlights["@lsp.type.enum"] = { fg = colors.yellow }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-storm")
    end,
  },

  -- AstroTheme: AstroNvim's official colorscheme
  {
    "AstroNvim/astrotheme",
    lazy = true,
    priority = 1000,
    opts = {
      palette = "astrodark", -- "astrodark" | "astrolight" | "astromars"
      
      background = {
        light = "astrolight",
        dark = "astrodark",
      },

      style = {
        transparent = false,         -- Bool value, toggles transparency.
        inactive = true,             -- Bool value, toggles inactive window color.
        float = true,                -- Bool value, toggles floating windows background colors.
        neotree = true,              -- Bool value, toggles neo-trees background color.
        border = true,               -- Bool value, toggles borders.
        title_invert = true,         -- Bool value, swaps text and background colors.
        italic_comments = true,      -- Bool value, toggles italic comments.
        simple_syntax_colors = true, -- Bool value, simplifies the amounts of colors used for syntax highlighting.
      },

      termguicolors = true,
      terminal_color = true,
      
      plugin_default = "auto", -- "auto" | true | false
      
      plugins = {
        -- Plugin-specific overrides
        ["dashboard-nvim"] = true,
        ["fzf"] = true,
        ["gitsigns"] = true,
        ["indent-blankline"] = true,
        ["lazy"] = true,
        ["lualine"] = true,
        ["mason"] = true,
        ["mini"] = true,
        ["neo-tree"] = true,
        ["noice"] = true,
        ["nvim-cmp"] = true,
        ["nvim-notify"] = true,
        ["nvim-tree"] = true,
        ["nvim-web-devicons"] = true,
        ["telescope"] = true,
        ["todo-comments"] = true,
        ["which-key"] = true,
        ["blink-cmp"] = true,
      },

      palettes = {
        global = {
          -- Custom global colors
          my_accent = "#FFAA00",
        },
        astrodark = {
          -- Extend astrodark palette
          ui = {
            accent = "#FFAA00", -- Custom accent color
          },
        },
        astrolight = {
          -- Extend astrolight palette  
          ui = {
            accent = "#FF6600", -- Custom accent for light theme
          },
        },
      },

      highlights = {
        global = {
          -- Global highlight overrides
          modify_hl_groups = function(hl, c)
            -- Enhanced C/C++ semantic highlighting
            hl["@function.call"] = { fg = c.syntax.func, bold = false }
            hl["@function.builtin"] = { fg = c.syntax.builtin, bold = true }
            hl["@variable.parameter"] = { fg = c.syntax.parameter, italic = true }
            hl["@variable.member"] = { fg = c.syntax.field }
            hl["@type.builtin"] = { fg = c.syntax.builtin, bold = true }
          end,
        },
        astrodark = {
          -- Specific overrides for astrodark theme
          modify_hl_groups = function(hl, c)
            hl.Comment = { fg = c.syntax.comment, italic = true }
            hl.Todo = { fg = c.ui.accent, bg = c.ui.none, bold = true }
          end,
        },
        astrolight = {
          -- Specific overrides for astrolight theme
          modify_hl_groups = function(hl, c)
            hl.Comment = { fg = c.syntax.comment, italic = true }
            hl.Todo = { fg = c.ui.accent, bg = c.ui.none, bold = true }
          end,
        },
      },
    },
    config = function(_, opts)
      require("astrotheme").setup(opts)
      -- Uncomment the line below to switch to AstroTheme
      -- vim.cmd.colorscheme("astrotheme")
    end,
    
    keys = {
      -- Quick theme switching (organized under <leader>ut)
      { "<leader>uta", function() vim.cmd.colorscheme("astrotheme") end, desc = "AstroTheme (Dark)" },
      { "<leader>utl", function() 
        vim.o.background = "light"
        vim.cmd.colorscheme("astrotheme") 
      end, desc = "AstroTheme (Light)" },
      { "<leader>utm", function() 
        require("astrotheme").setup({ palette = "astromars" })
        vim.cmd.colorscheme("astrotheme")
      end, desc = "AstroTheme (Mars)" },
      { "<leader>utt", function() vim.cmd.colorscheme("tokyonight-storm") end, desc = "Tokyo Night" },
    },
  },
}