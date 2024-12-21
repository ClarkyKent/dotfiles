return {
	-- amongst your other plugins
	{
		'akinsho/toggleterm.nvim',
		version = "*",
		opts = {
			open_mapping = [[<c-\>]],
			direction = 'float',
			hide_numbers = true,   -- hide the number column in toggleterm buffers
			start_in_insert = true,
			insert_mappings = true, -- whether or not the open mapping applies in insert mode
			terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
			persist_size = true,
			persist_mode = true,   -- if set to true (default) the previous terminal mode will be remembered
			clear_env = false,     -- use only environmental variables from `env`, passed to jobstart()
			auto_scroll = true,    -- automatically scroll to the bottom on terminal output
			float_opts = {
				border = 'curved',
				winblend = 3,
				title_pos = 'right',
			},
			responsiveness = {
				horizontal_breakpoint = 135,
			}
		}
	}
}
