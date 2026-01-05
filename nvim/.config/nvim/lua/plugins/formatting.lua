return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },
    opts = {
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        python = { "ruff_format", "ruff_organize_imports" },
        rust = { "rustfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        cmake = { "cmake_format" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ["_"] = { "trim_whitespace" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        toml = { "taplo" },
        meson = { lsp_format = "prefer" }, -- mesonlsp provides formatting
      },
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- Deal with clang-format
        ["clang-format"] = {
          prepend_args = { "--style=file" },
        },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}