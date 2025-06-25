return {
	"mbbill/undotree",
	-- enabled = false,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local map = vim.keymap.set
		-- keymaps
		map("n", "<leader>uu", "<cmd>UndotreeToggle<cr>", { desc = "UndoTree Toggle", noremap = true, silent = true })
		map("n", "<leader>uf", "<cmd>UndotreeFocus<cr>", { desc = "UndoTree Focus", noremap = true, silent = true })
	end,
}