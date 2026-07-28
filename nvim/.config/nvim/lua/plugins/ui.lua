return {
  -- Navic (Breadcrumbs)
  -- Previously configured but never rendered anywhere -- no winbar component,
  -- not referenced by lualine. It is now drawn in the winbar.
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    init = function()
      vim.g.navic_silence = true
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("navic_attach", { clear = true }),
        callback = function(args)
          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not (client and client:supports_method("textDocument/documentSymbol")) then
            return
          end
          require("nvim-navic").attach(client, buffer)

          -- Only draw a winbar in real, listed file windows.
          if
            vim.bo[buffer].buftype ~= ""
            or vim.bo[buffer].filetype == ""
            or vim.api.nvim_win_get_config(0).relative ~= ""
          then
            return
          end
          vim.wo.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
        end,
      })
    end,
    opts = function()
      return {
        separator = "  ",
        highlight = true,
        depth_limit = 5,
        icons = require("config.icons").kinds,
        lazy_update_context = true,
      }
    end,
  },

  -- Colorscheme - Kanagawa
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {
      compile = false, -- enable compiling the colorscheme
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false, -- do not set background color
      dimInactive = false, -- dim inactive window `:h hl-NormalNC`
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
      colors = { -- add/modify theme and palette colors
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
      },
      overrides = function(colors) -- add/modify highlights
        return {}
      end,
      theme = "wave", -- Load "wave" theme when 'background' option is not set
      background = { -- map the value of 'background' option to a theme
        dark = "wave", -- try "dragon" !
        light = "lotus",
      },
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      require("kanagawa").load()
    end,
  },

  -- Zen Mode
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      plugins = {
        gitsigns = { enabled = true },
        tmux = { enabled = true },
        twilight = { enabled = true },
      },
    },
    keys = {
      { "<leader>uz", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
  },

  -- Twilight (dim inactive portions of code)
  -- NOTE: twilight exposes no `is_enabled()`; the previous wrapper called it
  -- unconditionally and threw. `:Twilight` already toggles and reports state.
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    opts = {},
    keys = {
      { "<leader>uw", "<cmd>Twilight<cr>", desc = "Twilight (dim inactive code)" },
    },
  },

  -- Notifications are owned by snacks.notifier (see the snacks spec below).
  -- nvim-notify remains installed only because noice.nvim can route to it,
  -- but it must not register its own `<leader>un` -- that collided with
  -- Snacks.notifier.hide and the winning binding was load-order dependent.
  {
    "rcarriga/nvim-notify",
    lazy = true,
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local icons = {
        diagnostics = { Error = " ", Warn = " ", Hint = " ", Info = " " },
        git = { added = " ", modified = " ", removed = " " },
      }
      return {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
          },
          lualine_x = {
            {
              function()
                return require("noice").api.status.command.get()
              end,
              cond = function()
                return package.loaded["noice"] and require("noice").api.status.command.has()
              end,
            },
            {
              function()
                return require("noice").api.status.mode.get()
              end,
              cond = function()
                return package.loaded["noice"] and require("noice").api.status.mode.has()
              end,
            },
            {
              "diff",
              symbols = { added = icons.git.added, modified = icons.git.modified, removed = icons.git.removed },
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return " " .. os.date("%R")
            end,
          },
        },
        extensions = { "lazy" },
      }
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete Other Buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    },
    opts = {
      options = {
        close_command = function(n)
          require("mini.bufremove").delete(n, false)
        end,
        right_mouse_command = function(n)
          require("mini.bufremove").delete(n, false)
        end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = { Error = " ", Warn = " ", Hint = " ", Info = " " }
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        -- No file explorer offset needed (using fzf-lua for navigation)
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
    end,
  },

  -- Noice
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          -- Note: cmp.entry.get_documentation is for nvim-cmp, not blink.cmp
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },

  -- Dashboard
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      quickfix = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
      {
        "<leader>n",
        function()
          Snacks.notifier.show_history()
        end,
        desc = "Notification History",
      },
      {
        "<leader>cR",
        function()
          Snacks.rename.rename_file()
        end,
        desc = "Rename File",
      },
      {
        "<leader>gB",
        function()
          Snacks.gitbrowse()
        end,
        desc = "Git Browse",
      },
      {
        "<leader>gb",
        function()
          Snacks.git.blame_line()
        end,
        desc = "Git Blame Line",
      },
      {
        "<leader>gf",
        function()
          Snacks.lazygit.log_file()
        end,
        desc = "Lazygit Current File History",
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>gl",
        function()
          Snacks.lazygit.log()
        end,
        desc = "Lazygit Log (CWD)",
      },
      {
        "<leader>un",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "<c-/>",
        function()
          Snacks.terminal()
        end,
        desc = "Toggle Terminal",
      },
      {
        "<c-_>",
        function()
          Snacks.terminal()
        end,
        desc = "which_key_ignore",
      },
    },
  },

  -- Floating Terminal (ToggleTerm) - NvChad style
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    lazy = false,
    keys = {
      { "<A-h>", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Terminal Horizontal" },
      { "<A-v>", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Terminal Vertical" },
      { "<A-i>", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal Float" },
      -- Insert mode mappings
      { "<A-h>", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", mode = "i", desc = "Terminal Horizontal" },
      { "<A-v>", "<cmd>ToggleTerm size=80 direction=vertical<cr>", mode = "i", desc = "Terminal Vertical" },
      { "<A-i>", "<cmd>ToggleTerm direction=float<cr>", mode = "i", desc = "Terminal Float" },
      -- Terminal mode mappings
      { "<A-h>", "<cmd>ToggleTerm<cr>", mode = "t", desc = "Toggle Terminal" },
      { "<A-v>", "<cmd>ToggleTerm<cr>", mode = "t", desc = "Toggle Terminal" },
      { "<A-i>", "<cmd>ToggleTerm<cr>", mode = "t", desc = "Toggle Terminal" },
      { "<C-x>", "<cmd>ToggleTerm<cr>", mode = "t", desc = "Toggle Terminal" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
      float_opts = {
        border = "curved",
        width = function()
          return math.floor(vim.o.columns * 0.8)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
      winbar = {
        enabled = false,
      },
    },
  },

  -- Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Illuminate (highlight word under cursor)
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end
      map("]]", "next")
      map("[[", "prev")
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },

  -- Treesitter context (sticky function headers)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = { mode = "cursor", max_lines = 3 },
    keys = {
      {
        "<leader>uC",
        function()
          local tsc = require("treesitter-context")
          tsc.toggle()
          require("config.util").toggle_fn("Treesitter Context", function()
            return true
          end, true)
        end,
        desc = "Toggle Treesitter Context",
      },
      {
        "<leader>ul",
        function()
          require("config.util").toggle("number")
        end,
        desc = "Line Numbers",
      },
      {
        "<leader>uL",
        function()
          require("config.util").toggle("relativenumber")
        end,
        desc = "Relative Numbers",
      },
      {
        "<leader>ud",
        function()
          require("config.util").toggle_diagnostics()
        end,
        desc = "Inline Diagnostics",
      },
      {
        "<leader>us",
        function()
          require("config.util").toggle("spell")
        end,
        desc = "Spelling",
      },
      {
        "<leader>ub",
        function()
          require("config.util").toggle("background", false, { "light", "dark" })
        end,
        desc = "Background (Light/Dark)",
      },
    },
  },

  -- Which-key (keymap discovery)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      preset = "modern",
      plugins = { spelling = true },
      spec = {
        { "<leader>a", group = "ai", icon = " " },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug", icon = " " },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>gx", group = "conflict" },
        { "<leader>h", group = "harpoon" },
        -- <leader>m is markdown only now; the CMake build bindings that used
        -- to squat here were removed along with cmake-tools.nvim.
        { "<leader>m", group = "markdown", icon = " " },
        { "<leader>o", group = "tasks/overseer", icon = "󰭻 " },
        { "<leader>q", group = "sessions" },
        { "<leader>r", group = "refactor" },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "test/coverage", icon = "󰙨 " },
        { "<leader>u", group = "ui/toggle" },
        { "<leader>w", group = "windows" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "<leader><tab>", group = "tabs" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "gs", group = "surround" },
        { "gp", group = "peek" },
      },
    },
  },

  -- Indent guides are owned by snacks.indent (see the snacks spec).
  -- indent-blankline was rendering a second set of guides on top of it.
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
  },

  -- Scrollbar with diagnostics
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      handle = {
        color = nil, -- Use theme default
      },
      marks = {
        Cursor = { text = "•" },
        Search = { color = nil },
        Error = { color = nil },
        Warn = { color = nil },
        Info = { color = nil },
        Hint = { color = nil },
        Misc = { color = nil },
      },
      handlers = {
        gitsigns = true,
        search = false, -- Requires kevinhwang91/nvim-hlslens (not installed)
      },
    },
  },

  -- vim.ui.select / vim.ui.input are owned by snacks (input) and fzf-lua
  -- (select, registered in lua/plugins/project.lua). dressing.nvim was a third
  -- provider racing the other two for the same override.
  {
    "stevearc/dressing.nvim",
    enabled = false,
  },
}
