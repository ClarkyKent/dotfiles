local config = function()
  require("nvim-treesitter.configs").setup({
    build = ":TSUpdate",
    indent = {
      enable = true,
    },
    autotag = {
      enable = true,
    },
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    ensure_installed = {
      "vim",
      "regex",
      "rust",
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
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = true,
    },
  })
end

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  config = config,
}
