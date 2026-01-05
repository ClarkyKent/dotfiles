return {
  -- Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = false,
      -- Available models (GitHub Copilot) - use :CopilotChatModels to see available
      -- Claude: claude-sonnet-4.5, claude-sonnet-4, claude-opus-4.5, claude-opus-4.1, claude-haiku-4.5
      -- GPT: gpt-5.2, gpt-5.1, gpt-5.1-codex*, gpt-5, gpt-5-codex, gpt-5-mini, gpt-4.1
      -- Gemini: gemini-3-pro, gemini-3-flash, gemini-2.5-pro
      -- Other: grok-code-fast-1, raptor-mini
      model = "claude-sonnet-4.5", -- Default model
      -- Agent mode configuration
      agent = "copilot", -- Default agent

      -- Window configuration
      window = {
        layout = "vertical", -- 'vertical', 'horizontal', 'float', 'replace'
        width = 0.4, -- fractional width of parent
        height = 0.5, -- fractional height of parent
        border = "rounded",
      },

      -- Available prompts (agents/modes)
      prompts = {
        Explain = {
          prompt = "/COPILOT_EXPLAIN Write an explanation for the selected code as paragraphs of text.",
        },
        Review = {
          prompt = "/COPILOT_REVIEW Review the selected code for potential issues and improvements.",
        },
        Fix = {
          prompt = "/COPILOT_GENERATE Fix any issues in the selected code.",
        },
        Optimize = {
          prompt = "/COPILOT_GENERATE Optimize the selected code for performance and readability.",
        },
        Docs = {
          prompt = "/COPILOT_GENERATE Add documentation comments for the selected code.",
        },
        Tests = {
          prompt = "/COPILOT_GENERATE Generate unit tests for the selected code.",
        },
        Refactor = {
          prompt = "/COPILOT_GENERATE Refactor the selected code to improve clarity and maintainability.",
        },
      },

      -- Mappings inside chat window
      mappings = {
        complete = {
          insert = "<Tab>",
        },
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        reset = {
          normal = "<C-r>",
          insert = "<C-r>",
        },
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        toggle_sticky = {
          normal = "gs",
        },
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        yank_diff = {
          normal = "gy",
        },
        show_diff = {
          normal = "gd",
        },
        show_info = {
          normal = "gi",
        },
        show_context = {
          normal = "gc",
        },
      },
    },
    keys = {
      -- Chat toggle
      { "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" },
      { "<leader>cq", "<cmd>CopilotChatClose<cr>", desc = "Close Copilot Chat" },
      { "<leader>cr", "<cmd>CopilotChatReset<cr>", desc = "Reset Copilot Chat" },

      -- Prompts/Actions
      { "<leader>ce", "<cmd>CopilotChatExplain<cr>", mode = { "n", "v" }, desc = "Explain Code" },
      { "<leader>cR", "<cmd>CopilotChatReview<cr>", mode = { "n", "v" }, desc = "Review Code" },
      { "<leader>cf", "<cmd>CopilotChatFix<cr>", mode = { "n", "v" }, desc = "Fix Code" },
      { "<leader>co", "<cmd>CopilotChatOptimize<cr>", mode = { "n", "v" }, desc = "Optimize Code" },
      { "<leader>cd", "<cmd>CopilotChatDocs<cr>", mode = { "n", "v" }, desc = "Generate Docs" },
      { "<leader>ct", "<cmd>CopilotChatTests<cr>", mode = { "n", "v" }, desc = "Generate Tests" },
      { "<leader>cF", "<cmd>CopilotChatRefactor<cr>", mode = { "n", "v" }, desc = "Refactor Code" },

      -- Model selection
      {
        "<leader>cm",
        function()
          local models = {
            -- Anthropic Claude
            "claude-sonnet-4.5",
            "claude-sonnet-4",
            "claude-opus-4.5",
            "claude-opus-4.1",
            "claude-haiku-4.5",
            -- OpenAI GPT
            "gpt-5.2",
            "gpt-5.1",
            "gpt-5.1-codex",
            "gpt-5.1-codex-mini",
            "gpt-5.1-codex-max",
            "gpt-5",
            "gpt-5-codex",
            "gpt-5-mini",
            "gpt-4.1",
            -- Google Gemini
            "gemini-3-pro",
            "gemini-3-flash",
            "gemini-2.5-pro",
            -- xAI
            "grok-code-fast-1",
            -- Fine-tuned
            "raptor-mini",
          }
          vim.ui.select(models, { prompt = "Select Copilot Model:" }, function(choice)
            if choice then
              require("CopilotChat").config.model = choice
              vim.notify("Copilot model set to: " .. choice, vim.log.levels.INFO)
            end
          end)
        end,
        desc = "Select Copilot Model",
      },

      -- Agent mode selection
      {
        "<leader>ca",
        function()
          local agents = {
            "copilot",      -- Default tool-calling agent (file reading, git, search)
            "codebase",     -- Understands codebase context
            "perplexityai", -- Web search agent (requires extension)
          }
          vim.ui.select(agents, { prompt = "Select Agent:" }, function(choice)
            if choice then
              require("CopilotChat").config.agent = choice
              vim.notify("Agent set to: " .. choice, vim.log.levels.INFO)
            end
          end)
        end,
        desc = "Select Agent Mode",
      },

      -- Quick chat with visual selection
      {
        "<leader>cv",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input, { selection = require("CopilotChat.select").visual })
          end
        end,
        mode = "v",
        desc = "Quick Chat (Visual)",
      },

      -- Quick chat with buffer
      {
        "<leader>cb",
        function()
          local input = vim.fn.input("Chat about buffer: ")
          if input ~= "" then
            require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
          end
        end,
        desc = "Chat about Buffer",
      },

      -- Show available prompts
      {
        "<leader>cp",
        function()
          require("CopilotChat").select_prompt()
        end,
        mode = { "n", "v" },
        desc = "Select Prompt",
      },
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)

      -- Create user commands for model switching
      vim.api.nvim_create_user_command("CopilotModel", function(args)
        if args.args ~= "" then
          require("CopilotChat").config.model = args.args
          vim.notify("Model: " .. args.args, vim.log.levels.INFO)
        else
          vim.notify("Current model: " .. require("CopilotChat").config.model, vim.log.levels.INFO)
        end
      end, {
        nargs = "?",
        complete = function()
          return {
            -- Anthropic Claude
            "claude-sonnet-4.5", "claude-sonnet-4", "claude-opus-4.5", "claude-opus-4.1", "claude-haiku-4.5",
            -- OpenAI GPT
            "gpt-5.2", "gpt-5.1", "gpt-5.1-codex", "gpt-5.1-codex-mini", "gpt-5.1-codex-max",
            "gpt-5", "gpt-5-codex", "gpt-5-mini", "gpt-4.1",
            -- Google Gemini
            "gemini-3-pro", "gemini-3-flash", "gemini-2.5-pro",
            -- xAI & Fine-tuned
            "grok-code-fast-1", "raptor-mini",
          }
        end,
        desc = "Set Copilot Chat model",
      })
    end,
  },

  -- Claude / AI Assistant (CodeCompanion)
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim", -- Optional
      {
        "stevearc/dressing.nvim", -- Optional: Improves the UI
        opts = {},
      },
    },
    config = true,
    keys = {
      { "<leader>a", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Chat Toggle" },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "AI Inline" },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot", -- Default to copilot, change to "anthropic" if you have a key
        },
        inline = {
          adapter = "copilot",
        },
        agent = {
          adapter = "copilot",
        },
      },
    },
  },
}
