return {
  -- Tree-sitter (new rewrite for nvim 0.11+)
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    lazy = false,
    config = function()
      -- Install parsers
      local parsers = {
        "bash", "c", "cpp", "diff", "html", "javascript", "jsdoc",
        "json", "jsonc", "lua", "luadoc", "luap", "markdown",
        "markdown_inline", "python", "query", "regex", "toml",
        "tsx", "typescript", "vim", "vimdoc", "yaml", "rust",
        "cmake", "make", "rst", "ninja",
      }

      -- Install parsers asynchronously
      require('nvim-treesitter').install(parsers)

      -- Enable treesitter highlighting for common filetypes
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'bash', 'c', 'cpp', 'lua', 'python', 'rust', 'javascript',
          'typescript', 'tsx', 'json', 'yaml', 'toml', 'vim', 'markdown',
          'html', 'css', 'cmake', 'make',
        },
        callback = function()
          vim.treesitter.start()
        end,
      })

      -- Enable treesitter-based folding
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'c', 'cpp', 'lua', 'python', 'rust', 'javascript', 'typescript' },
        callback = function()
          vim.wo[0][0].foldmethod = 'expr'
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo[0][0].foldenable = false -- Don't fold by default
        end,
      })

      -- Enable treesitter-based indentation (experimental)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'python', 'yaml' },
        callback = function()
          vim.bo.indentexpr = 'v:lua.require("nvim-treesitter").indentexpr()'
        end,
      })
    end,
  },

  -- Treesitter textobjects - DISABLED: Not compatible with new treesitter rewrite
  -- TODO: Re-enable when nvim-treesitter-textobjects is updated for the new API
  -- See: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  -- {
  --   "nvim-treesitter/nvim-treesitter-textobjects",
  --   enabled = false,
  -- },

  -- Native textobject support (basic replacement until textobjects plugin is updated)
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      -- Helper function to select a treesitter node by capture
      local function select_node(capture_name, mode)
        mode = mode or 'v'
        local bufnr = vim.api.nvim_get_current_buf()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local row, col = cursor[1] - 1, cursor[2]

        -- Get the node at cursor
        local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })
        if not node then return end

        -- Find parent node matching the capture
        while node do
          local node_type = node:type()
          -- Match common node types for functions and classes
          if capture_name == 'function' then
            if node_type:match('function') or node_type:match('method') then
              break
            end
          elseif capture_name == 'class' then
            if node_type:match('class') or node_type:match('struct') then
              break
            end
          end
          node = node:parent()
        end

        if node then
          local start_row, start_col, end_row, end_col = node:range()
          vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
          vim.cmd('normal! ' .. mode)
          vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
        end
      end

      -- Function textobjects (outer = whole function)
      vim.keymap.set({ 'o', 'x' }, 'af', function() select_node('function', 'V') end, { desc = 'Around Function' })
      vim.keymap.set({ 'o', 'x' }, 'if', function() select_node('function', 'V') end, { desc = 'Inside Function' })

      -- Class textobjects
      vim.keymap.set({ 'o', 'x' }, 'ac', function() select_node('class', 'V') end, { desc = 'Around Class' })
      vim.keymap.set({ 'o', 'x' }, 'ic', function() select_node('class', 'V') end, { desc = 'Inside Class' })
    end,
  },

  -- Incremental selection
  {
    "nvim-treesitter/nvim-treesitter",
    keys = {
      { "<c-space>", desc = "Increment Selection", mode = { "n", "x" } },
      { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    config = function()
      -- Implement incremental selection with native treesitter
      vim.keymap.set({ 'n', 'x' }, '<C-space>', function()
        local mode = vim.fn.mode()
        if mode == 'n' then
          -- Start selection
          vim.cmd('normal! viw')
        else
          -- Expand selection using treesitter
          local cursor = vim.api.nvim_win_get_cursor(0)
          local row, col = cursor[1] - 1, cursor[2]

          local node = vim.treesitter.get_node({ pos = { row, col } })
          if node then
            local parent = node:parent()
            if parent then
              local start_row, start_col, end_row, end_col = parent:range()
              vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
              vim.cmd('normal! v')
              vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
            end
          end
        end
      end, { desc = 'Increment Selection' })

      vim.keymap.set('x', '<bs>', function()
        -- Shrink selection
        vim.cmd('normal! o')
      end, { desc = 'Decrement Selection' })
    end,
  },
}
