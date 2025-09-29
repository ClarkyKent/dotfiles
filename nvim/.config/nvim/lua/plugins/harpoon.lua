-- Harpoon 2: Quick navigation to marked files
return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- Global settings
      settings = {
        save_on_toggle = false,
        sync_on_ui_close = true,  -- Auto-save when closing UI
        key = function()
          return vim.loop.cwd()
        end,
      },
      
      -- Default configuration for file lists
      default = {
        get_root_dir = function()
          return vim.loop.cwd()
        end,
        select = function(list_item, list, options)
          options = options or {}
          if options.vsplit then
            vim.cmd("vsplit")
          elseif options.split then
            vim.cmd("split")
          elseif options.tabedit then
            vim.cmd("tabedit")
          end
          
          if list_item then
            vim.api.nvim_command("edit " .. list_item.value)
          end
        end,
      },
      
      -- Custom terminal list configuration
      terms = {
        select = function(list_item, list, options)
          options = options or {}
          local Terminal = require("toggleterm.terminal").Terminal
          
          if list_item then
            local term = Terminal:new({
              cmd = list_item.value,
              direction = options.direction or "float",
            })
            term:toggle()
          end
        end,
        encode = false,  -- Don't save to disk
      },
    },
    
    keys = {
      -- Core Harpoon functionality
      { "<leader>ha", function()
        require("harpoon"):list():add()
        vim.notify("󱡀 Added to Harpoon", vim.log.levels.INFO)
      end, desc = "Harpoon: Add file" },
      
      { "<leader>hh", function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, desc = "Harpoon: Toggle menu" },
      
      -- File navigation (1-9)
      { "<leader>h1", function() require("harpoon"):list():select(1) end, desc = "Harpoon: File 1" },
      { "<leader>h2", function() require("harpoon"):list():select(2) end, desc = "Harpoon: File 2" },
      { "<leader>h3", function() require("harpoon"):list():select(3) end, desc = "Harpoon: File 3" },
      { "<leader>h4", function() require("harpoon"):list():select(4) end, desc = "Harpoon: File 4" },
      { "<leader>h5", function() require("harpoon"):list():select(5) end, desc = "Harpoon: File 5" },
      { "<leader>h6", function() require("harpoon"):list():select(6) end, desc = "Harpoon: File 6" },
      { "<leader>h7", function() require("harpoon"):list():select(7) end, desc = "Harpoon: File 7" },
      { "<leader>h8", function() require("harpoon"):list():select(8) end, desc = "Harpoon: File 8" },
      { "<leader>h9", function() require("harpoon"):list():select(9) end, desc = "Harpoon: File 9" },
      
      -- Navigation shortcuts
      { "<C-j>", function() require("harpoon"):list():next() end, desc = "Harpoon: Next file" },
      { "<C-k>", function() require("harpoon"):list():prev() end, desc = "Harpoon: Prev file" },
      
      -- Alternative quick access (for frequent files)
      { "<A-h>", function() require("harpoon"):list():select(1) end, desc = "Harpoon: File 1" },
      { "<A-t>", function() require("harpoon"):list():select(2) end, desc = "Harpoon: File 2" },
      { "<A-n>", function() require("harpoon"):list():select(3) end, desc = "Harpoon: File 3" },
      { "<A-s>", function() require("harpoon"):list():select(4) end, desc = "Harpoon: File 4" },
      
      -- List management
      { "<leader>hr", function()
        require("harpoon"):list():clear()
        vim.notify("󱡀 Harpoon list cleared", vim.log.levels.INFO)
      end, desc = "Harpoon: Clear list" },
      
      -- Terminal list functionality
      { "<leader>ht", function()
        local harpoon = require("harpoon")
        local current_line = vim.api.nvim_get_current_line()
        if current_line and current_line ~= "" then
          harpoon:list("terms"):add({ value = current_line })
          vim.notify("󰆍 Added command to Harpoon terminals", vim.log.levels.INFO)
        end
      end, desc = "Harpoon: Add terminal command" },
      
      { "<leader>hT", function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list("terms"))
      end, desc = "Harpoon: Toggle terminal menu" },
    },
    
    config = function(_, opts)
      local harpoon = require("harpoon")
      
      -- Setup with options
      harpoon:setup(opts)
      
      -- Extensions for enhanced functionality
      harpoon:extend({
        UI_CREATE = function(cx)
          -- Enhanced UI keymaps when harpoon menu is open
          vim.keymap.set("n", "<C-v>", function()
            harpoon.ui:select_menu_item({ vsplit = true })
          end, { buffer = cx.bufnr, desc = "Open in vertical split" })

          vim.keymap.set("n", "<C-x>", function()
            harpoon.ui:select_menu_item({ split = true })
          end, { buffer = cx.bufnr, desc = "Open in horizontal split" })

          vim.keymap.set("n", "<C-t>", function()
            harpoon.ui:select_menu_item({ tabedit = true })
          end, { buffer = cx.bufnr, desc = "Open in new tab" })
          
          vim.keymap.set("n", "<C-d>", function()
            local line = vim.fn.line(".")
            harpoon:list():remove_at(line)
            vim.notify("󱡀 Removed item from Harpoon", vim.log.levels.INFO)
          end, { buffer = cx.bufnr, desc = "Delete harpoon item" })
        end,
      })
      
      -- Add builtin extensions
      local harpoon_extensions = require("harpoon.extensions")
      harpoon:extend(harpoon_extensions.builtins.navigate_with_number())
      
      -- Highlight current file in harpoon list
      if harpoon_extensions.builtins.highlight_current_file then
        harpoon:extend(harpoon_extensions.builtins.highlight_current_file())
      end
      
      -- Integration with existing workflow
      vim.api.nvim_create_autocmd("User", {
        pattern = "HarpoonUIMenuOpened",
        callback = function()
          vim.wo.cursorline = true
          vim.wo.number = true
          vim.wo.relativenumber = false
        end,
        desc = "Enhanced UI for Harpoon menu"
      })
    end,
  },
}