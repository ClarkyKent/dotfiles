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
        meson = { "meson_format", lsp_format = "fallback" },
      },
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- Deal with clang-format
        ["clang-format"] = {
          prepend_args = { "--style=file" },
        },
        meson_format = {
          command = "meson",
          args = function(self, ctx)
            local args = { "format", "-i" }
            -- Look for meson.format config file
            local config_file = vim.fn.findfile("meson.format", ctx.dirname .. ";")
            if config_file ~= "" then
              table.insert(args, "-c")
              table.insert(args, config_file)
            end
            table.insert(args, "$FILENAME")
            return args
          end,
          stdin = false,
          tempfile_format = ".meson.build",
        },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}