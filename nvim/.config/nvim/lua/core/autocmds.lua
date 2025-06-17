local function augroup(name)
    return vim.api.nvim_create_augroup('nvim_aug' .. name, { clear = true })
end

-- Strip trailing spaces before write
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    group = augroup('strip_space'),
    pattern = { '*' },
    callback = function()
        vim.cmd([[ %s/\s\+$//e ]])
    end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
    group = augroup('checktime'),
    command = 'checktime',
})

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup('highlight_yank'),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("keymaps-lsp-attach"),
  callback = function()

    -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            vim.keymap.set("n", "<leader>uh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, { desc = "Toggle [U]i Inlay [H]ints" })
          end
    -- Jump to the definition of the word under your cursor.
    --  This is where a variable was first declared, or where a function is defined, etc.
    --  To jump back, press <C-t>.

    --
    -- All of the follwoing gX keybindings are a little more
    -- involved, as we are checking first if there is only one
    -- match. If there is we directly go there. Otherwise we open
    -- fzf-lua for the results.
    --

    -- [G]oto [D]efinition(s)
    vim.keymap.set("n", "gd", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
        local items = result
        if type(result) == "table" and result.result then
          items = result.result
        end

        if not items or vim.tbl_isempty(items) then
          vim.notify("No definition found", vim.log.levels.ERROR)
        elseif #items == 1 then
          vim.lsp.buf.definition(params)
        else
          require("fzf-lua").lsp_definitions()
        end
      end)
    end, { desc = "[G]oto [D]efinition(s)" })

    -- Unmap default gr* since 0.11
    local gr_mappings = { "grr", "gra", "gri", "grn" }
    for _, keymap in ipairs(gr_mappings) do
      pcall(function()
        vim.keymap.del("n", keymap)
      end)
    end

    -- [G]oto [R]eference(s)
    vim.keymap.set("n", "gr", function()
      require("fzf-lua").lsp_references()
    end, { desc = "[G]oto [R]eference(s)" })

    -- [G]oto [I]mplementation(s)
    vim.keymap.set("n", "gI", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/implementation", params, function(_, result)
        local items = result
        if type(result) == "table" and result.result then
          items = result.result
        end

        if not items or vim.tbl_isempty(items) then
          vim.notify("No implementation found", vim.log.levels.ERROR)
        elseif #items == 1 then
          vim.lsp.buf.implementation(params)
        else
          require("fzf-lua").lsp_implementations()
        end
      end)
    end, { desc = "[G]oto [I]mplementation(s)" })

    -- [G]oto [D]eclaration
    vim.keymap.set("n", "gD", function()
      -- Check if declaration is supported
      local clients = vim.lsp.get_active_clients({ bufnr = 0 })
      local has_support = false
      for _, client in ipairs(clients) do
        if client.supports_method("textDocument/declaration") then
          has_support = true
          break
        end
      end

      if not has_support then
        vim.notify("LSP method textDocument/declaration not supported", vim.log.levels.ERROR)
        return
      end

      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/declaration", params, function(_, result)
        local items = result
        if type(result) == "table" and result.result then
          items = result.result
        end

        if not items or vim.tbl_isempty(items) then
          vim.notify("No declaration found", vim.log.levels.ERROR)
        elseif #items == 1 then
          vim.lsp.buf.declaration(params)
        else
          require("fzf-lua").lsp_declarations()
        end
      end)
    end, { desc = "[G]oto [D]eclaration" })

    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    vim.keymap.set("n", "<leader>D", require("fzf-lua").lsp_typedefs, { desc = "Type [D]efinition" })

    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "[R]ename" })

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ction" })
  end,
})
