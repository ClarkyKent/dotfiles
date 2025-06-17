-- Disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })


local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- For conciseness
local opts = { noremap = true, silent = true }


vim.keymap.set('n', '-', '<cmd>Oil --float <CR>', {desc = "Open parent directory" })
-- save file
vim.keymap.set('n', '<C-s>', '<cmd> w <CR>', opts)

-- save file without auto-formatting
vim.keymap.set('n', '<leader>sn', '<cmd>noautocmd w <CR>', opts)

-- Show current diagnostic in a float
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show Diagnostic" })

-- Toggle diagnostic view
vim.keymap.set("n", "<Leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle [D]iagnostics" })


-- quit file
vim.keymap.set('n', '<C-q>', '<cmd> q <CR>', opts)

-- delete single character without copying into register
map({'n', 'v', 'x' }, 'x', '"_x', opts)
-- Keep last yanked when pasting
-- Visual overwrite paste
map({ 'v', 'x' }, 'p', '"_dP', opts)

-- Move text up and down
map({ 'v', 'x' }, 'J', ":move '>+1<CR>gv-gv", opts)
map({ 'v', 'x' }, 'K', ":move '<-2<CR>gv-gv", opts)

-- Find and center
map('n', 'n', 'nzzzv', opts)
map('n', 'N', 'Nzzzv', opts)

-- Vertical scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- Resize with arrows
vim.keymap.set('n', '<Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>', opts)

-- Delete words with CTRL-Backspace/Alt-Backspace in insert mode
vim.keymap.set("i", "<C-BS>", "<C-w>", opts)
vim.keymap.set("x", "<C-BS>", "<C-w>", opts)
vim.keymap.set("i", "<M-BS>", "<C-w>", opts)

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Buffers
vim.keymap.set('n', '<Tab>', ':bnext<CR>', opts)
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', opts)
vim.keymap.set('n', '<leader>x', ':bdelete!<CR>', opts) -- close buffer
vim.keymap.set('n', '<leader>b', '<cmd> enew <CR>', opts) -- new buffer

-- Window management
vim.keymap.set('n', '<leader>v', '<C-w>v', opts) -- split window vertically
vim.keymap.set('n', '<leader>h', '<C-w>s', opts) -- split window horizontally
vim.keymap.set('n', '<leader>se', '<C-w>=', opts) -- make split windows equal width & height
vim.keymap.set('n', '<leader>xs', ':close<CR>', opts) -- close current split window

-- Navigate between splits
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', opts)
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', opts)
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', opts)
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', opts)

-- Tabs
vim.keymap.set('n', '<leader>to', ':tabnew<CR>', opts) -- open new tab
vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', opts) -- close current tab
vim.keymap.set('n', '<leader>tn', ':tabn<CR>', opts) --  go to next tab
vim.keymap.set('n', '<leader>tp', ':tabp<CR>', opts) --  go to previous tab

-- Toggle line wrapping
vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', opts)

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)



-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
-- vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "jj", "<Esc>", { desc = "Press <Esc>" })
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("v", "jj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("t", "jj", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("x", "jj", "<C-\\><C-n>", { desc = "Exit terminal mode" })


-- FZF related general keymaps
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "[F]ind [K]eymaps" })
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "[F]ind [F]iles" })
vim.keymap.set("n", "<leader>fp", "<cmd>FzfDirectories<CR>", { desc = "[F]ind [P]aths" })
vim.keymap.set("n", "<leader>fb", fzf.builtin, { desc = "[F]ind [B]uiltin FZF" })
vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "[F]ind current [W]ord" })
vim.keymap.set("n", "<leader>fW", fzf.grep_cWORD, { desc = "[F]ind current [W]ORD" })
vim.keymap.set("n", "<leader>fG", fzf.live_grep, { desc = "[F]ind by Live [G]rep" })
vim.keymap.set("n", "<leader>fg", fzf.grep_project, { desc = "[F]ind by [G]rep" })
vim.keymap.set("n", "<leader>fd", fzf.diagnostics_document, { desc = "[F]ind [D]iagnostics" })
vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "[F]ind [R]esume" })
vim.keymap.set("n", "<leader>fo", fzf.oldfiles, { desc = "[F]ind [O]ld Files" })
vim.keymap.set("n", "<leader><leader>", fzf.buffers, { desc = "[,] Find existing buffers" })
vim.keymap.set("n", "<leader>/", fzf.lgrep_curbuf, { desc = "[/] Live grep the current buffer" })
vim.keymap.set("n", "<leader>fS", require("fzf-lua").lsp_workspace_symbols, { desc = "[F]ind Workspace [S]ymbols" })
vim.keymap.set("n", "<leader>fs", require("fzf-lua").lsp_document_symbols, { desc = "[F]ind Document [S]ymbols" })

-- Search in neovim config
vim.keymap.set("n", "<leader>fc", function()
  fzf.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[F]ind Neovim [C]onfig files" })
-- Search in my dotfiles config
vim.keymap.set("n", "<leader>fd", function()
  fzf.files({ cwd = os.getenv("HOME") .. "/dotfiles" })
end, { desc = "[F]ind [D]otfiles" })
-- Search in TODOs, FIXMEs, HACKs, via todo-comments.nvim
vim.keymap.set("n", "<leader>ft", function()
  require("todo-comments.fzf").todo()
end, { desc = "[F]ind [T]odos, Fixmes, Hacks, ..." })
-- Navigate between TODOs and such
vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })
vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- Toggle undotree
-- FIXME: Maybe there is a faster more current way of showing this undo history?
vim.keymap.set("n", "<leader>uu", function()
  vim.cmd.UndotreeToggle()
end, { remap = false, desc = "Toggle [U]ndoTree [U]i" })

-- Toggle copilot completion on <leader>uc
vim.keymap.set("n", "<leader>uc", function()
  vim.g.copilot_completion_enabled = not vim.g.copilot_completion_enabled
  if vim.g.copilot_completion_enabled then
    vim.cmd("Copilot enable")
  else
    vim.cmd("Copilot disable")
  end
end, { desc = "Toggle [C]opilot" })