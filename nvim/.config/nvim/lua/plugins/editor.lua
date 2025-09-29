-- Editor enhancement plugins inspired by LazyVim
return {
  -- Flash enhances the built-in search functionality by showing labels
  -- at the end of each match, letting you quickly jump to a specific location
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- Remap Flash away from 's' to avoid conflict with mini.surround
      { "/", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "?", mode = { "n", "x", "o" }, function() require("flash").jump({ search = { forward = false } }) end, desc = "Flash Jump Backward" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
      -- Flash treesitter selection under leader
      { 
        "<leader>fs", 
        mode = { "n", "o", "x" },
        function() require("flash").treesitter() end, 
        desc = "Flash Treesitter Selection" 
      },
    },
  },

  -- which-key helps you remember key bindings by showing a popup
  -- with the active keybindings of the command you started typing
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      spec = {
        { "<leader><tab>", group = "tabs", mode = { "n", "v" } },
        { "<leader>c", group = "code", mode = { "n", "v" } },
        { "<leader>d", group = "debug", mode = { "n", "v" } },
        { "<leader>f", group = "file/find", mode = { "n", "v" } },
        { "<leader>g", group = "git", mode = { "n", "v" } },
        { "<leader>gh", group = "hunks", mode = { "n", "v" } },
        { "<leader>h", group = "harpoon", mode = { "n", "v" } },
        { "<leader>q", group = "quit/session", mode = { "n", "v" } },
        -- Remove conflicting group definitions, let which-key auto-discover
        { "<leader>s", group = "search", mode = { "n", "v" } },
        { "<leader>t", group = "terminal/toggle", mode = { "n", "v" } },
        { "<leader>tc", group = "treesitter-context", mode = { "n", "v" } },
        { "<leader>u", group = "ui", mode = { "n", "v" } },
        { "<leader>ut", group = "ui/themes", mode = { "n", "v" } },
        { "<leader>w", group = "windows", mode = { "n", "v" } },
        { "<leader>x", group = "diagnostics/quickfix", mode = { "n", "v" } },
        -- Keep essential navigation groups
        { "[", group = "prev", mode = { "n", "v" } },
        { "]", group = "next", mode = { "n", "v" } },
        { "g", group = "goto", mode = { "n", "v" } },
        { "z", group = "fold", mode = { "n", "v" } },
      },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
        ellipsis = "…",
        mappings = true,
        rules = {},
        colors = true,
        keys = {
          Up = " ",
          Down = " ",
          Left = " ",
          Right = " ",
          C = "󰘴 ",
          M = "󰘵 ",
          D = "󰘳 ",
          S = "󰘶 ",
          CR = "󰌑 ",
          Esc = "󱊷 ",
          ScrollWheelDown = "󱕐 ",
          ScrollWheelUp = "󱕑 ",
          NL = "󰌑 ",
          BS = "󰁮",
          Space = "󱁐 ",
          Tab = "󰌒 ",
          F1 = "󱊫",
          F2 = "󱊬",
          F3 = "󱊭",
          F4 = "󱊮",
          F5 = "󱊯",
          F6 = "󱊰",
          F7 = "󱊱",
          F8 = "󱊲",
          F9 = "󱊳",
          F10 = "󱊴",
          F11 = "󱊵",
          F12 = "󱊶",
        },
      },
      show_help = true,
      show_keys = true,
      disable = {
        buftypes = {},
        filetypes = { "TelescopePrompt" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
    end,
  },

  -- Enhanced gitsigns configuration 
  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")

        -- Actions
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  -- Better diagnostics list and others
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble" },
    init = function()
      -- Disable on startup to prevent window management issues
      vim.g.trouble_disable_on_startup = true
    end,
    opts = {
      auto_close = false,
      auto_open = false,
      auto_preview = true,
      auto_refresh = true,
      auto_jump = false,
      focus = false,
      restore = true,
      follow = true,
      indent_guides = true,
      max_items = 200,
      multiline = true,
      pinned = false,
      warn_no_results = true,
      open_no_results = false,
      win = {
        position = "bottom",
        size = { height = 10 },
        border = "single",
      },
      preview = {
        type = "main",
        scratch = true,
      },
      -- Add safe mode configuration
      modes = {
        diagnostics = {
          auto_refresh = false,
        },
        lsp = {
          auto_refresh = false,
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
      -- Simplified navigation without API calls that could cause promise issues
      { "[q", "<cmd>Trouble qflist prev<cr>", desc = "Previous Trouble/Quickfix Item" },
      { "]q", "<cmd>Trouble qflist next<cr>", desc = "Next Trouble/Quickfix Item" },
    },
  },
}