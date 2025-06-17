return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function ()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = {
                "vim",
                "regex",
                "meson",
                "cmake",
                "make",
                "ninja",
                "proto",
                "robot",
                "asm",
                "comment",
                "markdown",
                "json",
                "yaml",
                "bash",
                "lua",
                "dockerfile",
                "gitignore",
                "python",
                "toml",
                "c",
                "cpp",
                "rust",
                "just",
            },
            auto_install = true,
            sync_install = false,
            highlight = { enable = true, additional_vim_regex_highlighting = { "ruby" }, },
            indent =  { enable = true },
            autotag = { enable = true },
            event = {
                "BufReadPre",
                "BufNewFile",
            },
            incremental_selection = {
                enable = true,
                keymaps = {
        init_selection = "<CR>",
        scope_incremental = "<CR>",
        node_incremental = "<TAB>",
        node_decremental = "<S-TAB>",
      },
            },
        })
    end
}
