-- Autocmds
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  command = "checktime",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "checkhealth",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Enable spell checking for documentation files
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("spell_check"),
  pattern = { "markdown", "rst", "text", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})

-- LSP Keymaps (attached when LSP is active)
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("lsp_keymaps"),
  callback = function(args)
    local buffer = args.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
    end

    -- Navigation
    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
    map("n", "gI", vim.lsp.buf.implementation, "Go to Implementation")
    map("n", "gy", vim.lsp.buf.type_definition, "Go to Type Definition")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
    map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

    -- Code actions
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("v", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")

    -- Diagnostics
    map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
    map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")

    -- Format (if no conform.nvim)
    map({ "n", "v" }, "<leader>cf", function()
      vim.lsp.buf.format({ async = true })
    end, "Format")

    -- Toggle inlay hints
    if vim.lsp.inlay_hint then
      map("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buffer }), { bufnr = buffer })
      end, "Toggle Inlay Hints")
    end
  end,
})
