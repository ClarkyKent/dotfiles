-- Treesitter (nvim-treesitter `main` branch API, Neovim 0.11+)
--
-- Parser set is driven by what this workstation actually edits: embedded C/C++
-- firmware (Meson + arm-none-eabi), Rust tooling, Python/Robot Framework test
-- harnesses, and Sphinx/RST docs.
local PARSERS = {
  -- Core / editor
  "lua",
  "vim",
  "vimdoc",
  "query",
  "regex",
  "comment",
  "diff",
  "printf",

  -- C / C++ firmware
  "c",
  "cpp",
  "doxygen",

  -- Embedded-specific
  "asm", -- ARM / inline assembly
  "linkerscript", -- *.ld
  "devicetree", -- *.dts / *.dtsi
  "kconfig", -- Kconfig
  "objdump",
  "disassembly",

  -- Build systems
  "meson",
  "ninja",
  "cmake", -- parsing/lint only; not used to build this project
  "make",
  "just", -- .justfile is the primary task interface

  -- Rust
  "rust",

  -- Python / test tooling
  "python",
  "robot", -- Robot Framework
  "requirements",

  -- Data / config
  "json",
  "yaml",
  "toml",
  "xml",
  "csv",
  "editorconfig",
  "ssh_config",
  "dockerfile",

  -- Docs
  "markdown",
  "markdown_inline",
  "rst",

  -- Git
  "gitcommit",
  "gitignore",
  "git_config",
  "git_rebase",

  -- Web (occasional)
  "html",
  "css",
  "javascript",
  "typescript",
  "bash",
}

-- Filetypes that should get treesitter highlighting. Derived from PARSERS but
-- filetype names do not always match parser names.
local HIGHLIGHT_FILETYPES = {
  "asm",
  "bash",
  "c",
  "cmake",
  "cpp",
  "css",
  "csv",
  "devicetree",
  "diff",
  "dockerfile",
  "dts",
  "editorconfig",
  "gitcommit",
  "gitconfig",
  "gitignore",
  "gitrebase",
  "html",
  "javascript",
  "json",
  "jsonc",
  "just",
  "kconfig",
  "ld",
  "lua",
  "make",
  "markdown",
  "meson",
  "ninja",
  "python",
  "requirements",
  "robot",
  "rst",
  "rust",
  "sh",
  "toml",
  "typescript",
  "vim",
  "xml",
  "yaml",
  "query",
}

-- Filetype -> parser, where the names differ.
local FT_TO_PARSER = {
  sh = "bash",
  dts = "devicetree",
  ld = "linkerscript",
  gitconfig = "git_config",
  gitrebase = "git_rebase",
  jsonc = "json",
  tsx = "typescript",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    keys = {
      {
        "<C-space>",
        function()
          require("config.tsincremental").expand()
        end,
        mode = { "n", "x" },
        desc = "Increment selection",
      },
      {
        "<BS>",
        function()
          require("config.tsincremental").shrink()
        end,
        mode = "x",
        desc = "Decrement selection",
      },
    },
    config = function()
      require("nvim-treesitter").setup({})

      -- ── Parser installation ───────────────────────────────────────────
      -- Install only what is missing, asynchronously, so startup is never
      -- blocked by compilation. Previously this config never installed
      -- anything, which meant *zero* parsers were present and every
      -- `vim.treesitter.start()` failed silently inside a pcall.
      local function missing_parsers()
        local missing = {}
        for _, lang in ipairs(PARSERS) do
          if not vim.treesitter.language.add(lang) then
            missing[#missing + 1] = lang
          end
        end
        return missing
      end

      -- The `main` branch of nvim-treesitter shells out to the `tree-sitter`
      -- CLI (>= 0.26.1) to build grammars. Without it every install emits a
      -- separate ENOENT error, so fail once, loudly, with a fix.
      local function have_cli()
        if vim.fn.executable("tree-sitter") == 1 then
          return true
        end
        -- Devbox/nix shells rewrite PATH and can hide a user-level install.
        for _, dir in ipairs({ "~/.nix-profile/bin", "~/.cargo/bin", "~/.local/bin" }) do
          local candidate = vim.fn.expand(dir .. "/tree-sitter")
          if vim.fn.executable(candidate) == 1 then
            vim.env.PATH = vim.fn.expand(dir) .. ":" .. vim.env.PATH
            return true
          end
        end
        return false
      end

      local function install(langs, opts)
        opts = opts or {}
        if #langs == 0 then
          if opts.notify_empty then
            vim.notify("All treesitter parsers present", vim.log.levels.INFO, { title = "treesitter" })
          end
          return
        end
        if not have_cli() then
          vim.notify(
            ("%d treesitter parsers are missing, but the `tree-sitter` CLI was not found.\n\n"):format(#langs)
              .. "Install it with:  nix profile add nixpkgs#tree-sitter\n\n"
              .. "(Mason's prebuilt binary and the npm/cargo builds both require\n"
              .. " glibc >= 2.38; Debian 12 ships 2.36. The nix build bundles its own.)\n\n"
              .. "Then run :TSSync",
            vim.log.levels.WARN,
            { title = "treesitter" }
          )
          return
        end
        vim.notify(
          ("Installing %d treesitter parsers in the background: %s"):format(#langs, table.concat(langs, ", ")),
          vim.log.levels.INFO,
          { title = "treesitter" }
        )
        require("nvim-treesitter").install(langs)
      end

      vim.api.nvim_create_user_command("TSSync", function()
        install(missing_parsers(), { notify_empty = true })
      end, { desc = "Install any missing treesitter parsers" })

      -- Auto-install on first start after a config change. Deferred so it
      -- never delays the first paint.
      vim.defer_fn(function()
        install(missing_parsers())
      end, 2000)

      -- ── Highlighting / indent / folding ───────────────────────────────
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        pattern = HIGHLIGHT_FILETYPES,
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = FT_TO_PARSER[ft] or ft

          -- Do not attempt to start if the parser is genuinely absent;
          -- fall back to the legacy syntax engine instead of ending up with
          -- no highlighting at all.
          if not vim.treesitter.language.add(lang) then
            return
          end

          pcall(vim.treesitter.start, args.buf, lang)

          -- Treesitter indent (opt-in per filetype: it is noticeably worse
          -- than the builtin indentexpr for C and Lua).
          if vim.tbl_contains({ "python", "yaml", "json", "rust", "robot" }, ft) then
            vim.bo[args.buf].indentexpr = 'v:lua.require("nvim-treesitter").indentexpr()'
          end

          -- Treesitter folding, opened by default.
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldenable = false
        end,
      })
    end,
  },

  -- ── Textobjects ─────────────────────────────────────────────────────
  -- Replaces the previous hand-rolled `select_node` helper, which was broken:
  -- `af`/`if` were identical, `ac`/`ic` were identical, it ran `normal! V`
  -- from operator-pending mode, and `<bs>` merely swapped selection ends
  -- instead of shrinking the selection.
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      local function sel(key, capture, desc)
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(capture, "textobjects")
        end, { desc = desc, silent = true })
      end

      -- Functions
      sel("af", "@function.outer", "Around function")
      sel("if", "@function.inner", "Inside function")
      -- Classes / structs
      sel("ac", "@class.outer", "Around class/struct")
      sel("ic", "@class.inner", "Inside class/struct")
      -- Parameters -- essential for C APIs with long argument lists
      sel("aa", "@parameter.outer", "Around parameter")
      sel("ia", "@parameter.inner", "Inside parameter")
      -- Conditionals & loops
      sel("ai", "@conditional.outer", "Around conditional")
      sel("ii", "@conditional.inner", "Inside conditional")
      sel("al", "@loop.outer", "Around loop")
      sel("il", "@loop.inner", "Inside loop")
      -- Calls, blocks, comments
      sel("aC", "@call.outer", "Around call")
      sel("iC", "@call.inner", "Inside call")
      sel("ab", "@block.outer", "Around block")
      sel("ib", "@block.inner", "Inside block")
      sel("a/", "@comment.outer", "Around comment")
      sel("i/", "@comment.inner", "Inside comment")

      local function mv(key, fn, capture, desc)
        vim.keymap.set({ "n", "x", "o" }, key, function()
          move[fn](capture, "textobjects")
        end, { desc = desc, silent = true })
      end

      -- Movement
      mv("]f", "goto_next_start", "@function.outer", "Next function start")
      mv("[f", "goto_previous_start", "@function.outer", "Prev function start")
      mv("]F", "goto_next_end", "@function.outer", "Next function end")
      mv("[F", "goto_previous_end", "@function.outer", "Prev function end")
      mv("]c", "goto_next_start", "@class.outer", "Next class start")
      mv("[c", "goto_previous_start", "@class.outer", "Prev class start")
      mv("]a", "goto_next_start", "@parameter.inner", "Next parameter")
      mv("[a", "goto_previous_start", "@parameter.inner", "Prev parameter")

      -- Swap -- reorder function arguments / struct fields in place
      vim.keymap.set("n", "<leader>cA", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap parameter next" })
      vim.keymap.set("n", "<leader>cP", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap parameter previous" })
    end,
  },
}
