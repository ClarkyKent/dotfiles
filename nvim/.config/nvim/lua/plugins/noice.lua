-- Noice.nvim: Enhanced UI for messages, cmdline and popupmenu
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      -- LSP progress configuration
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
        progress = {
          enabled = true,
          format = "lsp_progress",
          format_done = "lsp_progress_done",
          throttle = 1000 / 30, -- frequency to update lsp progress message
          view = "mini",
        },
        hover = {
          enabled = true,
          silent = false, -- set to true to not show message if hover is not available
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
            trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
            luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
            throttle = 50, -- Debounce lsp signature help request by 50ms
          },
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
        message = {
          enabled = true,
          view = "notify",
          opts = {},
        },
        documentation = {
          view = "hover",
          opts = {
            lang = "markdown",
            replace = true,
            render = "plain",
            format = { "{message}" },
            win_options = { concealcursor = "n", conceallevel = 3 },
          },
        },
      },
      
      -- Health check configuration
      health = {
        checker = false, -- Disable if you don't want health checks
      },
      
      -- Smart notify configuration
      smart_move = {
        enabled = true, -- noice tries to move out of the way of existing floating windows.
        excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
      },
      
      -- Presets for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
      
      -- Message configuration
      messages = {
        enabled = true, -- enables the Noice messages UI
        view = "notify", -- default view for messages
        view_error = "notify", -- view for errors
        view_warn = "notify", -- view for warnings
        view_history = "messages", -- view for :messages
        view_search = "virtualtext", -- view for search count messages
      },
      
      -- Popupmenu configuration
      popupmenu = {
        enabled = true, -- enables the Noice popupmenu UI
        backend = "nui", -- backend to use to show regular cmdline completions
        kind_icons = {}, -- set to false to disable icons
      },
      
      -- Redirect configuration
      redirect = {
        view = "popup",
        filter = { event = "msg_show" },
      },
      
      -- Command line configuration
      cmdline = {
        enabled = true, -- enables the Noice cmdline UI
        view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
        opts = {}, -- global options for the cmdline. See section on views
        format = {
          -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
          -- view: (default is cmdline view)
          -- opts: any options passed to the view
          -- icon_hl_group: optional hl_group for the icon
          -- title: set to anything or empty string to hide
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
          input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
          -- lua = false, -- to disable a format, set to `false`
        },
      },
      
      -- Views configuration
      views = {
        cmdline_popup = {
          position = {
            row = 5,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = 8,
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
      },
      
      -- Routes configuration for message filtering and routing
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
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "msg_show",
            find = "search hit BOTTOM",
          },
          skip = true,
        },
        {
          filter = {
            event = "msg_show",
            find = "search hit TOP",
          },
          skip = true,
        },
        {
          filter = {
            event = "msg_show",
            find = "Pattern not found",
          },
          skip = true,
        },
        -- Route long messages to split
        {
          filter = { event = "msg_show", min_height = 20 },
          view = "split",
        },
        -- Route nvim-treesitter messages to mini view
        {
          filter = {
            event = "notify",
            find = "treesitter",
          },
          view = "mini",
        },
        -- Route LSP progress to mini view
        {
          filter = {
            event = "lsp",
            kind = "progress",
          },
          opts = { replace = true, merge = true },
        },
      },
    },
    
    keys = {
      { "<leader>sn", "<cmd>NoiceHistory<cr>", desc = "Noice History" },
      { "<leader>snl", "<cmd>NoiceLast<cr>", desc = "Noice Last Message" },
      { "<leader>snd", "<cmd>NoiceDismiss<cr>", desc = "Dismiss All" },
      { "<leader>snt", "<cmd>NoiceStats<cr>", desc = "Noice Stats" },
      { "<leader>snc", "<cmd>NoiceConfig<cr>", desc = "Noice Config" },
      -- Better scrolling in command line and popups
      { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
      { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"} },
    },
    
    config = function(_, opts)
      -- Setup noice
      require("noice").setup(opts)
      
      -- Integrate with nvim-notify for better notifications
      vim.notify = require("notify")
      
      -- Custom highlighting
      vim.cmd([[
        highlight NoiceCmdlinePopup guibg=#1e1e2e
        highlight NoiceCmdlinePopupBorder guifg=#89b4fa
        highlight NoiceCmdlineIcon guifg=#fab387
      ]])
    end,
  },
  
  -- Enhanced notifications
  {
    "rcarriga/nvim-notify",
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
      render = "wrapped-compact",
      stages = "fade_in_slide_out",
      background_colour = "#000000",
      icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        DEBUG = "",
        TRACE = "✎",
      },
      level = 2,
      minimum_width = 50,
      fps = 30,
      top_down = true,
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      
      -- Set as default notification handler
      vim.notify = notify
      
      -- Add keymap to dismiss notifications
      vim.keymap.set("n", "<leader>un", function()
        notify.dismiss({ silent = true, pending = true })
      end, { desc = "Dismiss All Notifications" })
    end,
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "<leader>sN",
        function()
          require("telescope").extensions.notify.notify()
        end,
        desc = "Notification History",
      },
    },
  },
}