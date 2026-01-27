return {
  -- Fzf-lua
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    init = function()
      -- Define project root finder globally (available before plugin loads)
      _G.fzf_get_root = function()
        local path = vim.api.nvim_buf_get_name(0)
        path = path ~= "" and vim.uv.fs_realpath(path) or nil
        local search_path = path or vim.uv.cwd()

        local root = vim.fs.find(".git", { path = search_path, upward = true })[1]
        if root then return vim.fs.dirname(root) end

        root = vim.fs.find({ "Makefile", "meson.build", "Cargo.toml", "pyproject.toml", "package.json" }, {
          path = search_path,
          upward = true,
        })[1]
        return root and vim.fs.dirname(root) or vim.uv.cwd()
      end
    end,
    keys = {
      { "<leader>,", "<cmd>FzfLua buffers<cr>", desc = "Switch Buffer" },
      { "<leader>/", function() require("fzf-lua").live_grep({ cwd = _G.fzf_get_root() }) end, desc = "Grep (Root Dir)" },
      { "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      { "<leader><space>", function() require("fzf-lua").files({ cwd = _G.fzf_get_root() }) end, desc = "Find Files (Root Dir)" },
      -- find
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>ff", function() require("fzf-lua").files({ cwd = _G.fzf_get_root() }) end, desc = "Find Files (Root Dir)" },
      { "<leader>fF", function() require("fzf-lua").files({ cwd = vim.fn.expand("%:p:h") }) end, desc = "Find Files (Cwd)" },
      { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Files (git-files)" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
      -- git
      { "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Commits" },
      { "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Status" },
      -- search
      { "<leader>s\"", "<cmd>FzfLua registers<cr>", desc = "Registers" },
      { "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>FzfLua lines<cr>", desc = "Buffer Lines" },
      { "<leader>sc", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document Diagnostics" },
      { "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics" },
      { "<leader>sg", function() require("fzf-lua").live_grep({ cwd = _G.fzf_get_root() }) end, desc = "Grep (Root Dir)" },
      { "<leader>sG", function() require("fzf-lua").live_grep({ cwd = vim.fn.expand("%:p:h") }) end, desc = "Grep (Cwd)" },
      { "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>FzfLua highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
      { "<leader>sl", "<cmd>FzfLua loclist<cr>", desc = "Location List" },
      { "<leader>sM", "<cmd>FzfLua man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Jump to Mark" },
      { "<leader>so", "<cmd>FzfLua vim_options<cr>", desc = "Options" },
      { "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume" },
      { "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
      { "<leader>sw", function() require("fzf-lua").grep_cword({ cwd = _G.fzf_get_root() }) end, desc = "Word (Root Dir)" },
      { "<leader>sW", function() require("fzf-lua").grep_cword({ cwd = vim.fn.expand("%:p:h") }) end, desc = "Word (Cwd)" },
      { "<leader>sw", function() require("fzf-lua").grep_visual({ cwd = _G.fzf_get_root() }) end, mode = "v", desc = "Selection (Root Dir)" },
      { "<leader>sW", function() require("fzf-lua").grep_visual({ cwd = vim.fn.expand("%:p:h") }) end, mode = "v", desc = "Selection (Cwd)" },
      { "<leader>s*", "<cmd>FzfLua lgrep_curbuf<cr>", desc = "Word in Buffer" },
    },
    opts = {
      -- Global fzf colors (Catppuccin-inspired)
      fzf_colors = {
        ["fg"] = { "fg", "CursorLine" },
        ["bg"] = { "bg", "Normal" },
        ["hl"] = { "fg", "Comment" },
        ["fg+"] = { "fg", "Normal" },
        ["bg+"] = { "bg", "CursorLine" },
        ["hl+"] = { "fg", "Statement" },
        ["info"] = { "fg", "PreProc" },
        ["prompt"] = { "fg", "Conditional" },
        ["pointer"] = { "fg", "Exception" },
        ["marker"] = { "fg", "Keyword" },
        ["spinner"] = { "fg", "Label" },
        ["header"] = { "fg", "Comment" },
        ["gutter"] = { "bg", "Normal" },
        ["separator"] = { "fg", "Comment" },
      },
      fzf_opts = {
        ["--ansi"] = true,
        ["--info"] = "inline-right",
        ["--layout"] = "reverse",
        ["--marker"] = "▏",
        ["--pointer"] = "▌",
        ["--prompt"] = " ",
        ["--separator"] = "─",
        ["--scrollbar"] = "▐",
        ["--ellipsis"] = "…",
      },
      winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        border = "rounded",
        backdrop = 60,
        title = " FZF ",
        title_pos = "center",
        preview = {
          default = "builtin",
          border = "border",
          layout = "flex",
          flip_columns = 130,
          vertical = "down:55%",
          horizontal = "right:55%",
          title = true,
          title_pos = "center",
          scrollbar = "float",
          delay = 50,
          winopts = {
            number = true,
            relativenumber = false,
            cursorline = true,
            cursorlineopt = "both",
            signcolumn = "no",
          },
        },
        on_create = function()
          vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, buffer = true })
          vim.keymap.set("t", "<C-k>", "<Up>", { silent = true, buffer = true })
        end,
      },
      keymap = {
        builtin = {
          ["<F1>"] = "toggle-help",
          ["<F2>"] = "toggle-fullscreen",
          ["<F3>"] = "toggle-preview-wrap",
          ["<F4>"] = "toggle-preview",
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
        fzf = {
          ["ctrl-z"] = "abort",
          ["ctrl-a"] = "toggle-all",
          ["ctrl-q"] = "select-all+accept",
          ["ctrl-d"] = "preview-page-down",
          ["ctrl-u"] = "preview-page-up",
        },
      },
      files = {
        prompt = "  ",
        cwd_prompt = false,
        file_icons = true,
        git_icons = true,
        color_icons = true,
        find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
        fd_opts = [[--color=never --type f --hidden --follow --exclude .git]],
        actions = {
          ["ctrl-g"] = false,
        },
        winopts = {
          title = "  Files ",
          title_pos = "center",
        },
      },
      buffers = {
        prompt = " 󰈙 ",
        file_icons = true,
        color_icons = true,
        sort_lastused = true,
        winopts = {
          title = " 󰈙 Buffers ",
          title_pos = "center",
        },
      },
      grep = {
        prompt = "  ",
        input_prompt = "  Grep: ",
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        rg_glob = true,
        glob_flag = "--iglob",
        glob_separator = "%s%-%-",
        winopts = {
          title = "  Grep ",
          title_pos = "center",
        },
      },
      lsp = {
        prompt_postfix = " ",
        symbols = {
          prompt = " 󰅪 ",
          symbol_icons = {
            File = "󰈙",
            Module = "",
            Namespace = "󰦮",
            Package = "",
            Class = "󰆧",
            Method = "󰊕",
            Property = "",
            Field = "",
            Constructor = "",
            Enum = "",
            Interface = "",
            Function = "󰊕",
            Variable = "󰀫",
            Constant = "󰏿",
            String = "",
            Number = "󰎠",
            Boolean = "󰨙",
            Array = "󱡠",
            Object = "",
            Key = "󰌋",
            Null = "󰟢",
            EnumMember = "",
            Struct = "󰆼",
            Event = "",
            Operator = "󰆕",
            TypeParameter = "󰗴",
          },
        },
        code_actions = {
          prompt = " 󰌵 ",
          winopts = {
            title = " 󰌵 Code Actions ",
            title_pos = "center",
          },
        },
      },
      diagnostics = {
        prompt = " 󰒡 ",
        winopts = {
          title = " 󰒡 Diagnostics ",
          title_pos = "center",
        },
      },
      oldfiles = {
        prompt = "  ",
        winopts = {
          title = "  Recent Files ",
          title_pos = "center",
        },
      },
      quickfix = {
        prompt = " 󰁨 ",
        winopts = {
          title = " 󰁨 Quickfix ",
          title_pos = "center",
        },
      },
      loclist = {
        prompt = " 󰒡 ",
        winopts = {
          title = " 󰒡 Location List ",
          title_pos = "center",
        },
      },
      git = {
        files = {
          prompt = " 󰊢 ",
          winopts = {
            title = " 󰊢 Git Files ",
            title_pos = "center",
          },
        },
        status = {
          prompt = " 󰊢 ",
          winopts = {
            title = " 󰊢 Git Status ",
            title_pos = "center",
          },
        },
        commits = {
          prompt = "  ",
          winopts = {
            title = "  Git Commits ",
            title_pos = "center",
          },
        },
        bcommits = {
          prompt = "  ",
          winopts = {
            title = "  Buffer Commits ",
            title_pos = "center",
          },
        },
        branches = {
          prompt = "  ",
          winopts = {
            title = "  Git Branches ",
            title_pos = "center",
          },
        },
      },
      helptags = {
        prompt = " 󰋖 ",
        winopts = {
          title = " 󰋖 Help ",
          title_pos = "center",
        },
      },
      keymaps = {
        prompt = "  ",
        winopts = {
          title = "  Keymaps ",
          title_pos = "center",
        },
      },
      marks = {
        prompt = " 󰃀 ",
        winopts = {
          title = " 󰃀 Marks ",
          title_pos = "center",
        },
      },
      registers = {
        prompt = " 󰅍 ",
        winopts = {
          title = " 󰅍 Registers ",
          title_pos = "center",
        },
      },
      commands = {
        prompt = "  ",
        winopts = {
          title = "  Commands ",
          title_pos = "center",
        },
      },
      command_history = {
        prompt = "  ",
        winopts = {
          title = "  Command History ",
          title_pos = "center",
        },
      },
      search_history = {
        prompt = "  ",
        winopts = {
          title = "  Search History ",
          title_pos = "center",
        },
      },
    },
  },

  -- Flash
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- Mini.surround
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete surrounding" },
        { opts.mappings.find, desc = "Find right surrounding" },
        { opts.mappings.find_left, desc = "Find left surrounding" },
        { opts.mappings.highlight, desc = "Highlight surrounding" },
        { opts.mappings.replace, desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`
      },
    },
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>H", function() require("harpoon"):list():add() end, desc = "Harpoon File" },
      { "<leader>h", function() local harpoon = require("harpoon"); harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon Quick Menu" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon to File 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon to File 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon to File 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon to File 4" },
      { "<leader>5", function() require("harpoon"):list():select(5) end, desc = "Harpoon to File 5" },
    },
    opts = {},
  },

  -- Git Signs
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 500,
        ignore_whitespace = false,
      },
    },
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoFzfLua" },
    event = "VeryLazy",
    config = true,
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", "<cmd>TodoFzfLua<cr>", desc = "Todo (fzf)" },
      { "<leader>sT", "<cmd>TodoFzfLua keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (fzf)" },
    },
  },

  -- Refactoring
  {
    "ThePrimeagen/refactoring.nvim",
    keys = {
      {
        "<leader>r",
        function()
          require("refactoring").select_refactor()
        end,
        mode = "v",
        noremap = true,
        silent = true,
        expr = false,
        desc = "Refactoring",
      },
    },
    opts = {},
  },

  -- Trouble (better diagnostics list)
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / References (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },

  -- Mini.bufremove (better buffer deletion)
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
    },
  },
}
