# Modern Neovim Config for C/C++/Embedded

A modular, feature-rich Neovim configuration focused on C/C++, Rust, and Python development, with an "NvChad-like" aesthetic.

## Features

- **Package Management**: [lazy.nvim](https://github.com/folke/lazy.nvim)
- **UI**: [Kanagawa](https://github.com/rebelot/kanagawa.nvim) theme, [Lualine](https://github.com/nvim-lualine/lualine.nvim), [Snacks.nvim](https://github.com/folke/snacks.nvim) (Dashboard, Notifications).
- **LSP**: Native LSP with [Mason](https://github.com/williamboman/mason.nvim) and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig).
  - **C/C++**: `clangd` with `clangd_extensions.nvim` (AST, switching, etc.).
  - **Rust**: `rust-analyzer`.
  - **Python**: `pyright` + `black`/`isort`.
- **Completion**: [blink.cmp](https://github.com/saghen/blink.cmp) (Fast, Rust-based).
- **Formatting**: [conform.nvim](https://github.com/stevearc/conform.nvim).
- **Linting**: [nvim-lint](https://github.com/mfussenegger/nvim-lint).
- **Navigation**: [fzf-lua](https://github.com/ibhagwan/fzf-lua) (Files, Grep, Git), [Flash.nvim](https://github.com/folke/flash.nvim).
- **Git**: [gitsigns](https://github.com/lewis6991/gitsigns.nvim), [Snacks Lazygit](https://github.com/folke/snacks.nvim).
- **AI**: GitHub Copilot (Chat & Completion), Claude via [CodeCompanion](https://github.com/olimorris/codecompanion.nvim).
- **Terminal**: Floating terminal via [ToggleTerm](https://github.com/akinsho/toggleterm.nvim) or Snacks (`<c-/>`).

## Requirements

Ensure the following are installed on your system:

- **Neovim** >= 0.9.0 (0.10+ recommended)
- **Git**
- **C Compiler** (gcc/clang) - for compiling treesitter parsers.
- **Node.js & npm** - for Mason to install many servers.
- **Ripgrep** (`rg`) - for Fzf-lua grep.
- **Fd** (`fd`) - for Fzf-lua file search.
- **Unzip**, **Tar**, **Wget**, **Curl** - for Mason.
- **Clangd** - heavily recommended to have system-wide `clangd` for C++, though Mason can install it too.

## Structure

```
nvim/
├── init.lua              # Bootstrap
├── lua/
│   ├── config/           # Core config
│   │   ├── autocmds.lua
│   │   ├── cortex.lua    # Cortex-M (SVD/registers/memory) helpers for DAP
│   │   ├── coverage.lua  # Coverage report discovery
│   │   ├── env.lua       # Synchronous direnv/devbox environment loading
│   │   ├── format.lua    # Format-on-save toggles
│   │   ├── icons.lua
│   │   ├── keymaps.lua
│   │   ├── options.lua
│   │   ├── tasks.lua     # Overseer templates (just/meson/invoke/robot)
│   │   ├── tsincremental.lua
│   │   └── util.lua
│   └── plugins/          # Plugins (Modular)
│       ├── ai.lua        # Copilot, CodeCompanion (Claude/GPT/Gemini)
│       ├── build.lua     # Overseer task runner
│       ├── completion.lua# blink.cmp
│       ├── coverage.lua  # nvim-coverage
│       ├── debug.lua     # nvim-dap (Cortex-M, host gdb, Python/Robot)
│       ├── docs.lua      # Markdown preview/render
│       ├── editor.lua    # Fzf, Flash, Harpoon, Git signs, Todo comments
│       ├── formatting.lua# Conform
│       ├── git.lua       # Diffview, git-conflict
│       ├── linting.lua   # nvim-lint
│       ├── lsp.lua       # LSP, Mason, Clangd
│       ├── navigation.lua# Aerial outline, matchup, Glance peek
│       ├── project.lua   # Sessions, project detection
│       ├── sonarqube.lua # SonarLint
│       ├── testing.lua   # Neotest (pytest, Rust)
│       ├── tooling.lua   # Mason tool provisioning
│       ├── treesitter.lua# Syntax Highlighting
│       └── ui.lua        # Theme, Dashboard, Statusline, Terminal
```

## Keymaps

| Key | Description |
| --- | --- |
| `<space>` | Leader Key |
| `<leader><space>` | Find Files |
| `<leader>/` | Grep (Live) |
| `<leader>,` | Switch Buffer |
| `<leader>l` | Lazy Plugin Manager |
| `<leader>gg` | Lazygit |
| `<C-t>` | Toggle Floating Terminal |
| `<leader>cR` | Switch Source/Header (C++) |
| `<leader>a` | AI Actions |
| `<leader>cc` | Copilot Chat |

## Customization

- **LSP**: Edit `lua/plugins/lsp.lua` to add more servers.
- **Formatting**: Edit `lua/plugins/formatting.lua`.
- **UI**: Edit `lua/plugins/ui.lua`.
