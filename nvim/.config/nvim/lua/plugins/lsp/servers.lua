return {

  -- bash
  bashls = {
    filetypes = { "sh", "aliasrc" },
  },
  -- C/C++
  clangd = {
    cmd = {
      "clangd",
      "--offset-encoding=utf-16",
      "--log=verbose",
      "--completion-style=detailed",
      "--query-driver=/usr/bin/arm-none-eabi-*",
      "--pretty",
      --compile-commands-dir=
      "--background-index",
      "--clang-tidy",
      "--enable-config",
      "-j=2",
    },
    init_options = {
      clangdFileStatus = true,
      completeUnimported = true,
      usePlaceholders = true,
      semanticHighlighting = true,
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    root_markers = {
      ".clangd",
      "Makefile",
      "build.ninja",
      "compile_commands.json",
      "configure.in",
      "meson.build",
    },
    settings = {
      clangd = {
        semanticHighlighting = true,
        single_file_support = false,
      },
    },
    single_file_support = true,
  },
  -- docker
  dockerls = {},
  lua_ls = {
    settings = { -- custom settings for lua
      Lua = {
        -- make the language server recognize "vim" global
        diagnostics = {
          globals = { "vim" },
        },
        format = {
          enable = true,
          defaultConfig = {
            align_continuous_assign_statement = false,
            align_continuous_rect_table_field = false,
            align_array_table = false,
          },
        },
        workspace = {
          library = {
            vim.fn.expand("$VIMRUNTIME/lua"),
            vim.fn.expand("$XDG_CONFIG_HOME") .. "/nvim/lua",
          },
        },
      },
    },
  },
  ruff = {},
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
        },
      },
    },
  },
  jsonls = { filetypes = { "json", "jsonc" } },
}
