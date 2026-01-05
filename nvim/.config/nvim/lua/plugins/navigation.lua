return {
  -- Code outline sidebar
  {
    "stevearc/aerial.nvim",
    cmd = "AerialToggle",
    keys = {
      { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Aerial (Symbols)" },
      { "<leader>cn", "<cmd>AerialNavToggle<cr>", desc = "Aerial Nav" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
      layout = {
        max_width = { 40, 0.2 },
        width = nil,
        min_width = 10,
        default_direction = "prefer_right",
      },
      attach_mode = "window",
      close_automatic_events = {},
      keymaps = {
        ["?"] = "actions.show_help",
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.jump",
        ["<2-LeftMouse>"] = "actions.jump",
        ["<C-v>"] = "actions.jump_vsplit",
        ["<C-s>"] = "actions.jump_split",
        ["p"] = "actions.scroll",
        ["<C-j>"] = "actions.down_and_scroll",
        ["<C-k>"] = "actions.up_and_scroll",
        ["{"] = "actions.prev",
        ["}"] = "actions.next",
        ["[["] = "actions.prev_up",
        ["]]"] = "actions.next_up",
        ["q"] = "actions.close",
        ["o"] = "actions.tree_toggle",
        ["za"] = "actions.tree_toggle",
        ["O"] = "actions.tree_toggle_recursive",
        ["zA"] = "actions.tree_toggle_recursive",
        ["l"] = "actions.tree_open",
        ["zo"] = "actions.tree_open",
        ["L"] = "actions.tree_open_recursive",
        ["zO"] = "actions.tree_open_recursive",
        ["h"] = "actions.tree_close",
        ["zc"] = "actions.tree_close",
        ["H"] = "actions.tree_close_recursive",
        ["zC"] = "actions.tree_close_recursive",
        ["zr"] = "actions.tree_increase_fold_level",
        ["zR"] = "actions.tree_open_all",
        ["zm"] = "actions.tree_decrease_fold_level",
        ["zM"] = "actions.tree_close_all",
        ["zx"] = "actions.tree_sync_folds",
        ["zX"] = "actions.tree_sync_folds",
      },
      lsp = {
        diagnostics_trigger_update = true,
        update_when_errors = true,
        update_delay = 300,
      },
      treesitter = {
        update_delay = 300,
      },
      markdown = {
        update_delay = 300,
      },
      filter_kind = false,
      highlight_on_hover = true,
      autojump = false,
      link_folds_to_tree = false,
      link_tree_to_folds = true,
      nerd_font = "auto",
      icons = {},
      guides = {
        mid_item = "├─",
        last_item = "└─",
        nested_top = "│ ",
        whitespace = "  ",
      },
    },
  },

  -- Enhanced % matching
  {
    "andymass/vim-matchup",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.g.matchup_surround_enabled = 1
    end,
  },

  -- LSP preview in popup
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    keys = {
      { "gd", "<cmd>Glance definitions<cr>", desc = "Glance Definitions" },
      { "gr", "<cmd>Glance references<cr>", desc = "Glance References" },
      { "gy", "<cmd>Glance type_definitions<cr>", desc = "Glance Type Definitions" },
      { "gI", "<cmd>Glance implementations<cr>", desc = "Glance Implementations" },
    },
    opts = {
      height = 18,
      zindex = 45,
      preview_win_opts = {
        cursorline = true,
        number = true,
        wrap = true,
      },
      border = {
        enable = true,
        top_char = "―",
        bottom_char = "―",
      },
      list = {
        position = "right",
        width = 0.33,
      },
      theme = {
        enable = true,
        mode = "auto",
      },
      mappings = {
        list = {
          ["j"] = function(win)
            require("glance").actions.next_location(win)
          end,
          ["k"] = function(win)
            require("glance").actions.previous_location(win)
          end,
          ["<Down>"] = function(win)
            require("glance").actions.next_location(win)
          end,
          ["<Up>"] = function(win)
            require("glance").actions.previous_location(win)
          end,
          ["<Tab>"] = function(win)
            require("glance").actions.next_location(win)
          end,
          ["<S-Tab>"] = function(win)
            require("glance").actions.previous_location(win)
          end,
          ["<C-u>"] = function(win)
            require("glance").actions.preview_scroll_win(win, 5)
          end,
          ["<C-d>"] = function(win)
            require("glance").actions.preview_scroll_win(win, -5)
          end,
          ["v"] = function(win)
            require("glance").actions.jump_vsplit(win)
          end,
          ["s"] = function(win)
            require("glance").actions.jump_split(win)
          end,
          ["t"] = function(win)
            require("glance").actions.jump_tab(win)
          end,
          ["<CR>"] = function(win)
            require("glance").actions.jump(win)
          end,
          ["o"] = function(win)
            require("glance").actions.jump(win)
          end,
          ["<leader>l"] = function(win)
            require("glance").actions.enter_win(win, "preview")
          end,
          ["q"] = function(win)
            require("glance").actions.close(win)
          end,
          ["Q"] = function(win)
            require("glance").actions.close(win)
          end,
          ["<Esc>"] = function(win)
            require("glance").actions.close(win)
          end,
          ["<C-q>"] = function(win)
            require("glance").actions.quickfix(win)
          end,
        },
        preview = {
          ["Q"] = function(win)
            require("glance").actions.close(win)
          end,
          ["<Tab>"] = function(win)
            require("glance").actions.next_location(win)
          end,
          ["<S-Tab>"] = function(win)
            require("glance").actions.previous_location(win)
          end,
          ["<leader>l"] = function(win)
            require("glance").actions.enter_win(win, "list")
          end,
        },
      },
      hooks = {},
      folds = {
        fold_closed = "",
        fold_open = "",
        folded = true,
      },
      indent_lines = {
        enable = true,
        icon = "│",
      },
      winbar = {
        enable = true,
      },
    },
  },
}
