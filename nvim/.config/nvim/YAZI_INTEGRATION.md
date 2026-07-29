# Yazi File Manager Integration

## Overview

Yazi is now integrated into your Neovim configuration, providing a fast, modern terminal file manager with vim-like keybindings.

## Keybindings

### Opening Yazi

| Key | Action |
|-----|--------|
| `<F7>` | Open Yazi in current directory ⭐ |
| `<leader>fy` | Open Yazi in current directory |
| `<leader>fY` | Open Yazi in current working directory (cwd) |

### Inside Yazi

| Key | Action |
|-----|--------|
| `<F1>` | Show help |
| `<Enter>` | Open file in current buffer |
| `<C-v>` | Open file in vertical split |
| `<C-x>` | Open file in horizontal split |
| `<C-t>` | Open file in new tab |
| `<C-s>` | Grep in directory |
| `<C-g>` | Replace in directory |
| `<Tab>` | Cycle through open buffers |
| `<C-y>` | Copy relative path of selected files |
| `<C-q>` | Send to quickfix list |
| `q` or `<Esc>` | Close Yazi |

### Yazi Native Keybindings (in Yazi)

These work when Yazi is open:

**Navigation**:
- `j/k` or `↓/↑` - Move down/up
- `h/l` or `←/→` - Go to parent directory / Open directory
- `g` - Go to top
- `G` - Go to bottom

**File Operations**:
- `<Space>` - Toggle selection
- `v` - Visual mode (select multiple)
- `y` - Yank (copy)
- `x` - Cut
- `p` - Paste
- `d` - Delete
- `r` - Rename
- `c` - Create (new file/directory)

**View & Search**:
- `/` - Search
- `n/N` - Next/previous search result
- `s` - Sort by
- `z` - Toggle hidden files
- `i` - Toggle image preview (if supported)

**Quick Actions**:
- `o` - Open with default application
- `.` - Toggle hidden files
- `~` - Go to home directory

## Configuration

The Yazi integration is configured in:
- **File**: `nvim/.config/nvim/lua/plugins/editor.lua`
- **Plugin**: `mikavilpas/yazi.nvim`

### Window Settings
- **Scaling**: 90% of screen
- **Border**: Rounded
- **Blend**: No transparency (0)

### Features Enabled
- ✅ File opening in splits/tabs
- ✅ Grep in directory (via Neovim)
- ✅ Replace in directory (via Neovim)
- ✅ Copy paths to clipboard
- ✅ Send files to quickfix list
- ✅ Cycle through Neovim buffers

## Use Cases

### 1. Quick File Navigation
Press `<F7>` to browse files visually, navigate with `j/k`, open with `<Enter>`.

### 2. Multi-File Operations
1. Press `<F7>`
2. Select multiple files with `<Space>` or `v` (visual mode)
3. Yank with `y`, then paste in another directory with `p`

### 3. Project Exploration
1. Press `<F7>`
2. Navigate directories with `h/l`
3. Toggle hidden files with `z`
4. Open files in splits: `<C-v>` (vertical) or `<C-x>` (horizontal)

### 4. Search & Grep
1. Press `<F7>`
2. Navigate to directory
3. Press `<C-s>` to grep in that directory
4. Or use `/` to search file names in Yazi

### 5. File Management
1. Press `<F7>`
2. Create new file/dir: `c`
3. Rename: `r`
4. Delete: `d`
5. Copy: select with `<Space>`, then `y`, navigate, `p`

## Tips

### Efficient Workflow
1. **Quick browse**: `<F7>` → navigate → `<Enter>` to open
2. **Compare files**: Open first with `<Enter>`, open second with `<C-v>`
3. **Multi-file edit**: Select files → `<C-q>` (quickfix) → `:cdo %s/old/new/g`

### Integration with Neovim
- Files opened in Yazi respect your Neovim LSP configuration
- Split behavior follows Neovim window management
- Quickfix integration allows batch operations
- Buffer cycling lets you switch between open files

### Performance
- Yazi is extremely fast, even with large directories
- Image previews work in supported terminals
- File previews are syntax-highlighted

## Comparison: Yazi vs Other File Managers

| Feature | Yazi | NvimTree | Neo-tree | Oil.nvim |
|---------|------|----------|----------|----------|
| **Speed** | ⚡ Blazing fast | Fast | Fast | Fast |
| **UI** | Terminal-based | Split window | Split window | Buffer-based |
| **Keybindings** | Vim-like | Vim-like | Vim-like | Vim-like |
| **Preview** | ✅ Images + Files | ✅ Files | ✅ Files | ❌ |
| **Standalone** | ✅ Yes | ❌ Neovim only | ❌ Neovim only | ❌ Neovim only |
| **Multi-select** | ✅ Advanced | ✅ Basic | ✅ Basic | ✅ Basic |
| **File ops** | ✅ Full featured | ✅ Good | ✅ Good | ✅ Basic |

**Why Yazi?**
- Fastest file manager for terminals
- Rich feature set (preview, search, multi-select)
- Works standalone (can use outside Neovim)
- Modern, actively maintained
- Excellent multi-file operations

## Troubleshooting

### Issue: Yazi not opening

**Check installation**:
```bash
which yazi
yazi --version
```

**Verify in Neovim**:
```vim
:checkhealth yazi
```

### Issue: Keybinding not working

**Check if F7 is captured by terminal**:
Some terminals capture F-keys. If F7 doesn't work, use:
```vim
<leader>fy
```

**Remap if needed**: Edit `lua/plugins/editor.lua` and change `<F7>` to your preferred key.

### Issue: Preview not working

Yazi preview requires:
- Supported terminal (kitty, wezterm, iTerm2, etc.)
- Image preview support enabled in Yazi config
- File preview tools (bat, exa, etc.)

### Issue: Files not opening in Neovim

Ensure you're using the Neovim keybindings:
- `<Enter>` - Open in current window
- `<C-v>` - Open in vertical split
- `<C-x>` - Open in horizontal split

Not the native Yazi `o` command.

## Advanced Configuration

### Auto-open for directories

If you want Yazi to open automatically when you open a directory in Neovim:

Edit `lua/plugins/editor.lua` and change:
```lua
open_for_directories = true,
```

### Custom Yazi configuration

Yazi respects your Yazi config at `~/.config/yazi/yazi.toml`.

Example custom theme and keybindings:
```toml
# ~/.config/yazi/yazi.toml
[manager]
show_hidden = false
sort_by = "natural"
sort_dir_first = true

[preview]
image_filter = "lanczos3"
max_width = 600
max_height = 900
```

### Integration with FZF

You already have FZF-lua configured. Use them together:
1. `<F7>` - Browse visually (Yazi)
2. `<leader><space>` - Search by name (FZF)
3. `<leader>/` - Search by content (FZF grep)

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│ YAZI FILE MANAGER - QUICK REFERENCE                        │
├─────────────────────────────────────────────────────────────┤
│ Open Yazi                                                   │
│   <F7>         Open in current directory ⭐                 │
│   <leader>fy   Open in current directory                    │
│   <leader>fY   Open in cwd                                  │
├─────────────────────────────────────────────────────────────┤
│ In Yazi - Navigation                                        │
│   j/k          Move down/up                                 │
│   h/l          Parent dir / Open dir                        │
│   g/G          Top / Bottom                                 │
│   /            Search                                        │
│   z            Toggle hidden files                          │
├─────────────────────────────────────────────────────────────┤
│ In Yazi - File Operations                                   │
│   <Space>      Toggle selection                             │
│   v            Visual mode                                  │
│   y/x/p        Yank / Cut / Paste                           │
│   d            Delete                                        │
│   r            Rename                                        │
│   c            Create file/directory                        │
├─────────────────────────────────────────────────────────────┤
│ Open in Neovim                                              │
│   <Enter>      Open in current buffer                       │
│   <C-v>        Open in vertical split                       │
│   <C-x>        Open in horizontal split                     │
│   <C-t>        Open in new tab                              │
│   <C-q>        Send to quickfix list                        │
├─────────────────────────────────────────────────────────────┤
│ Neovim Integration                                          │
│   <C-s>        Grep in directory                            │
│   <C-g>        Replace in directory                         │
│   <C-y>        Copy relative paths                          │
│   <Tab>        Cycle open buffers                           │
├─────────────────────────────────────────────────────────────┤
│ Exit                                                         │
│   q / <Esc>    Close Yazi                                   │
└─────────────────────────────────────────────────────────────┘
```

## Resources

- **Yazi GitHub**: https://github.com/sxyazi/yazi
- **Yazi.nvim Plugin**: https://github.com/mikavilpas/yazi.nvim
- **Yazi Documentation**: https://yazi-rs.github.io/
- **Your Config**: `nvim/.config/nvim/lua/plugins/editor.lua`

---

*Configuration File: `nvim/.config/nvim/lua/plugins/editor.lua`*
*Yazi Version: Check with `yazi --version`*
*Last Updated: 2026-01-29*
