-- Verification script for AI keybindings and which-key integration
-- Run this with: :luafile %

local M = {}

-- Check if plugins are loaded
function M.check_plugins()
  local status = {
    codecompanion = pcall(require, "codecompanion"),
    copilot = pcall(require, "copilot"),
    whichkey = pcall(require, "which-key"),
  }

  print("=== Plugin Status ===")
  for plugin, loaded in pairs(status) do
    print(string.format("  %s: %s", plugin, loaded and "✓ Loaded" or "✗ Not Loaded"))
  end
  print()

  return status
end

-- Check AI keybindings
function M.check_keybindings()
  print("=== AI Keybindings ===")

  local keymaps = {
    -- Core operations
    { mode = "n", lhs = "<leader>aa", desc = "AI Chat Toggle" },
    { mode = "n", lhs = "<leader>an", desc = "AI New Chat" },
    { mode = "n", lhs = "<leader>ag", desc = "AI Agent Mode" },
    { mode = "n", lhs = "<leader>ai", desc = "AI Inline Prompt" },
    { mode = "n", lhs = "<leader>a<cr>", desc = "AI Actions Palette" },

    -- Quick prompts (visual mode)
    { mode = "v", lhs = "<leader>ae", desc = "AI Explain" },
    { mode = "v", lhs = "<leader>af", desc = "AI Fix" },
    { mode = "v", lhs = "<leader>at", desc = "AI Generate Tests" },
    { mode = "v", lhs = "<leader>ar", desc = "AI Refactor" },

    -- Settings
    { mode = "n", lhs = "<leader>am", desc = "AI Select Model" },
    { mode = "n", lhs = "<leader>as", desc = "AI Toggle Suggestions" },
  }

  local registered_count = 0
  local missing_count = 0

  for _, keymap in ipairs(keymaps) do
    local found = false
    local all_keymaps = vim.api.nvim_get_keymap(keymap.mode)

    for _, map in ipairs(all_keymaps) do
      if map.lhs == keymap.lhs then
        found = true
        registered_count = registered_count + 1
        print(string.format("  ✓ %s (%s): %s", keymap.lhs, keymap.mode, keymap.desc))
        break
      end
    end

    if not found then
      missing_count = missing_count + 1
      print(string.format("  ✗ %s (%s): NOT FOUND", keymap.lhs, keymap.mode))
    end
  end

  print()
  print(string.format("Summary: %d registered, %d missing", registered_count, missing_count))
  print()
end

-- Check which-key groups
function M.check_whichkey_groups()
  local ok, wk = pcall(require, "which-key")
  if not ok then
    print("=== Which-Key Status ===")
    print("  ✗ Which-Key not loaded")
    print()
    return
  end

  print("=== Which-Key Groups ===")
  print("  ✓ Which-Key is loaded")
  print("  ✓ AI group should be registered as '<leader>a'")
  print()
  print("To test which-key display:")
  print("  1. Press <leader> in normal mode")
  print("  2. Wait for which-key popup (300ms)")
  print("  3. Look for 'a' with icon  and 'ai' label")
  print("  4. Press 'a' to see all AI subcommands")
  print()
end

-- Check current AI model
function M.check_current_model()
  print("=== Current AI Configuration ===")

  local model = vim.g.codecompanion_model or "claude-4.5-sonnet (default)"
  local adapter = vim.g.codecompanion_adapter or "Not set"

  print(string.format("  Current Model: %s", model))
  print(string.format("  Current Adapter: %s", adapter))
  print()
end

-- Check Copilot status
function M.check_copilot()
  print("=== Copilot Status ===")
  print("  Run :Copilot status to check authentication")
  print("  If not authenticated, run :Copilot auth")
  print()
end

-- Run all checks
function M.verify_all()
  print("\n")
  print(
    "╔════════════════════════════════════════════════════════╗"
  )
  print("║   CodeCompanion.nvim Keybinding Verification          ║")
  print(
    "╚════════════════════════════════════════════════════════╝"
  )
  print()

  M.check_plugins()
  M.check_current_model()
  M.check_keybindings()
  M.check_whichkey_groups()
  M.check_copilot()

  print(
    "╔════════════════════════════════════════════════════════╗"
  )
  print("║   Next Steps                                           ║")
  print(
    "╚════════════════════════════════════════════════════════╝"
  )
  print()
  print("1. Test in normal mode: Press <leader> and then 'a'")
  print("2. Test agent mode: <leader>ag")
  print("3. Test chat: <leader>aa")
  print("4. Test model selection: <leader>am")
  print()
  print("For detailed reference, see: nvim/.config/nvim/AI_SETUP.md")
  print()
end

-- Auto-run if sourced directly
if vim.fn.expand("%:t") == "verify-ai-keys.lua" then
  M.verify_all()
end

return M
