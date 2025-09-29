-- Autocompletion configuration using blink.cmp (LazyVim style)
return {
  {
    "saghen/blink.cmp",
    version = "*",
    build = "cargo build --release",
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.compat",
      "sources.default",
    },
    dependencies = {
      "rafamadriz/friendly-snippets",
      -- add blink.compat to dependencies
      {
        "saghen/blink.compat",
        optional = true, -- make optional so it doesn't error if not using it
        opts = {},
        version = "*",
      },
    },
    event = { "InsertEnter", "CmdlineEnter" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      snippets = {
        expand = function(snippet, _)
          -- Use LuaSnip expansion if available, otherwise fallback to vim's snippet expansion
          local ok, luasnip = pcall(require, "luasnip")
          if ok then
            luasnip.lsp_expand(snippet)
          else
            vim.snippet.expand(snippet)
          end
        end,
      },
      appearance = {
        -- sets the fallback highlight groups to nvim-cmp's highlight groups
        -- useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release, assuming themes add support
        use_nvim_cmp_as_default = false,
        -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
      },
      completion = {
        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = vim.g.ai_cmp ~= false,
        },
      },

      sources = {
        -- adding any nvim-cmp sources here will enable them
        -- with blink.compat
        compat = {},
        default = { "lsp", "path", "snippets", "buffer" },
      },

      -- Command line completion moved to separate section
      cmdline = {
        sources = {},
      },

      keymap = {
        preset = "default",
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },

        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },

        ["<C-l>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            end
          end,
          "fallback",
        },
      },
    },
    ---@param opts blink.cmp.Config | {sources: {compat: string[]}}
    config = function(_, opts)
      -- Ensure sources are properly initialized
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      
      -- Conditionally add lazydev if available
      local has_lazydev, _ = pcall(require, "lazydev.integrations.blink")
      if has_lazydev then
        opts.sources.providers.lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        }
        -- Add lazydev to default sources if not already present
        if not vim.tbl_contains(opts.sources.default, "lazydev") then
          table.insert(opts.sources.default, "lazydev")
        end
      end
      
      -- setup compat sources
      local enabled = opts.sources.default
      for _, source in ipairs(opts.sources.compat or {}) do
        opts.sources.providers[source] = vim.tbl_deep_extend(
          "force",
          { name = source, module = "blink.compat.source" },
          opts.sources.providers[source] or {}
        )
        if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
          table.insert(enabled, source)
        end
      end

      -- Unset custom prop to pass blink.cmp validation
      opts.sources.compat = nil

      -- check if we need to override symbol kinds
      for _, provider in pairs(opts.sources.providers or {}) do
        ---@cast provider blink.cmp.SourceProviderConfig|{kind?:string}
        if provider.kind then
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1
          CompletionItemKind[kind_idx] = provider.kind
          ---@diagnostic disable-next-line: no-unknown
          CompletionItemKind[provider.kind] = kind_idx

          ---@type fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
          local transform_items = provider.transform_items
          ---@param ctx blink.cmp.Context
          ---@param items blink.cmp.CompletionItem[]
          provider.transform_items = function(ctx, items)
            items = transform_items and transform_items(ctx, items) or items
            for _, item in ipairs(items) do
              item.kind = kind_idx or item.kind
            end
            return items
          end

          -- Unset custom prop to pass blink.cmp validation
          provider.kind = nil
        end
      end

      -- Safe setup with error handling
      local ok, err = pcall(require("blink.cmp").setup, opts)
      if not ok then
        vim.notify("blink.cmp setup failed: " .. tostring(err), vim.log.levels.ERROR)
      end
    end,
  },
  
  -- lazydev integration
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        -- add lazydev to your completion providers
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- show at a higher priority than lsp
          },
        },
      },
    },
    specs = {
      {
        "folke/lazydev.nvim",
        optional = true,
        opts = {
          integrations = {
            blink = true,
          },
        },
      },
    },
  },
}