-- lua/custom/plugins/mini.lua
return {
	{
		'echasnovski/mini.nvim',
		enabled = true,
		config = function()
			local statusline = require 'mini.statusline'
			statusline.setup { use_icons = true }
			local icons = require 'mini.icons'
			icons.setup { style = 'glyph' }
			local notify = require 'mini.notify'
			notify.setup { style = 'glyph' }
			local clue = require 'mini.clue'
			clue.setup {
				triggers = {
					-- Leader triggers
					{ mode = 'n', keys = '<Leader>' },
					{ mode = 'x', keys = '<Leader>' },
				},
				clues = {
					-- Enhance this by adding descriptions for <Leader> mapping groups
					clue.gen_clues.builtin_completion(),
					clue.gen_clues.g(),
					clue.gen_clues.marks(),
					clue.gen_clues.registers(),
					clue.gen_clues.windows(),
					clue.gen_clues.z(),
				},
				window = {
					-- Floating window config
					config = {},
				}
			}
		end,
	},
}
