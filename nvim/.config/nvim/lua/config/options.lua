-- Enhanced options based on LazyVim configuration
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Set leader keys first
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- LazyVim globals
vim.g.autoformat = true -- enable auto-formatting
vim.g.lazyvim_picker = "auto" -- picker to use
vim.g.lazyvim_cmp = "auto" -- completion engine to use

local opt = vim.opt

-- Basic editing options
opt.autoindent = true          -- copy indent from current line
opt.autowrite = true           -- enable auto write
opt.backup = false            -- disable backup
opt.clipboard = "unnamedplus" -- sync with system clipboard
opt.completeopt = "menu,menuone,noselect" -- completion options
opt.conceallevel = 2          -- hide * markup for bold and italic
opt.confirm = true            -- confirm to save changes before exiting modified buffer
opt.cursorline = true         -- enable highlighting of the current line
opt.expandtab = true          -- use spaces instead of tabs
opt.fillchars = {
  foldopen = "-",
  foldclose = "+",
  fold = " ",
  foldsep = " ",
  diff = "/",
  eob = " ",
}
-- opt.formatexpr = "v:lua.LazyVim.format.formatexpr()" -- disabled - requires LazyVim
opt.formatoptions = "jcroqlnt" -- format options
opt.grepformat = "%f:%l:%c:%m" -- format for grep
opt.grepprg = "rg --vimgrep"  -- use ripgrep for grep
opt.ignorecase = true         -- ignore case
opt.inccommand = "nosplit"    -- preview incremental substitute
opt.jumpoptions = "view"      -- jump options
opt.laststatus = 3           -- global statusline
opt.linebreak = true         -- wrap lines at convenient points
opt.list = true              -- show some invisible characters (tabs, etc.)
opt.mouse = "a"              -- enable mouse mode
opt.number = true            -- print line number
opt.pumblend = 10           -- popup blend
opt.pumheight = 10          -- maximum number of entries in a popup
opt.relativenumber = true    -- relative line numbers
opt.scrolloff = 10           -- lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true       -- round indent
opt.shiftwidth = 2          -- size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false        -- don't show mode since we have a statusline
opt.sidescrolloff = 8       -- columns of context
opt.signcolumn = "yes"      -- always show the signcolumn
opt.smartcase = true        -- don't ignore case with capitals
opt.smartindent = true      -- insert indents automatically
opt.smoothscroll = true     -- smooth scrolling
opt.spelllang = { "en" }    -- spell check language
opt.splitbelow = true       -- put new windows below current
opt.splitkeep = "screen"    -- keep screen position when splitting
opt.splitright = true       -- put new windows right of current
opt.swapfile = false        -- disable swapfile
opt.tabstop = 2            -- number of spaces tabs count for
opt.termguicolors = true    -- true color support
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- timeout for which-key
opt.undofile = true         -- enable persistent undo
opt.undolevels = 10000      -- maximum number of undos
opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- undo directory
opt.updatetime = 200        -- save swap file and trigger CursorHold
opt.virtualedit = "block"   -- allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- command-line completion mode
opt.winminwidth = 5         -- minimum window width
opt.wrap = false           -- disable line wrapping

-- Search options
opt.hlsearch = false       -- disable search highlighting by default

-- Folding settings - disable automatic folding but allow manual
opt.foldenable = false     -- disable folding by default
opt.foldmethod = "indent"  -- folding method (changed from manual to indent for better experience)
opt.foldlevel = 99        -- start with all folds open
opt.foldlevelstart = 99   -- start with all folds open when opening files
opt.foldtext = ""         -- use simple fold text

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0