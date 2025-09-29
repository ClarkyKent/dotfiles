# Noice.nvim Configuration

## Overview
Noice.nvim replaces the UI for messages, cmdline, and the popupmenu with a modern, highly configurable interface. This configuration provides enhanced notifications, a better command line experience, and improved LSP message handling.

## Features

### Enhanced Command Line
- **Modern popup cmdline**: Floating command line with rounded borders
- **Command icons**: Visual indicators for different command types
- **Smart positioning**: Centered popup that doesn't interfere with content
- **Syntax highlighting**: Proper highlighting for different command types

### Notification System
- **nvim-notify integration**: Beautiful notification system
- **Smart routing**: Different message types go to appropriate views
- **Notification history**: Access to previous notifications
- **Dismissible notifications**: Easy cleanup of notification clutter

### LSP Integration
- **Progress indicators**: Visual feedback for LSP operations
- **Enhanced hover**: Better formatting for LSP hover information
- **Signature help**: Auto-opening signature help with proper formatting
- **Documentation**: Improved LSP documentation display

## Keymaps

### Noice Controls
| Keymap | Action | Description |
|--------|---------|-------------|
| `<leader>sn` | `:NoiceHistory` | Show message history |
| `<leader>snl` | `:NoiceLast` | Show last message |
| `<leader>snd` | `:NoiceDismiss` | Dismiss all messages |
| `<leader>snt` | `:NoiceStats` | Show noice statistics |
| `<leader>snc` | `:NoiceConfig` | Show current config |

### Notification Controls
| Keymap | Action | Description |
|--------|---------|-------------|
| `<leader>un` | Dismiss notifications | Clear all pending notifications |
| `<leader>sN` | Notification history | Browse notification history (requires Telescope) |

### Enhanced Scrolling
| Keymap | Mode | Action |
|--------|------|--------|
| `<Ctrl-f>` | i,n,s | Scroll forward in LSP docs/popups |
| `<Ctrl-b>` | i,n,s | Scroll backward in LSP docs/popups |

## Command Line Features

### Command Icons
- `:` - Vim command
- `/` - Search down  
- `?` - Search up
- `!` - Shell command
- `` - Lua command
- `` - Help command
- `󰥻` - Input prompt

### Smart Command Detection
- **Vim commands**: Normal : commands with vim syntax highlighting
- **Searches**: Pattern search with regex highlighting  
- **Shell commands**: System commands with bash highlighting
- **Lua evaluation**: Lua expressions with proper syntax
- **Help commands**: Documentation searches

## Message Routing

### Smart Message Filtering
- **File write messages**: Hidden to reduce noise
- **Search wrap messages**: Hidden (hit TOP/BOTTOM)
- **Pattern not found**: Hidden to reduce clutter
- **Long messages**: Automatically routed to split view
- **LSP progress**: Compact mini view display

### View Routing
- **Errors/Warnings**: Prominent notify view
- **Info messages**: Standard notify view
- **History**: Dedicated messages view
- **Search counts**: Virtual text display

## Notification Features

### Visual Enhancements
- **Fade animations**: Smooth fade in/slide out
- **Responsive sizing**: Adapts to screen size
- **Custom icons**: Clear status indicators (✓ ⚠  ✎)
- **Background styling**: Proper contrast and theming
- **High z-index**: Always visible above other content

### Smart Behavior
- **3-second timeout**: Auto-dismiss after reasonable time
- **Top-down stacking**: New notifications appear at top
- **Wrapped compact**: Efficient space usage
- **Pending dismissal**: Clear all at once

## LSP Enhancements

### Progress Display
- **Mini view**: Compact progress indicators
- **Throttled updates**: Smooth 30fps progress updates
- **Replace/merge**: Avoid notification spam
- **Background operations**: Non-intrusive progress tracking

### Documentation
- **Markdown rendering**: Proper formatting for LSP docs
- **Hover improvements**: Enhanced hover documentation
- **Signature help**: Auto-opening with trigger detection
- **Concealed markup**: Clean display without markdown syntax

## Configuration Highlights

### Presets Enabled
- **Bottom search**: Classic search experience at bottom
- **Command palette**: Unified cmdline and popup positioning
- **Long message splits**: Large messages in dedicated splits
- **LSP documentation**: Enhanced LSP documentation display

### Custom Views
- **Cmdline popup**: Centered, 60-character width with auto-height
- **Popupmenu**: Positioned below cmdline with matching width
- **Rounded borders**: Consistent visual styling
- **Custom highlights**: Integrated with your color scheme

## Usage Examples

### Daily Workflow
```lua
-- Check message history
<leader>sn

-- Dismiss notification clutter  
<leader>un

-- Review last important message
<leader>snl

-- Check noice statistics
<leader>snt
```

### LSP Workflow
```lua
-- Enhanced hover (automatic)
K  -- LSP hover with better formatting

-- Signature help (automatic)
-- Triggers when typing function calls

-- Scroll through LSP documentation
<Ctrl-f>  -- Scroll down in LSP popups
<Ctrl-b>  -- Scroll up in LSP popups
```

### Command Line Usage
```lua
:help noice          -- Help command with  icon
/search pattern      -- Search with  icon  
:!ls -la            -- Shell command with $ icon
:lua print("hi")    -- Lua command with  icon
```

## Integration Notes

### Which-Key Integration
- **`<leader>sn` group**: "noice" - All noice commands grouped
- **`<leader>u` group**: "ui" - Notification controls in UI group
- **Clear descriptions**: All commands properly documented

### Existing Plugin Harmony
- **FZF/Telescope**: Notification history integration
- **LSP**: Enhanced hover and signature help
- **Completion**: Better documentation in completion popups
- **Terminal**: Proper message handling in terminal mode

## Customization

### Styling
- **Custom highlights**: NoiceCmdlinePopup, NoiceCmdlinePopupBorder, NoiceCmdlineIcon
- **Theme integration**: Adapts to your colorscheme
- **Border styles**: Rounded borders for modern look
- **Icon customization**: Easily modify command icons

### Message Filtering
Add custom routes in configuration:
```lua
routes = {
  {
    filter = { event = "msg_show", find = "your_pattern" },
    opts = { skip = true }, -- Hide message
  },
}
```

### View Customization
Modify views for different positioning:
```lua
views = {
  cmdline_popup = {
    position = { row = 5, col = "50%" },
    size = { width = 60, height = "auto" },
  },
}
```

## Benefits

1. **Modern UI**: Clean, floating command line and notifications
2. **Reduced Noise**: Smart filtering of repetitive messages  
3. **Enhanced LSP**: Better documentation and progress feedback
4. **Accessible History**: Easy access to previous messages
5. **Customizable**: Highly configurable for personal preferences
6. **Performance**: Efficient rendering with proper throttling

Your Neovim now has a **professional-grade UI** with modern notifications, enhanced command line, and improved LSP integration! ✨

The combination of noice.nvim and nvim-notify provides a cohesive, distraction-free editing experience while keeping important information easily accessible.