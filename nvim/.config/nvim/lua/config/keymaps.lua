local mapkey = require("util.keymapper").mapvimkey


local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end
local opts = { noremap = true, silent = true }


mapkey("-", "Oil", "n")                -- open oil explorer
-- Buffer Navigation
mapkey("<leader>bn", "bnext", "n")     -- Next buffer
mapkey("<leader>bp", "bprevious", "n") -- Prev buffer
mapkey("<leader>bb", "e #", "n")       -- Switch to Other Buffer
mapkey("<leader>`", "e #", "n")        -- Switch to Other Buffer

-- Directory Navigatio}n
mapkey("<leader>m", "NvimTreeFocus", "n")
mapkey("<leader>e", "NvimTreeToggle", "n")

-- Pane and Window Navigation
mapkey("<C-h>", "<C-w>h", "n")   -- Navigate Left
mapkey("<C-j>", "<C-w>j", "n")   -- Navigate Down
mapkey("<C-k>", "<C-w>k", "n")   -- Navigate Up
mapkey("<C-l>", "<C-w>l", "n")   -- Navigate Right
mapkey("<C-h>", "wincmd h", "t") -- Navigate Left
mapkey("<C-j>", "wincmd j", "t") -- Navigate Down
mapkey("<C-k>", "wincmd k", "t") -- Navigate Up
mapkey("<C-l>", "wincmd l", "t") -- Navigate Right
-- mapkey("<C-h>", "TmuxNavigateLeft", "n")  -- Navigate Left
-- mapkey("<C-j>", "TmuxNavigateDown", "n")  -- Navigate Down
-- mapkey("<C-k>", "TmuxNavigateUp", "n")    -- Navigate Up
-- mapkey("<C-l>", "TmuxNavigateRight", "n") -- Navigate Right

-- Window Management
mapkey("<leader>sv", "vsplit", "n") -- Split Vertically
mapkey("<leader>sh", "split", "n")  -- Split Horizontally
mapkey("<C-Up>", "resize +2", "n")
mapkey("<C-Down>", "resize -2", "n")
mapkey("<C-Left>", "vertical resize +2", "n")
mapkey("<C-Right>", "vertical resize -2", "n")

-- Show Full File-Path
mapkey("<leader>pa", "ShowPath", "n") -- Show Full File Path

-- Indenting
vim.keymap.set("v", "<", "<gv", { silent = true, noremap = true })
vim.keymap.set("v", ">", ">gv", { silent = true, noremap = true })

-- Visual overwrite paste
map({ 'v', 'x' }, 'p', '"_dP', opts)

-- Do not copy on x
map({ 'v', 'x' }, 'x', '"_x', opts)


-- Move to line beginning and end
map({ 'n', 'v', 'x' }, 'gl', '$', { desc = 'End of line' })
map({ 'n', 'v', 'x' }, 'gh', '^', { desc = 'Beginning of line' })

-- Better up/down
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move text up and down
map({ 'v', 'x' }, 'J', ":move '>+1<CR>gv-gv", opts)
map({ 'v', 'x' }, 'K', ":move '<-2<CR>gv-gv", opts)

-- save file
mapkey('<C-s>', 'w', 'n', opts)

-- save file without auto-formatting
mapkey('<leader>sn', 'noautocmd', 'n', opts)

-- quit file
mapkey('<C-q>', 'q', 'n', opts)

-- Vertical scroll and center
map('n', '<C-d>', '<C-d>zz', opts)
map('n', '<C-u>', '<C-u>zz', opts)

-- Find and center
map('n', 'n', 'nzzzv', opts)
map('n', 'N', 'Nzzzv', opts)

-- Resize with arrows
mapkey('<Up>', ':resize -2', 'n', opts)
mapkey('<Down>', ':resize +2', 'n', opts)
mapkey('<Left>', ':vertical resize -2', 'n', opts)
mapkey('<Right>', ':vertical resize +2', 'n', opts)

-- Buffers
mapkey('<Tab>', ':bnext', 'n', opts)
mapkey('<S-Tab>', ':bprevious', 'n', opts)
mapkey('<leader>x', ':bdelete!', 'n', opts)   -- close buffer
mapkey('<leader>b', '<cmd> enew ', 'n', opts) -- new buffer

local api = vim.api

-- Comments

if vim.env.TMUX ~= nil then
  api.nvim_set_keymap("n", "<C-_>", "gtc", { noremap = false })
  api.nvim_set_keymap("v", "<C-_>", "goc", { noremap = false })
else
  api.nvim_set_keymap("n", "<C-/>", "gtc", { noremap = false })
  api.nvim_set_keymap("v", "<C-/>", "goc", { noremap = false })
end
