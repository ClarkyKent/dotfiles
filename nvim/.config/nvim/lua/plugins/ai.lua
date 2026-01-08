return {
  -- Copilot Auth (required for CodeCompanion's copilot adapter)
  -- This provides authentication to access Claude, GPT, Gemini via GitHub Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      -- Enable suggestions for inline completions (like VS Code Copilot)
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<M-l>",        -- Alt+l to accept suggestion
          accept_word = "<M-k>",   -- Alt+k to accept word
          accept_line = "<M-j>",   -- Alt+j to accept line
          next = "<M-]>",          -- Alt+] for next suggestion
          prev = "<M-[>",          -- Alt+[ for previous suggestion
          dismiss = "<C-]>",       -- Ctrl+] to dismiss
        },
      },
      panel = {
        enabled = true,
        auto_refresh = true,
        keymap = {
          open = "<M-CR>",         -- Alt+Enter to open panel
        },
      },
      filetypes = {
        yaml = true,
        markdown = true,
        gitcommit = true,
        ["*"] = true,              -- Enable for all filetypes
      },
    },
  },

  -- CodeCompanion - Unified AI Assistant & Agent Mode
  -- Central hub for all AI operations: chat, inline, agents, and more
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "zbirenbaum/copilot.lua",
      { "stevearc/dressing.nvim", opts = {} },
      { "folke/which-key.nvim", optional = true },
      -- For agent file operations
      { "nvim-telescope/telescope.nvim", optional = true },
    },
    event = "VeryLazy",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
    keys = {
      -- ═══════════════════════════════════════════════════════════════════
      -- Chat & Toggle
      -- ═══════════════════════════════════════════════════════════════════
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Chat Toggle" },
      { "<leader>an", "<cmd>CodeCompanionChat<cr>", mode = { "n", "v" }, desc = "AI New Chat" },
      { "<leader>ah", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "AI Add to Chat" },

      -- ═══════════════════════════════════════════════════════════════════
      -- Actions & Inline
      -- ═══════════════════════════════════════════════════════════════════
      { "<leader>a<cr>", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions Palette" },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "AI Inline Prompt" },
      { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add to AI Chat" },

      -- ═══════════════════════════════════════════════════════════════════
      -- Agent Mode (like VS Code Copilot Agent)
      -- ═══════════════════════════════════════════════════════════════════
      { "<leader>ag", function()
          vim.cmd("CodeCompanionChat")
          vim.defer_fn(function()
            vim.api.nvim_feedkeys("@agent ", "n", false)
          end, 100)
        end, desc = "AI Agent Mode" },
      { "<leader>aw", function()
          vim.cmd("CodeCompanionChat")
          vim.defer_fn(function()
            vim.api.nvim_feedkeys("@workspace ", "n", false)
          end, 100)
        end, desc = "AI Workspace Context" },

      -- ═══════════════════════════════════════════════════════════════════
      -- Quick Prompts (Visual Mode)
      -- ═══════════════════════════════════════════════════════════════════
      { "<leader>ae", function() require("codecompanion").prompt("Explain") end, mode = "v", desc = "AI Explain" },
      { "<leader>af", function() require("codecompanion").prompt("Fix") end, mode = "v", desc = "AI Fix" },
      { "<leader>at", function() require("codecompanion").prompt("Tests") end, mode = "v", desc = "AI Generate Tests" },
      { "<leader>ad", function() require("codecompanion").prompt("Document") end, mode = "v", desc = "AI Generate Docs" },
      { "<leader>ar", function() require("codecompanion").prompt("Refactor") end, mode = "v", desc = "AI Refactor" },
      { "<leader>ao", function() require("codecompanion").prompt("Optimize") end, mode = "v", desc = "AI Optimize" },
      { "<leader>av", function() require("codecompanion").prompt("Review") end, mode = "v", desc = "AI Code Review" },

      -- ═══════════════════════════════════════════════════════════════════
      -- Buffer & File Operations
      -- ═══════════════════════════════════════════════════════════════════
      { "<leader>ab", function()
          local input = vim.fn.input("Ask about buffer: ")
          if input ~= "" then
            vim.cmd("CodeCompanionChat #buffer " .. input)
          end
        end, desc = "AI Ask about Buffer" },
      { "<leader>al", function()
          vim.cmd("CodeCompanionChat #lsp ")
        end, desc = "AI with LSP Context" },

      -- ═══════════════════════════════════════════════════════════════════
      -- Command Line AI (like :Copilot in VS Code)
      -- ═══════════════════════════════════════════════════════════════════
      { "<leader>a:", "<cmd>CodeCompanionCmd<cr>", desc = "AI Command" },

      -- ═══════════════════════════════════════════════════════════════════
      -- Model & Settings
      -- ═══════════════════════════════════════════════════════════════════
      { "<leader>am", function()
          local models = {
            -- Claude (Anthropic) - Latest
            { name = "Claude 4.5 Sonnet", model = "claude-4.5-sonnet" },
            { name = "Claude 4.5 Opus", model = "claude-4.5-opus" },
            { name = "Claude 4.5 Haiku", model = "claude-4.5-haiku" },
            { name = "Claude 4 Sonnet", model = "claude-4-sonnet" },
            { name = "Claude 4 Opus", model = "claude-4-opus" },
            { name = "Claude 3.5 Sonnet", model = "claude-3.5-sonnet" },
            { name = "Claude 3.5 Haiku", model = "claude-3.5-haiku" },
            -- GPT (OpenAI)
            { name = "GPT-4.5", model = "gpt-4.5" },
            { name = "GPT-4o", model = "gpt-4o" },
            { name = "GPT-4o Mini", model = "gpt-4o-mini" },
            { name = "GPT-4 Turbo", model = "gpt-4-turbo" },
            -- OpenAI Reasoning
            { name = "o3", model = "o3" },
            { name = "o3 Mini", model = "o3-mini" },
            { name = "o1", model = "o1" },
            { name = "o1 Mini", model = "o1-mini" },
            { name = "o1 Pro", model = "o1-pro" },
            -- Gemini (Google) - Latest
            { name = "Gemini 3 Pro", model = "gemini-3-pro" },
            { name = "Gemini 3 Flash", model = "gemini-3-flash" },
            { name = "Gemini 3 Ultra", model = "gemini-3-ultra" },
            { name = "Gemini 2.5 Pro", model = "gemini-2.5-pro" },
            { name = "Gemini 2.0 Flash", model = "gemini-2.0-flash" },
            { name = "Gemini 2.0 Flash Thinking", model = "gemini-2.0-flash-thinking-exp" },
          }
          local items = vim.tbl_map(function(m) return m.name end, models)
          vim.ui.select(items, { prompt = " Select AI Model:" }, function(choice, idx)
            if choice and idx then
              vim.g.codecompanion_model = models[idx].model
              vim.notify(" AI Model: " .. choice, vim.log.levels.INFO)
            end
          end)
        end, desc = "AI Select Model" },

      -- ═══════════════════════════════════════════════════════════════════
      -- Copilot Inline Suggestions
      -- ═══════════════════════════════════════════════════════════════════
      { "<leader>as", function()
          local suggestion = require("copilot.suggestion")
          if suggestion.is_visible() then
            suggestion.dismiss()
            vim.notify("Copilot suggestions disabled", vim.log.levels.INFO)
          else
            suggestion.next()
            vim.notify("Copilot suggestions enabled", vim.log.levels.INFO)
          end
        end, desc = "AI Toggle Suggestions" },
      { "<leader>ap", "<cmd>Copilot panel<cr>", desc = "AI Copilot Panel" },
    },
    opts = {
      -- ═══════════════════════════════════════════════════════════════════
      -- Strategy Configuration
      -- ═══════════════════════════════════════════════════════════════════
      strategies = {
        chat = {
          adapter = "copilot",
          roles = {
            llm = function(adapter)
              return " " .. (adapter.formatted_name or "AI")
            end,
            user = "  You",
          },
          slash_commands = {
            ["buffer"] = {
              opts = { provider = "default" },
            },
            ["file"] = {
              opts = { provider = "telescope" },
            },
            ["symbols"] = {
              opts = { provider = "telescope" },
            },
          },
          keymaps = {
            close = { modes = { n = "q", i = "<C-c>" } },
            stop = { modes = { n = "<C-c>" } },
            send = { modes = { n = "<CR>", i = "<C-s>" } },
            regenerate = { modes = { n = "gr" } },
            pin = { modes = { n = "gp" } },
            next_chat = { modes = { n = "]]" } },
            previous_chat = { modes = { n = "[[" } },
          },
        },
        inline = {
          adapter = "copilot",
          keymaps = {
            accept_change = { modes = { n = "ga" }, desc = "Accept change" },
            reject_change = { modes = { n = "gr" }, desc = "Reject change" },
          },
        },
        -- Agent mode configuration
        agent = {
          adapter = "copilot",
          tools = {
            opts = {
              auto_submit_errors = true,
              auto_submit_success = true,
            },
          },
        },
      },

      -- ═══════════════════════════════════════════════════════════════════
      -- Adapter Configuration (Copilot as primary)
      -- ═══════════════════════════════════════════════════════════════════
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = vim.g.codecompanion_model or "claude-4.5-sonnet",
                choices = {
                  -- Claude (Anthropic) - Latest
                  "claude-4.5-sonnet",
                  "claude-4.5-opus",
                  "claude-4.5-haiku",
                  "claude-4-sonnet",
                  "claude-4-opus",
                  "claude-3.5-sonnet",
                  "claude-3.5-haiku",
                  -- GPT (OpenAI)
                  "gpt-4.5",
                  "gpt-4o",
                  "gpt-4o-mini",
                  "gpt-4-turbo",
                  -- OpenAI Reasoning
                  "o3",
                  "o3-mini",
                  "o1",
                  "o1-mini",
                  "o1-pro",
                  -- Gemini (Google) - Latest
                  "gemini-3-pro",
                  "gemini-3-flash",
                  "gemini-3-ultra",
                  "gemini-2.5-pro",
                  "gemini-2.0-flash",
                  "gemini-2.0-flash-thinking-exp",
                },
              },
            },
          })
        end,
      },

      -- ═══════════════════════════════════════════════════════════════════
      -- Display Configuration
      -- ═══════════════════════════════════════════════════════════════════
      display = {
        chat = {
          window = {
            layout = "vertical",
            width = 0.35,
            height = 0.7,
            border = "rounded",
            opts = {
              number = false,
              relativenumber = false,
              signcolumn = "no",
              wrap = true,
              linebreak = true,
            },
          },
          intro_message = [[
Welcome to CodeCompanion! Your AI-powered coding assistant.

**Quick Commands:**
- `@agent` - Enable agent mode for multi-step tasks
- `@workspace` - Include workspace context
- `#buffer` - Reference current buffer
- `#file` - Include specific files
- `/help` - Show all commands

**Keymaps:** `<leader>am` to change models
]],
          show_settings = false,
          show_token_count = true,
        },
        inline = {
          diff = {
            enabled = true,
            priority = 130,
            hl_groups = {
              added = "DiffAdd",
              removed = "DiffDelete",
            },
          },
        },
        action_palette = {
          provider = "telescope",
          opts = {
            show_default_actions = true,
            show_default_prompt_library = true,
          },
        },
      },

      -- ═══════════════════════════════════════════════════════════════════
      -- Global Options
      -- ═══════════════════════════════════════════════════════════════════
      opts = {
        log_level = "ERROR",
        send_code = true,
        use_default_actions = true,
        use_default_prompt_library = true,
        system_prompt = [[You are an expert AI programming assistant powered by GitHub Copilot.
You have access to various tools and can perform multi-step tasks when in agent mode.

Core Capabilities:
- Code generation, explanation, refactoring, and optimization
- Bug fixing and code review
- Test generation and documentation
- Multi-file editing and workspace understanding

Guidelines:
- Write clean, idiomatic, and well-documented code
- Follow best practices for the language/framework being used
- Consider edge cases, error handling, and security
- Provide concise explanations when helpful
- Use tools effectively when in agent mode to accomplish complex tasks
- When editing files, show the complete changes needed]],
      },

      -- ═══════════════════════════════════════════════════════════════════
      -- Prompt Library (Accessible via Actions or Keybindings)
      -- ═══════════════════════════════════════════════════════════════════
      prompt_library = {
        -- Code Understanding
        ["Explain"] = {
          strategy = "chat",
          description = "Explain selected code in detail",
          opts = { auto_submit = true, short_name = "explain" },
          prompts = {
            { role = "user", content = "Explain what this code does, including its purpose, logic flow, and any important details:\n\n```\n${visual}\n```" },
          },
        },

        -- Code Improvement
        ["Fix"] = {
          strategy = "chat",
          description = "Find and fix bugs or issues",
          opts = { auto_submit = true, short_name = "fix" },
          prompts = {
            { role = "user", content = "Analyze this code for bugs, issues, or potential problems and provide fixes:\n\n```\n${visual}\n```" },
          },
        },
        ["Refactor"] = {
          strategy = "chat",
          description = "Refactor for better structure",
          opts = { auto_submit = true, short_name = "refactor" },
          prompts = {
            { role = "user", content = "Refactor this code to improve its structure, readability, and maintainability while preserving functionality:\n\n```\n${visual}\n```" },
          },
        },
        ["Optimize"] = {
          strategy = "chat",
          description = "Optimize for performance",
          opts = { auto_submit = true, short_name = "optimize" },
          prompts = {
            { role = "user", content = "Optimize this code for better performance. Identify bottlenecks and suggest improvements:\n\n```\n${visual}\n```" },
          },
        },

        -- Code Generation
        ["Tests"] = {
          strategy = "chat",
          description = "Generate comprehensive tests",
          opts = { auto_submit = true, short_name = "tests" },
          prompts = {
            { role = "user", content = "Generate comprehensive unit tests for this code, covering edge cases and error scenarios:\n\n```\n${visual}\n```" },
          },
        },
        ["Document"] = {
          strategy = "inline",
          description = "Add documentation comments",
          opts = { auto_submit = true, short_name = "doc" },
          prompts = {
            { role = "user", content = "Add comprehensive documentation comments (docstrings, JSDoc, etc.) to this code:\n\n${visual}" },
          },
        },
        ["Types"] = {
          strategy = "inline",
          description = "Add type annotations",
          opts = { auto_submit = true, short_name = "types" },
          prompts = {
            { role = "user", content = "Add comprehensive type annotations to this code:\n\n${visual}" },
          },
        },

        -- Code Review
        ["Review"] = {
          strategy = "chat",
          description = "Comprehensive code review",
          opts = { auto_submit = true, short_name = "review" },
          prompts = {
            { role = "user", content = [[Perform a comprehensive code review covering:
1. **Bugs & Issues**: Potential bugs or logic errors
2. **Security**: Security vulnerabilities or concerns
3. **Performance**: Performance issues or optimizations
4. **Best Practices**: Adherence to coding standards
5. **Readability**: Code clarity and maintainability
6. **Suggestions**: Specific improvements with code examples

Code to review:
```
${visual}
```]] },
          },
        },

        -- Agent Tasks (Multi-step)
        ["Implement Feature"] = {
          strategy = "chat",
          description = "Implement a new feature (agent mode)",
          opts = { auto_submit = false },
          prompts = {
            { role = "system", content = "You are in agent mode. You can read files, search the codebase, and make multi-file edits. Work step by step to implement the requested feature." },
            { role = "user", content = "@agent Implement the following feature. First, analyze the codebase to understand the structure, then make the necessary changes:\n\nFeature: " },
          },
        },
        ["Debug Issue"] = {
          strategy = "chat",
          description = "Debug an issue (agent mode)",
          opts = { auto_submit = false },
          prompts = {
            { role = "system", content = "You are in agent mode. Use available tools to investigate and fix the issue." },
            { role = "user", content = "@agent Debug and fix the following issue. Investigate the relevant code and propose a solution:\n\nIssue: " },
          },
        },

        -- Utilities
        ["Commit Message"] = {
          strategy = "chat",
          description = "Generate a commit message",
          opts = { auto_submit = true, short_name = "commit" },
          prompts = {
            { role = "user", content = "Generate a concise, descriptive git commit message following conventional commits format for these changes:\n\n```\n${visual}\n```" },
          },
        },
        ["Simplify"] = {
          strategy = "inline",
          description = "Simplify complex code",
          opts = { auto_submit = true, short_name = "simplify" },
          prompts = {
            { role = "user", content = "Simplify this code while maintaining its functionality. Make it more readable and concise:\n\n${visual}" },
          },
        },
      },
    },

    config = function(_, opts)
      require("codecompanion").setup(opts)

      -- ═══════════════════════════════════════════════════════════════════
      -- Abbreviations for quick access in chat
      -- ═══════════════════════════════════════════════════════════════════
      vim.cmd([[cab cc CodeCompanion]])
      vim.cmd([[cab ccc CodeCompanionChat]])
      vim.cmd([[cab cca CodeCompanionActions]])

      -- ═══════════════════════════════════════════════════════════════════
      -- Register with which-key
      -- ═══════════════════════════════════════════════════════════════════
      local wk_ok, wk = pcall(require, "which-key")
      if wk_ok then
        wk.add({
          { "<leader>a", group = "ai", icon = " " },
          -- Chat
          { "<leader>aa", desc = "Chat Toggle", mode = { "n", "v" } },
          { "<leader>an", desc = "New Chat", mode = { "n", "v" } },
          { "<leader>ah", desc = "Add to Chat", mode = "v" },
          -- Actions
          { "<leader>a<cr>", desc = "Actions Palette", mode = { "n", "v" } },
          { "<leader>ai", desc = "Inline Prompt", mode = { "n", "v" } },
          { "<leader>a:", desc = "AI Command" },
          -- Agent
          { "<leader>ag", desc = "Agent Mode" },
          { "<leader>aw", desc = "Workspace Context" },
          -- Prompts
          { "<leader>ae", desc = "Explain", mode = "v" },
          { "<leader>af", desc = "Fix", mode = "v" },
          { "<leader>at", desc = "Generate Tests", mode = "v" },
          { "<leader>ad", desc = "Generate Docs", mode = "v" },
          { "<leader>ar", desc = "Refactor", mode = "v" },
          { "<leader>ao", desc = "Optimize", mode = "v" },
          { "<leader>av", desc = "Code Review", mode = "v" },
          -- Context
          { "<leader>ab", desc = "Ask about Buffer" },
          { "<leader>al", desc = "With LSP Context" },
          -- Settings
          { "<leader>am", desc = "Select Model" },
          { "<leader>as", desc = "Toggle Suggestions" },
          { "<leader>ap", desc = "Copilot Panel" },
        })
      end

      -- ═══════════════════════════════════════════════════════════════════
      -- Status line integration (optional)
      -- ═══════════════════════════════════════════════════════════════════
      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeCompanionChatAdapter",
        callback = function(args)
          if args.data and args.data.adapter then
            vim.g.codecompanion_adapter = args.data.adapter.formatted_name or "AI"
          end
        end,
      })
    end,
  },
}
