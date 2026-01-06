return {
  -- Copilot Auth (required for CodeCompanion's copilot adapter)
  -- This provides authentication to access Claude, GPT, Gemini via GitHub Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "VeryLazy",
    opts = {
      suggestion = { enabled = false }, -- We use CodeCompanion instead
      panel = { enabled = false },
    },
  },

  -- CodeCompanion - Unified AI Assistant
  -- Access Claude, GPT, Gemini through Copilot subscription (no separate API keys needed)
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "zbirenbaum/copilot.lua", -- For Copilot auth
      {
        "stevearc/dressing.nvim",
        opts = {},
      },
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      -- Chat
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Chat Toggle" },
      { "<leader>an", "<cmd>CodeCompanionChat<cr>", mode = { "n", "v" }, desc = "AI New Chat" },
      -- Actions
      { "<leader>a<cr>", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "AI Inline" },
      -- Quick prompts
      { "<leader>ae", "<cmd>CodeCompanion /explain<cr>", mode = "v", desc = "AI Explain" },
      { "<leader>af", "<cmd>CodeCompanion /fix<cr>", mode = "v", desc = "AI Fix" },
      { "<leader>at", "<cmd>CodeCompanion /tests<cr>", mode = "v", desc = "AI Generate Tests" },
      { "<leader>ad", "<cmd>CodeCompanion /doc<cr>", mode = "v", desc = "AI Generate Docs" },
      { "<leader>ar", "<cmd>CodeCompanion /refactor<cr>", mode = "v", desc = "AI Refactor" },
      -- Buffer operations
      { "<leader>ab", function()
          local input = vim.fn.input("Ask about buffer: ")
          if input ~= "" then
            vim.cmd("CodeCompanionChat " .. input)
          end
        end, desc = "AI Ask about Buffer" },
      -- Model selection
      { "<leader>am", function()
          local models = {
            -- Claude (via Copilot)
            { name = "Claude Sonnet 4.5", model = "claude-sonnet-4.5" },
            { name = "Claude Sonnet 4", model = "claude-sonnet-4" },
            { name = "Claude Opus 4.5", model = "claude-opus-4.5" },
            { name = "Claude Haiku 4.5", model = "claude-haiku-4.5" },
            -- GPT (via Copilot)
            { name = "GPT-4.1", model = "gpt-4.1" },
            { name = "GPT-5", model = "gpt-5" },
            { name = "GPT-5.1", model = "gpt-5.1" },
            -- Gemini (via Copilot)
            { name = "Gemini 2.5 Pro", model = "gemini-2.5-pro" },
            { name = "Gemini 3 Pro", model = "gemini-3-pro" },
            { name = "Gemini 3 Flash", model = "gemini-3-flash" },
          }
          local items = vim.tbl_map(function(m) return m.name end, models)
          vim.ui.select(items, { prompt = "Select AI Model:" }, function(choice, idx)
            if choice and idx then
              local selected = models[idx].model
              -- Update the adapter's default model
              vim.g.codecompanion_model = selected
              vim.notify("AI Model: " .. choice, vim.log.levels.INFO)
            end
          end)
        end, desc = "AI Select Model" },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
          roles = {
            llm = "  Copilot",
            user = "  User",
          },
          keymaps = {
            close = { modes = { n = "q", i = "<C-c>" } },
            stop = { modes = { n = "<C-c>" } },
          },
        },
        inline = {
          adapter = "copilot",
        },
        agent = {
          adapter = "copilot",
        },
      },
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                -- Default model, can be changed with <leader>am
                default = vim.g.codecompanion_model or "claude-sonnet-4.5",
                -- Available models through Copilot subscription
                choices = {
                  -- Claude
                  "claude-sonnet-4.5",
                  "claude-sonnet-4",
                  "claude-opus-4.5",
                  "claude-opus-4.1",
                  "claude-haiku-4.5",
                  -- GPT
                  "gpt-4.1",
                  "gpt-5",
                  "gpt-5.1",
                  "gpt-5-mini",
                  -- Gemini
                  "gemini-2.5-pro",
                  "gemini-3-pro",
                  "gemini-3-flash",
                },
              },
            },
          })
        end,
      },
      display = {
        chat = {
          window = {
            layout = "vertical", -- vertical|horizontal|float
            width = 0.4,
            height = 0.6,
            border = "rounded",
            opts = {
              number = false,
              relativenumber = false,
              signcolumn = "no",
            },
          },
          intro_message = "Welcome! Use <leader>am to change models. Current: claude-sonnet-4.5",
        },
        inline = {
          diff = {
            enabled = true,
            priority = 130,
          },
        },
        action_palette = {
          provider = "default", -- default|telescope|mini_pick
        },
      },
      opts = {
        log_level = "ERROR",
        system_prompt = [[You are an expert software engineer. You provide clear, concise, and accurate answers.
When writing code:
- Follow best practices and idiomatic patterns for the language
- Include brief comments for complex logic
- Consider edge cases and error handling
- Suggest improvements when relevant]],
      },
      -- Prompt library (accessible via <leader>a<cr>)
      prompt_library = {
        ["Code Review"] = {
          strategy = "chat",
          description = "Review code for issues and improvements",
          prompts = {
            {
              role = "user",
              content = "Please review this code for potential bugs, performance issues, security concerns, and suggest improvements:\n\n```\n${visual}\n```",
            },
          },
        },
        ["Optimize"] = {
          strategy = "chat",
          description = "Optimize code for performance",
          prompts = {
            {
              role = "user",
              content = "Optimize this code for better performance while maintaining readability:\n\n```\n${visual}\n```",
            },
          },
        },
        ["Add Types"] = {
          strategy = "inline",
          description = "Add type annotations",
          prompts = {
            {
              role = "user",
              content = "Add comprehensive type annotations to this code:\n\n${visual}",
            },
          },
        },
        ["Explain Error"] = {
          strategy = "chat",
          description = "Explain an error message",
          prompts = {
            {
              role = "user",
              content = "Explain this error and how to fix it:\n\n${visual}",
            },
          },
        },
      },
    },
  },
}
