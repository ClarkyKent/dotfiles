-- require "nvchad.mappings"
local mapkey = require("utils.keymapper").mapvimkey
local maplazykey = require("utils.keymapper").maplazykey
local mapcmd = require("utils.keymapper").mapcmd
local mapkey_general = require("utils.keymapper").mapkey_general

local map = vim.keymap.set

map("i", "<C-b>", "<ESC>^i", { desc = "move beginning of line" })
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-h>", "<Left>", { desc = "move left" })
map("i", "<C-l>", "<Right>", { desc = "move right" })
map("i", "<C-j>", "<Down>", { desc = "move down" })
map("i", "<C-k>", "<Up>", { desc = "move up" })

map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

map({ "n", "x" }, "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "general format file" })

-- global lsp mappings
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

-- tabufline
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })

map("n", "<tab>", function()
  require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

map("n", "<S-tab>", function()
  require("nvchad.tabufline").prev()
end, { desc = "buffer goto prev" })

map("n", "<leader>x", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "buffer close" })

-- Comment
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- nvimtree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })

-- FZF related general keymaps
local fzf = require "fzf-lua"
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
  fzf.files { cwd = vim.fn.stdpath "config" }
end, "n", { desc = "[F]ind Neovim [C]onfig files" })
-- Search in my dotfiles config
mapkey_general("<leader>fd", function()
  fzf.files { cwd = os.getenv "HOME" .. "/dotfiles" }
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

map("n", "<leader>th", function()
  require("nvchad.themes").open()
end, { desc = "telescope nvchad themes" })

-- terminal
map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

-- new terminals
map("n", "<leader>h", function()
  require("nvchad.term").new { pos = "sp" }
end, { desc = "terminal new horizontal term" })

map("n", "<leader>v", function()
  require("nvchad.term").new { pos = "vsp" }
end, { desc = "terminal new vertical term" })

-- toggleable
map({ "n", "t" }, "<A-v>", function()
  require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "terminal toggleable vertical term" })

map({ "n", "t" }, "<A-h>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "terminal toggleable horizontal term" })

map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "terminal toggle floating term" })

-- whichkey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Visual --
-- Stay in indent mode
mapkey_general("<", "<gv", "v")
mapkey_general(">", ">gv", "v")

mapkey_general("<s-h>", "^", { "n", "o", "x" }, { desc = "Jump to beginning of line" })
mapkey_general("<s-l>", "g_", { "n", "o", "x" }, { desc = "Jump to end of line" })

-- Move block
mapkey_general("J", ":m '>+1<CR>gv=gv", "v", { desc = "Move Block Down" })
mapkey_general("K", ":m '<-2<CR>gv=gv", "v", { desc = "Move Block Up" })

-- Search for highlighted text in buffer
mapkey_general("//", 'y/<C-R>"<CR>', "v", { desc = "Search for highlighted text" })
