return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    -- We may want to change the "harpoon" leader to something different than
    -- the leader key
    local our_leader = "<leader>"
    local function keymap_set(mode, key, fn, desc)
      vim.keymap.set(mode, our_leader .. key, fn, { desc = desc })
    end

    keymap_set("n", "a", function()
      harpoon:list():add()
    end, "[A]dd Harpoon")

    vim.keymap.set("n", "<C-S-L>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

    -- Harpoon to targets
    keymap_set("n", "q", function()
      harpoon:list():select(1)
    end, "[q] Harpoon to 1")
    keymap_set("n", "w", function()
      harpoon:list():select(2)
    end, "[w] Harpoon to 2")
    keymap_set("n", "e", function()
      harpoon:list():select(3)
    end, "[e] Harpoon to 3")
    keymap_set("n", "r", function()
      harpoon:list():select(4)
    end, "[r] Harpoon to 4")
    keymap_set("n", "t", function()
      harpoon:list():select(5)
    end, "[t] Harpoon to 5")

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
    vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
  end,
}