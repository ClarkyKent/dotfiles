-- Enhanced keymaps based on LazyVim configuration
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- Better up/down movement for wrapped lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Buffer deletion (using bdelete for now, can be enhanced with Snacks later)
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Delete Buffer (Force)" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- Clear search, diff update and redraw
map("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redraw / Clear hlsearch / Diff Update" })

-- Search word under cursor
map("n", "gw", "*N", { desc = "Search Word Under Cursor" })
map("x", "gw", "*N", { desc = "Search Word Under Cursor" })

-- Better search result navigation
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- Keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- Lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- New file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- Location and quickfix lists
map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Previous Quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next Quickfix" })

-- Diagnostic keymaps
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Next Error" })
map("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Prev Error" })
map("n", "]w", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN }) end, { desc = "Next Warning" })
map("n", "[w", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN }) end, { desc = "Prev Warning" })

-- Formatting
map({ "n", "v" }, "<leader>cf", function()
  -- Try conform.nvim first, fallback to LSP
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ lsp_fallback = true })
  else
    vim.lsp.buf.format()
  end
end, { desc = "Format" })

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })

-- Terminal Mappings
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- Windows
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- Tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Toggle options (basic versions, can be enhanced with plugins)
map("n", "<leader>uf", function()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify("Autoformat " .. (vim.g.autoformat and "enabled" or "disabled"))
end, { desc = "Toggle Auto Format" })

map("n", "<leader>us", function()
  vim.opt.spell = not vim.opt.spell:get()
  vim.notify("Spell " .. (vim.opt.spell:get() and "enabled" or "disabled"))
end, { desc = "Toggle Spelling" })

map("n", "<leader>uw", function()
  vim.opt.wrap = not vim.opt.wrap:get()
  vim.notify("Wrap " .. (vim.opt.wrap:get() and "enabled" or "disabled"))
end, { desc = "Toggle Word Wrap" })

map("n", "<leader>uL", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
  vim.notify("Relative numbers " .. (vim.opt.relativenumber:get() and "enabled" or "disabled"))
end, { desc = "Toggle Relative Line Numbers" })

map("n", "<leader>ul", function()
  vim.opt.number = not vim.opt.number:get()
  vim.notify("Line numbers " .. (vim.opt.number:get() and "enabled" or "disabled"))
end, { desc = "Toggle Line Numbers" })

map("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
  vim.notify("Diagnostics " .. (vim.diagnostic.is_enabled() and "enabled" or "disabled"))
end, { desc = "Toggle Diagnostics" })

map("n", "<leader>uc", function()
  local conceallevel = vim.opt.conceallevel:get()
  if conceallevel > 0 then
    vim.opt.conceallevel = 0
    vim.notify("Conceal disabled")
  else
    vim.opt.conceallevel = 2
    vim.notify("Conceal enabled")
  end
end, { desc = "Toggle Conceal Level" })

map("n", "<leader>ub", function()
  local bg = vim.opt.background:get()
  vim.opt.background = bg == "dark" and "light" or "dark"
  vim.notify("Background: " .. vim.opt.background:get())
end, { desc = "Toggle Background" })

-- File operations
map("n", "<leader>fs", "<cmd>w<cr>", { desc = "Save File" })
map("n", "<leader>fS", "<cmd>wa<cr>", { desc = "Save All Files" })

-- Window operations
map("n", "<leader>ww", "<C-W>p", { desc = "Other Window", remap = true })
map("n", "<leader>wc", "<C-W>c", { desc = "Delete Window", remap = true })

-- Improved search and replace
map("n", "<leader>sr", ":%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Search and Replace" })
map("v", "<leader>sr", ":s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Search and Replace" })

-- Better command line editing
map("c", "<C-a>", "<Home>", { desc = "Beginning of line" })
map("c", "<C-e>", "<End>", { desc = "End of line" })

-- Improved clipboard operations
map("n", "<leader>y", '"+y', { desc = "Yank to System Clipboard" })
map("v", "<leader>y", '"+y', { desc = "Yank to System Clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank Line to System Clipboard" })
map("n", "<leader>p", '"+p', { desc = "Paste from System Clipboard" })
map("v", "<leader>p", '"+p', { desc = "Paste from System Clipboard" })

-- Legacy keymaps for compatibility (remapped to avoid which-key conflicts)
map("n", "<leader>W", "<cmd>w<cr>", { desc = "Save File" })  -- Capital W to avoid conflict
map("n", "<leader>Q", "<cmd>q<cr>", { desc = "Quit" })       -- Capital Q to avoid conflict  
map("n", "<leader>X", "<cmd>bdelete<cr>", { desc = "Delete Buffer" }) -- Capital X to avoid conflict

-- Additional useful keymaps
map("v", "p", '"_dP', { desc = "Paste without overwriting register" })