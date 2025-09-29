-- Enhanced toggle terminal configuration based on AstroNvim
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      -- Appearance
      highlights = {
        Normal = { link = "Normal" },
        NormalNC = { link = "NormalNC" },
        NormalFloat = { link = "NormalFloat" },
        FloatBorder = { link = "FloatBorder" },
        StatusLine = { link = "StatusLine" },
        StatusLineNC = { link = "StatusLineNC" },
        WinBar = { link = "WinBar" },
        WinBarNC = { link = "WinBarNC" },
      },
      
      -- Terminal settings
      size = function(term)
        if term.direction == "horizontal" then
          return 10
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      autochdir = false,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
      
      -- Float terminal options
      float_opts = {
        border = "rounded",
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
      
      -- Winbar options
      winbar = {
        enabled = false,
        name_formatter = function(term)
          return term.name
        end
      },
      
      -- On terminal create callback
      on_create = function(t)
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.signcolumn = "no"
        vim.opt_local.statuscolumn = ""
        
        -- Terminal-specific keymaps
        if t.hidden then
          local function toggle() t:toggle() end
          vim.keymap.set({ "n", "t", "i" }, "<C-\\>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
          vim.keymap.set({ "n", "t", "i" }, "<F7>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
        end
      end,
      
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
      end,
      
      on_close = function(term)
        vim.cmd("startinsert!")
      end,
      
      shading_factor = 2,
      shading_ratio = -30,
    },
    
    keys = {
      -- Basic toggle mappings
      { "<F7>", '<Cmd>execute v:count . "ToggleTerm"<CR>', desc = "Toggle terminal", mode = { "n", "i" } },
      { "<F7>", "<Cmd>ToggleTerm<CR>", desc = "Toggle terminal", mode = "t" },
      { "<C-\\>", '<Cmd>execute v:count . "ToggleTerm"<CR>', desc = "Toggle terminal", mode = { "n", "i" } },
      { "<C-\\>", "<Cmd>ToggleTerm<CR>", desc = "Toggle terminal", mode = "t" },
      
      -- Directional terminal toggles
      { "<leader>tf", "<Cmd>ToggleTerm direction=float<CR>", desc = "ToggleTerm float" },
      { "<leader>th", "<Cmd>ToggleTerm size=10 direction=horizontal<CR>", desc = "ToggleTerm horizontal split" },
      { "<leader>tv", "<Cmd>ToggleTerm size=80 direction=vertical<CR>", desc = "ToggleTerm vertical split" },
      { "<leader>tt", "<Cmd>ToggleTerm direction=tab<CR>", desc = "ToggleTerm tab" },
      
      -- Special terminal applications
      { "<leader>tg", function()
        local Terminal = require("toggleterm.terminal").Terminal
        local lazygit = Terminal:new({
          cmd = "lazygit",
          dir = "git_dir",
          direction = "float",
          float_opts = {
            border = "double",
          },
          on_open = function(term)
            vim.cmd("startinsert!")
            vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
          end,
          on_close = function(term)
            vim.cmd("startinsert!")
          end,
        })
        lazygit:toggle()
      end, desc = "ToggleTerm lazygit" },
      
      { "<leader>tn", function()
        local Terminal = require("toggleterm.terminal").Terminal
        local node = Terminal:new({
          cmd = "node",
          direction = "float",
          close_on_exit = false,
        })
        node:toggle()
      end, desc = "ToggleTerm node" },
      
      { "<leader>tp", function()
        local Terminal = require("toggleterm.terminal").Terminal
        local python_cmd = vim.fn.executable("python3") == 1 and "python3" or "python"
        local python = Terminal:new({
          cmd = python_cmd,
          direction = "float",
          close_on_exit = false,
        })
        python:toggle()
      end, desc = "ToggleTerm python" },
      
      { "<leader>tb", function()
        local Terminal = require("toggleterm.terminal").Terminal
        local btm = Terminal:new({
          cmd = "btm",
          direction = "float",
          float_opts = {
            border = "double",
            width = function()
              return math.floor(vim.o.columns * 0.9)
            end,
            height = function()
              return math.floor(vim.o.lines * 0.9)
            end,
          },
        })
        btm:toggle()
      end, desc = "ToggleTerm btm" },
      
      { "<leader>td", function()
        local Terminal = require("toggleterm.terminal").Terminal
        local gdu_cmd = "gdu"
        if vim.fn.executable(gdu_cmd) ~= 1 then
          if vim.fn.has("win32") == 1 then
            gdu_cmd = "gdu_windows_amd64.exe"
          elseif vim.fn.has("mac") == 1 then
            gdu_cmd = "gdu-go"
          end
        end
        
        if vim.fn.executable(gdu_cmd) == 1 then
          local gdu = Terminal:new({
            cmd = gdu_cmd,
            direction = "float",
          })
          gdu:toggle()
        else
          vim.notify("gdu not found", vim.log.levels.WARN)
        end
      end, desc = "ToggleTerm gdu" },
    },
    
    config = function(_, opts)
      require("toggleterm").setup(opts)
      
      -- Function to send commands to terminal
      function _G.set_terminal_keymaps()
        local map_opts = {buffer = 0}
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], map_opts)
        vim.keymap.set('t', 'jk', [[<C-\><C-n>]], map_opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], map_opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], map_opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], map_opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], map_opts)
        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], map_opts)
      end
      
      -- Apply terminal keymaps when entering terminal mode
      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
      
      -- Custom terminal commands
      local Terminal = require('toggleterm.terminal').Terminal
      
      -- Horizontal terminal
      local horizontal_term = Terminal:new({
        direction = "horizontal",
        size = 10,
      })
      
      function _HORIZONTAL_TOGGLE()
        horizontal_term:toggle()
      end
      
      -- Vertical terminal  
      local vertical_term = Terminal:new({
        direction = "vertical",
        size = vim.o.columns * 0.4,
      })
      
      function _VERTICAL_TOGGLE()
        vertical_term:toggle()
      end
      
      -- Float terminal
      local float_term = Terminal:new({
        direction = "float",
      })
      
      function _FLOAT_TOGGLE()
        float_term:toggle()
      end
      
      -- Tab terminal
      local tab_term = Terminal:new({
        direction = "tab",
      })
      
      function _TAB_TOGGLE()
        tab_term:toggle()
      end
    end,
  },
}