# Bare Minimum Neovim Configuration# Basic Neovim config using folke/lazy.nvim



A minimal Neovim configuration with essential plugins and useful keymaps.Bootstrap:



## Features1. Start Neovim. The `init.lua` will clone lazy.nvim automatically to: stdpath('data')/lazy/lazy.nvim

2. Inside Neovim run: `:Lazy sync`

- **Plugin Manager**: lazy.nvim

- **Colorscheme**: Tokyo Night StormIncluded plugins:

- **File Explorer**: nvim-tree

- **Fuzzy Finder**: Telescope- gruvbox (colorscheme)

- **Syntax Highlighting**: Treesitter- lualine (statusline)

- **Git Integration**: Gitsigns- telescope (fuzzy finder)

- **Status Line**: Lualine- nvim-treesitter (syntax)

- **Auto Pairs**: nvim-autopairs- mason (LSP tooling)

- **Comment Toggling**: Comment.nvim

Files:

## Key Mappings

- `init.lua` - main entry

### Leader Key- `lua/core/options.lua` - basic options

- Leader key is set to `<Space>`- `lua/core/keymaps.lua` - basic keymaps

- `lua/plugins/init.lua` - plugin list for lazy.nvim

### File Operations
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>x` - Close buffer

### Navigation
- `<C-h/j/k/l>` - Window navigation
- `<S-h/l>` - Buffer navigation (previous/next)
- `<C-Up/Down/Left/Right>` - Resize windows

### File Explorer
- `<leader>e` - Toggle nvim-tree

### Fuzzy Finding (Telescope)
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<leader>fh` - Help tags

### Text Editing
- `<A-j/k>` - Move lines up/down (visual mode)
- `</>` - Indent/outdent (stays in visual mode)
- `p` - Paste without overwriting register (visual mode)
- `<leader>h` - Clear search highlighting

### Quick Fix
- `<leader>j` - Next quickfix item
- `<leader>k` - Previous quickfix item

### Terminal
- `<C-h/j/k/l>` - Navigate from terminal mode

### Comments
- `gcc` - Toggle line comment
- `gc` - Toggle comment (visual mode)

## Installation

1. Clone or copy this `init.lua` to your Neovim config directory
2. Start Neovim - plugins will install automatically
3. Restart Neovim to ensure everything loads properly

## Directory Structure

```
~/.config/nvim/
├── init.lua            # Main configuration file (bootstrap and module loading)
├── lua/
│   ├── options.lua     # Editor options and settings
│   ├── keymaps.lua     # Basic keymaps (non-plugin)
│   └── plugins.lua     # Plugin configurations with their keymaps
└── README.md           # This file
```

The configuration is now modular with plugins self-contained:
- `init.lua` - Main entry point with lazy.nvim bootstrap and module loading
- `lua/options.lua` - All editor options and leader key settings
- `lua/keymaps.lua` - Basic navigation and editing keymaps (non-plugin related)
- `lua/plugins.lua` - All plugins with their configurations and keymaps in one place