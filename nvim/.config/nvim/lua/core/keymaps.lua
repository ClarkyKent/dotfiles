local mapkey = require("utils.keymapper").mapvimkey
local maplazykey = require("utils.keymapper").maplazykey
local mapcmd = require("utils.keymapper").mapcmd
local mapkey_general = require("utils.keymapper").mapkey_general


-- Oil
mapcmd('n', '-', "Oil --float", { desc = "Open parent directory" })

-- save file
mapcmd('n', '<C-s>', 'w', { desc = "Save file" })

-- quit file
mapcmd('n', '<C-q>', 'q', { desc = "Quit file" })

-- Show current diagnostic in a float
mapkey_general("gl", vim.diagnostic.open_float, "n", { desc = "Show Diagnostic" })

-- Toggle diagnostic view
mapkey_general("<Leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, "n", { desc = "Toggle [D]iagnostics" })


-- Jump between markdown headers
mapkey_general("gj", [[/^##\+ .*<CR>]], "n", { buffer = true, silent = true })
mapkey_general("gk", [[?^##\+ .*<CR>]], "n", { buffer = true, silent = true })

-- Exit insert mode without hitting Esc
mapkey_general("jj", "<Esc><Esc>", "i", { desc = "Esc" })

-- Make Y behave like C or D
mapkey_general("Y", "y$", "n")

-- Select all
mapkey_general("==", "gg<S-v>G", "n")

-- Keep window centered when going up/down
mapkey_general("J", "mzJ`z", "n")
mapkey_general("<C-d>", "<C-d>zz", "n")
mapkey_general("<C-u>", "<C-u>zz", "n")
mapkey_general("n", "nzzzv", "n")
mapkey_general("N", "Nzzzv", "n")

-- delete single character without copying into register
mapkey_general('x', '"_x', {'n', 'v', 'x'}, { desc = "Delete without yanking" })
-- Keep last yanked when pasting
-- Visual overwrite paste
mapkey_general('p', '"_dP', { 'v', 'x' }, { desc = "Paste without yanking" })

-- Copy text to " register
mapkey_general("<leader>y", "\"+y", { 'v', 'n' }, { desc = "Yank into \" register" })
-- vim.keymap.set("v", "<leader>y", "\"+y", { desc = "Yank into \" register" })
mapkey_general("<leader>Y", "\"+Y", "n", { desc = "Yank into \" register" })

-- Delete text to " register
mapkey_general("<leader>d", "\"_d", { 'n', 'v' }, { desc = "Delete into \" register" })
-- vim.keymap.set("v", "<leader>d", "\"_d", { desc = "Delete into \" register" })

-- Get out Q
mapkey_general("Q", "<nop>", "n")

-- Delete words with CTRL-Backspace/Alt-Backspace in insert mode
mapkey_general("<C-BS>", "<C-w>", "i", { desc = "Delete word backward" })
mapkey_general("<C-BS>", "<C-w>", "x", { desc = "Delete word backward" })
mapkey_general("<M-BS>", "<C-w>", "i", { desc = "Delete word backward" })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
mapcmd("n", "<Esc>", "nohlsearch", { desc = "Clear search highlights" })
-- Buffers
mapcmd('n', '<Tab>', 'bnext', { desc = "Next Buffer" })
mapcmd('n', '<S-Tab>', 'bprevious', { desc = "Prev Buffer" })
mapcmd('n', '<leader>b', 'enew', { desc = "New Buffer" }) -- new buffer


-- Close buffer without closing split
mapcmd("n", "<leader>w", "bp|bd #", { desc = "Close Buffer; Retain Split" })

-- Navigate between quickfix items
mapcmd("n", "<leader>h", "cnext", { desc = "Forward qfixlist" })
mapcmd("n", "<leader>;", "cprev", { desc = "Backward qfixlist" })

-- Navigate between location list items
mapcmd("n", "<leader>k", "lnext", { desc = "Forward location list" })
mapcmd("n", "<leader>j", "lprev", { desc = "Backward location list" })

-- Replace word under cursor across entire buffer
mapkey_general("<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "n",
  { desc = "Replace word under cursor" })


-- Jump to plugin management file
mapcmd("n", "<leader>vpp", "e ~/.config/nvim/lua/plugins.lua", { desc = "Jump to configuration file" })

-- Run Tests
-- vim.keymap.set("n", "<leader>t", "<cmd>lua require('neotest').run.run()<CR>", { desc = "Run Test" })
-- vim.keymap.set("n", "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>",
--   { desc = "Run Test File" })
-- vim.keymap.set("n", "<leader>td", "<cmd>lua require('neotest').run.run(vim.fn.getcwd())<CR>",
--   { desc = "Run Current Test Directory" })
-- vim.keymap.set("n", "<leader>tp", "<cmd>lua require('neotest').output_panel.toggle()<CR>",
--   { desc = "Toggle Test Output Panel" })
-- vim.keymap.set("n", "<leader>tl", "<cmd>lua require('neotest').run.run_last()<CR>", { desc = "Run Last Test" })
-- vim.keymap.set("n", "<leader>ts", "<cmd>lua require('neotest').summary.toggle()<CR>", { desc = "Toggle Test Summary" })

-- Debug Tests
-- vim.keymap.set("n", "<leader>dt", "<cmd>DapContinue<CR>", { desc = "Start Debugging" })
-- vim.keymap.set("n", "<leader>dc", "<cmd>DapContinue<CR>", { desc = "Start Debugging" })
-- vim.keymap.set("n", "<leader>dso", "<cmd>DapStepOver<CR>", { desc = "Step Over" })
-- vim.keymap.set("n", "<leader>dsi", "<cmd>DapStepInto<CR>", { desc = "Step Into" })
-- vim.keymap.set("n", "<leader>dsu", "<cmd>DapStepOut<CR>", { desc = "Step Out" })
-- vim.keymap.set("n", "<leader>dst", "<cmd>DapStepTerminate<CR>", { desc = "Stop Debugger" })
-- vim.keymap.set("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Toggle Breakpoint" })
-- vim.keymap.set("n", "<leader>dB", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
--   { desc = "Toggle Breakpoint Condition" })
-- vim.keymap.set("n", "<leader>E", "<cmd>lua require'dap'.set_exception_breakpoints()<CR>",
--   { desc = "Toggle Exception Breakpoint" })
-- vim.keymap.set("n", "<leader>dr",
--   "<cmd>lua require'dapui'.float_element('repl', { width = 100, height = 40, enter = true })<CR>",
--   { desc = "Show DAP REPL" })
-- vim.keymap.set("n", "<leader>ds",
--   "<cmd>lua require'dapui'.float_element('scopes', { width = 150, height = 50, enter = true })<CR>",
--   { desc = "Show DAP Scopes" })
-- vim.keymap.set("n", "<leader>df",
--   "<cmd>lua require'dapui'.float_element('stacks', { width = 150, height = 50, enter = true })<CR>",
--   { desc = "Show DAP Stacks" })
-- vim.keymap.set("n", "<leader>db", "<cmd>lua require'dapui'.float_element('breakpoints', { enter = true })<CR>",
--   { desc = "Show DAP breakpoints" })
-- vim.keymap.set("n", "<leader>do", "<cmd>lua require'dapui'.toggle()<CR>", { desc = "Toggle DAP UI" })
-- vim.keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<CR>", { desc = "Debug Last Test" })

-- Copy file paths
mapkey("<leader>cf", "let @+ = expand(\"%\")", "n", { desc = "Copy File Name" })
mapkey("<leader>cp", "let @+ = expand(\"%:p\")", "n", { desc = "Copy File Path" })


-- Dismiss Noice Message
mapcmd("n", "<leader>nd", "NoiceDismiss", { desc = "Dismiss Noice Message" })

-- Open Zoxide telescope extension
mapcmd("n", "<leader>Z", "Zi", { desc = "Open Zoxide" })

-- Resize with arrows
mapcmd("n", "<C-S-Down>", "resize +2", { desc = "Resize Horizontal Split Down" })
mapcmd("n", "<C-S-Up>", "resize -2", { desc = "Resize Horizontal Split Up" })
mapcmd("n", "<C-Left>", "vertical resize -2", { desc = "Resize Vertical Split Down" })
mapcmd("n", "<C-Right>", "vertical resize +2", { desc = "Resize Vertical Split Up" })

-- Obsidian
-- vim.keymap.set("n", "<leader>oc", "<cmd>lua require('obsidian').util.toggle_checkbox()<CR>",
--   { desc = "Obsidian Check Checkbox" })
-- vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianTemplate<CR>", { desc = "Insert Obsidian Template" })
-- vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", { desc = "Open in Obsidian App" })
-- vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Show ObsidianBacklinks" })
-- vim.keymap.set("n", "<leader>ol", "<cmd>ObsidianLinks<CR>", { desc = "Show ObsidianLinks" })
-- vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "Create New Note" })
-- vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search Obsidian" })
-- vim.keymap.set("n", "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Quick Switch" })

-- FZF related general keymaps
local fzf = require("fzf-lua")
mapkey_general("<leader>fh", fzf.helptags, "n", { desc = "[F]ind [H]elp" })
mapkey_general("<leader>fk", fzf.keymaps, "n", { desc = "[F]ind [K]eymaps" })
mapkey_general("<leader>ff", fzf.files, "n", { desc = "[F]ind [F]iles" })
mapcmd("n", "<leader>fp", "FzfDirectories", { desc = "[F]ind [P]aths" })
mapkey_general("<leader>fb", fzf.builtin, "n", { desc = "[F]ind [B]uiltin FZF" })
mapkey_general("<leader>fw", fzf.grep_cword, "n", { desc = "[F]ind current [W]ord" })
mapkey_general("<leader>fW", fzf.grep_cWORD, "n", { desc = "[F]ind current [W]ORD" })
mapkey_general("<leader>fG", fzf.live_grep, "n", { desc = "[F]ind by Live [G]rep" })
mapkey_general("<leader>fg", fzf.grep_project, "n", { desc = "[F]ind by [G]rep" })
mapkey_general("<leader>fd", fzf.diagnostics_document, "n", { desc = "[F]ind [D]iagnostics" })
mapkey_general("<leader>fr", fzf.resume, "n", { desc = "[F]ind [R]esume" })
mapkey_general("<leader>fo", fzf.oldfiles, "n", { desc = "[F]ind [O]ld Files" })
mapkey_general("<leader><leader>", fzf.buffers, "n", { desc = "[,] Find existing buffers" })
mapkey_general("<leader>/", fzf.lgrep_curbuf, "n", { desc = "[/] Live grep the current buffer" })
mapkey_general("<leader>fS", require("fzf-lua").lsp_workspace_symbols, "n", { desc = "[F]ind Workspace [S]ymbols" })
mapkey_general("<leader>fs", require("fzf-lua").lsp_document_symbols, "n", { desc = "[F]ind Document [S]ymbols" })
-- Search in neovim config
mapkey_general("<leader>fc", function()
  fzf.files({ cwd = vim.fn.stdpath("config") })
end, "n", { desc = "[F]ind Neovim [C]onfig files" })
-- Search in my dotfiles config
mapkey_general("<leader>fd", function()
  fzf.files({ cwd = os.getenv("HOME") .. "/dotfiles" })
end, "n", { desc = "[F]ind [D]otfiles" })
-- Search in TODOs, FIXMEs, HACKs, via todo-comments.nvim
mapkey_general("<leader>ft", function()
  require("todo-comments.fzf").todo()
end, "n", { desc = "[F]ind [T]odos, Fixmes, Hacks, ..." })
-- Navigate between TODOs and such
mapkey_general("]t", function()
  require("todo-comments").jump_next()
end, "n", { desc = "Next todo comment" })
mapkey_general("[t", function()
  require("todo-comments").jump_prev()
end, "n", { desc = "Previous todo comment" })

-- Visual --
-- Stay in indent mode
mapkey_general("<", "<gv", "v")
mapkey_general(">", ">gv", "v")

mapkey_general("<s-h>", "^", { "n", "o", "x" }, { desc = "Jump to beginning of line" })
mapkey_general("<s-l>", "g_", { "n", "o", "x" }, { desc = "Jump to end of line" })

-- Toggle line wrapping
mapcmd('n', '<leader>lw', 'set wrap!', { desc = "Toggle line wrapping" })

-- Move block
mapkey_general("J", ":m '>+1<CR>gv=gv", "v", { desc = "Move Block Down" })
mapkey_general("K", ":m '<-2<CR>gv=gv", "v", { desc = "Move Block Up" })

-- Search for highlighted text in buffer
mapkey_general("//", 'y/<C-R>"<CR>', "v", { desc = "Search for highlighted text" })

-- Exit terminal mode shortcut
mapkey_general("<C-t>", "<C-\\><C-n>", "t")

