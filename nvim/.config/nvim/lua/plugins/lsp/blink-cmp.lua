return {
  "saghen/blink.cmp",
  -- optional: provides snippets for the snippet source
  dependencies = {  'rafamadriz/friendly-snippets' ,
                    -- "giuxtaposition/blink-cmp-copilot",
					"fang2hou/blink-copilot", 
                  },
	event = { "InsertEnter", "CmdlineEnter" },
	version = "1.*",
	opts = {
		keymap = {
			preset = "enter",
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },
			["<CR>"] = { "accept", "fallback" },

			["<C-j>"] = { "snippet_forward", "fallback" },
			["<C-k>"] = { "snippet_backward", "fallback" },

			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-p>"] = { "select_prev", "fallback_to_mappings" },
			["<C-n>"] = { "select_next", "fallback_to_mappings" },

			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },

			["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
		},
   
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },

    completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 100,
				window = {
					border = "bold",
				},
			},
			menu = {
				border = "bold",
				scrollbar = false,
			},
			ghost_text = {
				enabled = false,
			},
		},
		snippets = { preset = "luasnip" },
		sources = {
			default = { "copilot", "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					-- make lazydev completions top priority (see `:h blink.cmp`)
					score_offset = 100,
				},
				copilot = {
					name = "copilot",
					module = "blink-copilot",
					score_offset = 100,
					async = true,
					},
			},
		},
		signature = {
			enabled = true,
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}