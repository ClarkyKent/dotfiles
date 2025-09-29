-- Enhanced todo management with additional utilities
return {
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        FIX = {
          icon = " ", -- icon used for the sign, and in search results
          color = "error", -- can be a hex color, or a named color (see below)
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      gui_style = {
        fg = "NONE", -- The gui style to use for the fg highlight group.
        bg = "BOLD", -- The gui style to use for the bg highlight group.
      },
      merge_keywords = true, -- when true, custom keywords will be merged with the defaults
      highlight = {
        multiline = true, -- enable multine todo comments
        multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
        multiline_context = 10, -- extra lines of context to show around a multiline comment
        before = "", -- "fg" or "bg" or empty
        keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
        after = "fg", -- "fg" or "bg" or empty
        pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
        comments_only = true, -- uses treesitter to match keywords in comments only
        max_line_len = 400, -- ignore lines longer than this
        exclude = {}, -- list of file types to exclude highlighting
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
      },
    },
    keys = {
      -- Navigation
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
      
      -- Quick todo actions using <leader>x prefix (diagnostics/quickfix)
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>xl", "<cmd>TodoLocList<cr>", desc = "Todo Location List" },
      { "<leader>xq", "<cmd>TodoQuickFix<cr>", desc = "Todo QuickFix" },
      
      -- Integrated with telescope/fzf search (already handled in fzf.lua with <leader>st prefix)
    },
  },
  
  -- Enhanced todo utilities
  {
    "arnarg/todotxt.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    ft = "todotxt",
    cmd = { "TodoTxtCapture", "TodoTxtTasksToggle" },
    opts = {
      todo_file = vim.fn.expand("~/todo.txt"),
      sidebar = {
        width = 40,
        position = "right", -- left, right
      },
      capture = {
        prompt = "> ",
        insert_date = true,
      },
      keymap = {
        quit = "q",
        toggle_metadata = "m",
        toggle_projects = "p",
        toggle_contexts = "c",
        toggle_completed = "x",
      },
    },
    keys = {
      { "<leader>uo", "<cmd>TodoTxtTasksToggle<cr>", desc = "Toggle Todo.txt Tasks" },
      { "<leader>ua", "<cmd>TodoTxtCapture<cr>", desc = "Add Todo.txt Task" },
    },
  },
}