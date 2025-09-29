-- Mini plugins: Enhanced text objects, surround operations, auto-pairs, and modern icons
-- Extends and creates a/i textobjects with treesitter support
return {
  -- Mini.icons: Modern icon provider (replaces nvim-web-devicons)
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- Mini.ai: Enhanced text objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter-textobjects" },
    opts = function()
      local ai = require("mini.ai")
      return {
        -- Custom textobjects
        custom_textobjects = {
          -- Treesitter-based textobjects
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner",
          }),
          c = ai.gen_spec.treesitter({
            a = "@class.outer", 
            i = "@class.inner",
          }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          -- Use 'k' for conditionals instead of 'i' to avoid conflict
          k = ai.gen_spec.treesitter({
            a = "@conditional.outer",
            i = "@conditional.inner",
          }),
          l = ai.gen_spec.treesitter({
            a = "@loop.outer",
            i = "@loop.inner",
          }),
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
          
          -- Custom bracket/quote combinations
          g = { -- buffer  
            { "^().*()$" },
          },
          
          -- Indentation textobject
          [" "] = function(ai_type)
            local spaces = (" "):rep(vim.o.tabstop)
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local indents = {}

            for i, line in ipairs(lines) do
              if not line:find("^%s*$") then
                indents[#indents + 1] = { i, #line:match("^%s*"), line }
              end
            end

            local target_indent = #vim.api.nvim_get_current_line():match("^%s*")
            local target_line = vim.api.nvim_win_get_cursor(0)[1]

            local start_line, end_line = target_line, target_line
            for i, v in ipairs(indents) do
              if v[1] == target_line then
                local start_i, end_i = i, i
                while start_i > 1 and indents[start_i - 1][2] >= target_indent do
                  start_i = start_i - 1
                end
                while end_i < #indents and indents[end_i + 1][2] >= target_indent do
                  end_i = end_i + 1
                end
                start_line, end_line = indents[start_i][1], indents[end_i][1]
                break
              end
            end

            if ai_type == "i" then
              -- "inside" includes only same indentation
              local first_line, last_line = start_line, end_line
              for i = start_line, end_line do
                if #(lines[i] or ""):match("^%s*") == target_indent then
                  first_line = i
                  break
                end
              end
              for i = end_line, start_line, -1 do
                if #(lines[i] or ""):match("^%s*") == target_indent then
                  last_line = i
                  break
                end
              end
              return { from = { line = first_line, col = 1 }, to = { line = last_line, col = #lines[last_line] } }
            else
              -- "around" includes nested indentation
              return { from = { line = start_line, col = 1 }, to = { line = end_line, col = #lines[end_line] } }
            end
          end,
        },
        
        -- Module mappings
        mappings = {
          -- Main textobject prefixes
          around = "a",
          inside = "i",

          -- Next/last variants (handle LSP conflicts)
          around_next = "an",
          inside_next = "in", 
          around_last = "al",
          inside_last = "il",

          -- Move cursor to corresponding edge of textobject
          goto_left = "g[",
          goto_right = "g]",
        },

        -- Number of lines within which textobject is searched
        n_lines = 500,

        -- Search method
        search_method = "cover_or_next",

        -- Don't be silent so we can see what's happening
        silent = false,
      }
    end,
    
    config = function(_, opts)
      require("mini.ai").setup(opts)
      
      -- Register which-key descriptions for better discoverability
      local wk_ok, wk = pcall(require, "which-key")
      if wk_ok then
        wk.add({
          -- Text objects for operator-pending mode
          mode = { "o" },
          { "a", group = "around" },
          { "a ", desc = "whitespace/indentation" },
          { "a?", desc = "user prompt" },
          { "aU", desc = "function call (no dot)" },
          { "aa", desc = "argument" },
          { "ab", desc = "balanced brackets" },
          { "ac", desc = "class" },
          { "ad", desc = "digit sequence" },
          { "ae", desc = "word with case" },
          { "af", desc = "function" },
          { "ag", desc = "entire buffer" },
          { "ak", desc = "conditional/if" },
          { "al", desc = "loop" },
          { "ao", desc = "block/object" },
          { "aq", desc = "quote" },
          { "at", desc = "tag" },
          { "au", desc = "function call" },
          { "i", group = "inside" },
          { "i ", desc = "whitespace/indentation" },
          { "i?", desc = "user prompt" },
          { "iU", desc = "function call (no dot)" },
          { "ia", desc = "argument" },
          { "ib", desc = "balanced brackets" },
          { "ic", desc = "class" },
          { "id", desc = "digit sequence" },
          { "ie", desc = "word with case" },
          { "if", desc = "function" },
          { "ig", desc = "entire buffer" },
          { "ik", desc = "conditional/if" },
          { "il", desc = "loop" },
          { "io", desc = "block/object" },
          { "iq", desc = "quote" },
          { "it", desc = "tag" },
          { "iu", desc = "function call" },
        })
        
        wk.add({
          -- Text objects for visual mode
          mode = { "x" },
          { "a", group = "around" },
          { "a ", desc = "whitespace/indentation" },
          { "a?", desc = "user prompt" },
          { "aU", desc = "function call (no dot)" },
          { "aa", desc = "argument" },
          { "ab", desc = "balanced brackets" },
          { "ac", desc = "class" },
          { "ad", desc = "digit sequence" },
          { "ae", desc = "word with case" },
          { "af", desc = "function" },
          { "ag", desc = "entire buffer" },
          { "ak", desc = "conditional/if" },
          { "al", desc = "loop" },
          { "ao", desc = "block/object" },
          { "aq", desc = "quote" },
          { "at", desc = "tag" },
          { "au", desc = "function call" },
          { "i", group = "inside" },
          { "i ", desc = "whitespace/indentation" },
          { "i?", desc = "user prompt" },
          { "iU", desc = "function call (no dot)" },
          { "ia", desc = "argument" },
          { "ib", desc = "balanced brackets" },
          { "ic", desc = "class" },
          { "id", desc = "digit sequence" },
          { "ie", desc = "word with case" },
          { "if", desc = "function" },
          { "ig", desc = "entire buffer" },
          { "ik", desc = "conditional/if" },
          { "il", desc = "loop" },
          { "io", desc = "block/object" },
          { "iq", desc = "quote" },
          { "it", desc = "tag" },
          { "iu", desc = "function call" },
        })
      end
    end,
    
    keys = {
      -- Edge navigation
      { "g[", desc = "Go to left edge of textobject" },
      { "g]", desc = "Go to right edge of textobject" },
      
      -- Examples of usage in keymaps for demonstration
      { "<leader>af", "vaf", desc = "Select around function", mode = "n" },
      { "<leader>if", "vif", desc = "Select inside function", mode = "n" },
      { "<leader>ac", "vac", desc = "Select around class", mode = "n" },
      { "<leader>ic", "vic", desc = "Select inside class", mode = "n" },
    },
  },
  
  -- Integration with existing treesitter textobjects
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      -- Ensure treesitter textobjects work well with mini.ai
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = false, -- Disable to avoid conflicts with mini.ai
            lookahead = true,
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = { query = "@class.outer", desc = "Next class start" },
              ["]o"] = "@loop.*",
              ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
              ["[o"] = "@loop.*",
              ["[s"] = { query = "@scope", query_group = "locals", desc = "Previous scope" },
              ["[z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
        },
      })
    end,
  },

  -- Mini.surround: Fast and feature-rich surround actions
  {
    "echasnovski/mini.surround",
    opts = {
      -- Add custom surroundings to be used on top of builtin ones. For more
      -- information with examples, see `:h MiniSurround.config`.
      custom_surroundings = nil,

      -- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
      highlight_duration = 500,

      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },

      -- Number of lines within which surrounding is searched
      n_lines = 20,

      -- Whether to respect selection type:
      -- - Place surroundings on separate lines in linewise mode.
      -- - Place surroundings on each line in blockwise mode.
      respect_selection_type = false,

      -- How to search for surrounding (first inside current line, then inside
      -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
      -- 'cover_or_nearest', 'next', 'previous', 'nearest'. For more info,
      -- see `:h MiniSurround.config`.
      search_method = "cover",

      -- Whether to disable showing non-error feedback
      silent = false,
    },
    keys = {
      { "sa", desc = "Add Surrounding", mode = { "n", "v" } },
      { "sd", desc = "Delete Surrounding" },
      { "sf", desc = "Find Right Surrounding" },
      { "sF", desc = "Find Left Surrounding" },
      { "sh", desc = "Highlight Surrounding" },
      { "sr", desc = "Replace Surrounding" },
      { "sn", desc = "Update N Lines" },
    },
  },

  -- Mini.pairs: Minimal and fast autopairs
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {
      -- In which modes mappings from this `config` should be created
      modes = { insert = true, command = false, terminal = false },

      -- Global mappings. Each right hand side should be a pair information, a
      -- table with at least these fields (see more in help):
      -- - <action> - one of 'open', 'close', 'closeopen'.
      -- - <pair> - two character string for pair to be used.
      -- By default pair is not inserted after `\`, quotes are not recognized by
      -- `<CR>`, `'` does not insert pair after a letter.
      -- Only parts of tables can be tweaked (others will use these defaults).
      mappings = {
        ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
        ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },

        [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
        ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
        ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },

        ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
        ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\].", register = { cr = false } },
        ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
      },
    },
    config = function(_, opts)
      require("mini.pairs").setup(opts)
      
      -- Add custom keymaps for disabling pairs temporarily
      vim.keymap.set("i", "<M-p>", function()
        local pairs = require("mini.pairs")
        if vim.g.minipairs_disable then
          pairs.enable()
          vim.g.minipairs_disable = false
          vim.notify("Mini.pairs enabled", vim.log.levels.INFO)
        else
          pairs.disable()
          vim.g.minipairs_disable = true
          vim.notify("Mini.pairs disabled", vim.log.levels.INFO)
        end
      end, { desc = "Toggle Mini.pairs" })
    end,
    keys = {
      { "<M-p>", desc = "Toggle Mini.pairs", mode = "i" },
    },
  },
}