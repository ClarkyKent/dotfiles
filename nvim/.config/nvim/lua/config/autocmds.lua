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
    vim.hl.on_yank()
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

-- ── Filetype detection for embedded / firmware formats ──────────────────
-- Neovim has no builtin rules for several formats this project uses daily.
vim.filetype.add({
  extension = {
    -- Linker scripts. `ld` gets a treesitter parser (linkerscript).
    ld = "ld",
    lds = "ld",
    icf = "ld", -- IAR linker config
    sct = "ld", -- ARM scatter file
    -- ARM assembly. Neovim guesses `asm`; force the GNU dialect used here.
    s = "asm",
    S = "asm",
    -- Device tree
    dts = "dts",
    dtsi = "dts",
    overlay = "dts",
    -- Map files from the linker
    map = "mapfile",
    -- Robot Framework resource files
    resource = "robot",
    -- Renode platform / script files
    repl = "renode",
    resc = "renode",
  },
  filename = {
    [".justfile"] = "just",
    ["justfile"] = "just",
    ["Justfile"] = "just",
    ["Kconfig"] = "kconfig",
    ["gcovr.cfg"] = "cfg",
    ["meson.options"] = "meson",
    ["meson_options.txt"] = "meson",
    [".clangd"] = "yaml",
    [".clang-tidy"] = "yaml",
    [".clang-format"] = "yaml",
    ["sonar-project.properties"] = "jproperties",
  },
  pattern = {
    -- Meson configure_file templates are not valid C -- keep clang-format and
    -- the C treesitter parser away from them.
    [".*%.h%.in"] = "config",
    [".*%.c%.in"] = "config",
    [".*/%.vscode/.*%.json"] = "jsonc",
  },
})

-- LSP Keymaps (attached when LSP is active)
--
-- Neovim 0.11+ ships defaults under the `gr` prefix: grn (rename), gra (code
-- action), grr (references), gri (implementation), grt (type definition) and
-- gO (document symbols). Mapping `gr` itself -- as this config used to -- makes
-- every one of those unreachable, because a complete buffer-local mapping wins
-- over longer global ones. Only genuinely missing bindings are added here.
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("lsp_keymaps"),
  callback = function(args)
    local buffer = args.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
    end

    -- Navigation
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "gK", vim.lsp.buf.signature_help, "Signature help")
    map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")

    -- Leader aliases for the native gr* defaults, for discoverability.
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
    map("n", "<leader>cR", vim.lsp.buf.references, "References")

    -- Diagnostics
    map("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, "Prev diagnostic")
    map("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, "Next diagnostic")
    map("n", "[e", function()
      vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
    end, "Prev error")
    map("n", "]e", function()
      vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR })
    end, "Next error")
    map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")

    -- Toggle inlay hints
    map("n", "<leader>uh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buffer }), { bufnr = buffer })
    end, "Toggle inlay hints")

    -- Document highlight under cursor is handled by vim-illuminate.
  end,
})
