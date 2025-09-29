-- Formatting configuration with clang-format and format-on-save
return {
  -- Code formatting with conform.nvim
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      -- Define formatters by file type
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        objc = { "clang_format" },
        objcpp = { "clang_format" },
        cuda = { "clang_format" },
        proto = { "clang_format" },
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
      },
      -- Format on save configuration
      format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_fallback = true,
      },
      -- Custom formatter configurations
      formatters = {
        clang_format = {
          command = "clang-format",
          args = { "--style=file", "--fallback-style=LLVM" },
          stdin = true,
        },
        stylua = {
          prepend_args = { "--config-path", vim.fn.expand("~/.stylua.toml") },
        },
      },
    },
    init = function()
      -- If you want to use format-on-save, you can optionally set a vim option
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },

  -- Mason tool installer for formatters
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "clang-format",
        "stylua",
        "prettier",
        "black",
        "shfmt",
      })
    end,
  },
}