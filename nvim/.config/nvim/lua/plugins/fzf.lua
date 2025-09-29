-- Fuzzy finder configuration based on LazyVim
-- Simplified for standalone use without LazyVim dependencies

local function symbols_filter(opts, info, symbol)
  if symbol.kind == 5 then -- Variable
    return symbol.name ~= "self"
  end
  return true
end

-- Helper function for root-aware commands
local function get_root_dir()
  local buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(buf)
  if path == "" then
    return vim.fn.getcwd()
  end
  
  -- Try to find git root
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.fnamemodify(path, ":h") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error == 0 then
    return git_root
  end
  
  -- Fall back to current working directory
  return vim.fn.getcwd()
end

local function root_cmd(cmd, opts)
  opts = opts or {}
  if opts.root ~= false then
    opts.cwd = get_root_dir()
  end
  return function()
    require("fzf-lua")[cmd](opts)
  end
end

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    opts = function()
      local config = require("fzf-lua.config")
      local actions = require("fzf-lua.actions")

      -- Trouble integration with better error handling
      local trouble_ok, trouble = pcall(require, "trouble")
      if trouble_ok then
        local sources_ok, trouble_sources = pcall(require, "trouble.sources.fzf")
        if sources_ok and trouble_sources.actions then
          config.defaults.actions.files["ctrl-t"] = trouble_sources.actions.open
        end
      end

      -- Toggle root dir / cwd
      config.defaults.actions.files["ctrl-r"] = function(_, ctx)
        local o = vim.deepcopy(ctx.__call_opts)
        o.root = o.root == false
        o.cwd = nil
        o.buf = ctx.__CTX.bufnr
        require("fzf-lua")[ctx.__INFO.cmd](o)
      end
      config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]
      config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

      -- Image previewer setup
      local img_previewer ---@type string[]?
      for _, v in ipairs({
        { cmd = "ueberzug", args = {} },
        { cmd = "chafa", args = { "{file}", "--format=symbols" } },
        { cmd = "viu", args = { "-b" } },
      }) do
        if vim.fn.executable(v.cmd) == 1 then
          img_previewer = vim.list_extend({ v.cmd }, v.args)
          break
        end
      end

      return {
        "default-title",
        fzf_colors = true,
        fzf_opts = {
          ["--no-scrollbar"] = true,
        },
        defaults = {
          formatter = "path.dirname_first",
        },
        previewers = {
          builtin = {
            extensions = {
              ["png"] = img_previewer,
              ["jpg"] = img_previewer,
              ["jpeg"] = img_previewer,
              ["gif"] = img_previewer,
              ["webp"] = img_previewer,
            },
          },
        },
        ui_select = function(fzf_opts, items)
          return vim.tbl_deep_extend("force", {
            prompt = " ",
            winopts = {
              title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
              title_pos = "center",
            },
          }, fzf_opts.kind == "codeaction" and {
            winopts = {
              layout = "vertical",
              height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 4) + 0.5) + 16,
              width = 0.5,
              preview = not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
                layout = "vertical",
                vertical = "down:15,border-top",
                hidden = "hidden",
              } or {
                layout = "vertical", 
                vertical = "down:15,border-top",
              },
            },
          } or {
            winopts = {
              width = 0.5,
              height = math.floor(math.min(vim.o.lines * 0.8, #items + 4) + 0.5),
            },
          })
        end,
        winopts = {
          width = 0.8,
          height = 0.8,
          row = 0.5,
          col = 0.5,
          preview = {
            scrollchars = { "┃", "" },
          },
        },
        files = {
          cwd_prompt = false,
          actions = {
            ["alt-i"] = { actions.toggle_ignore },
            ["alt-h"] = { actions.toggle_hidden },
          },
        },
        grep = {
          actions = {
            ["alt-i"] = { actions.toggle_ignore },
            ["alt-h"] = { actions.toggle_hidden },
          },
        },
        lsp = {
          symbols = {
            symbol_hl = function(s)
              return "TroubleIcon" .. s
            end,
            symbol_fmt = function(s)
              return s:lower() .. "\t"
            end,
            child_prefix = false,
          },
          code_actions = {
            previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
          },
        },
      }
    end,
    config = function(_, opts)
      if opts[1] == "default-title" then
        local function fix(t)
          t.prompt = t.prompt ~= nil and " " or nil
          for _, v in pairs(t) do
            if type(v) == "table" then
              fix(v)
            end
          end
          return t
        end
        opts = vim.tbl_deep_extend("force", fix(require("fzf-lua.profiles.default-title")), opts)
        opts[1] = nil
      end
      require("fzf-lua").setup(opts)
    end,
    init = function()
      -- Register ui.select handler
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "fzf-lua" } })
        local fzf_lua_opts = require("fzf-lua").config
        require("fzf-lua").register_ui_select(fzf_lua_opts.ui_select or nil)
        return vim.ui.select(...)
      end
    end,
    keys = {
      { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
      { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },
      {
        "<leader>,",
        "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Switch Buffer",
      },
      { "<leader>/", root_cmd("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      { "<leader><space>", root_cmd("files"), desc = "Find Files (Root Dir)" },
      -- find
      { "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>fc", function() require("fzf-lua").files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff", root_cmd("files"), desc = "Find Files (Root Dir)" },
      { "<leader>fF", root_cmd("files", { root = false }), desc = "Find Files (cwd)" },
      { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Files (git-files)" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
      { "<leader>fR", function() require("fzf-lua").oldfiles({ cwd = vim.uv.cwd() }) end, desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Commits" },
      { "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Status" },
      -- search
      { '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
      { "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", desc = "Buffer" },
      { "<leader>sc", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document Diagnostics" },
      { "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics" },
      { "<leader>sg", root_cmd("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>sG", root_cmd("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>sH", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
      { "<leader>sL", "<cmd>FzfLua highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
      { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
      { "<leader>sl", "<cmd>FzfLua loclist<cr>", desc = "Location List" },
      { "<leader>sM", "<cmd>FzfLua man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Jump to Mark" },
      { "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume" },
      { "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
      { "<leader>sw", root_cmd("grep_cword"), desc = "Word (Root Dir)" },
      { "<leader>sW", root_cmd("grep_cword", { root = false }), desc = "Word (cwd)" },
      { "<leader>sw", root_cmd("grep_visual"), mode = "v", desc = "Selection (Root Dir)" },
      { "<leader>sW", root_cmd("grep_visual", { root = false }), mode = "v", desc = "Selection (cwd)" },
      
      -- Harpoon integration with FZF
      { "<leader>sh", function()
        local harpoon = require("harpoon")
        local list = harpoon:list()
        local items = {}
        
        for i = 1, list:length() do
          local item = list:get(i)
          if item then
            table.insert(items, string.format("%d: %s", i, item.value))
          end
        end
        
        if #items == 0 then
          vim.notify("No Harpoon marks found", vim.log.levels.WARN)
          return
        end
        
        require("fzf-lua").fzf_exec(items, {
          prompt = "Harpoon❯ ",
          actions = {
            ["default"] = function(selected, opts)
              if selected and #selected > 0 then
                local idx = tonumber(selected[1]:match("^(%d+):"))
                if idx then
                  harpoon:list():select(idx)
                end
              end
            end,
            ["ctrl-d"] = function(selected, opts)
              if selected and #selected > 0 then
                local idx = tonumber(selected[1]:match("^(%d+):"))
                if idx then
                  harpoon:list():remove_at(idx)
                  vim.notify("󱡀 Removed from Harpoon", vim.log.levels.INFO)
                end
              end
            end,
            ["ctrl-v"] = function(selected, opts)
              if selected and #selected > 0 then
                local idx = tonumber(selected[1]:match("^(%d+):"))
                if idx then
                  local item = harpoon:list():get(idx)
                  if item then
                    vim.cmd("vsplit")
                    vim.api.nvim_command("edit " .. item.value)
                  end
                end
              end
            end,
            ["ctrl-x"] = function(selected, opts)
              if selected and #selected > 0 then
                local idx = tonumber(selected[1]:match("^(%d+):"))
                if idx then
                  local item = harpoon:list():get(idx)
                  if item then
                    vim.cmd("split")
                    vim.api.nvim_command("edit " .. item.value)
                  end
                end
              end
            end,
          },
          winopts = {
            height = 0.6,
            width = 0.8,
            preview = {
              type = "cmd",
              fn = function(items)
                local idx = tonumber(items[1]:match("^(%d+):"))
                if idx then
                  local harpoon = require("harpoon")
                  local item = harpoon:list():get(idx)
                  if item and vim.fn.filereadable(item.value) == 1 then
                    return string.format("cat %q", item.value)
                  end
                end
                return "echo 'No preview available'"
              end,
            },
          },
        })
      end, desc = "Harpoon Files" },
      
      -- Todo search shortcuts in main search menu
      { "<leader>st", function() 
        require("fzf-lua").grep({ 
          search = "TODO|HACK|BUG|NOTE|FIX|FIXME|WARNING|PERF|OPTIMIZE", 
          no_esc = true,
          prompt = "Todo❯ ",
        })
      end, desc = "Todo" },
      { "<leader>sT", function() 
        require("fzf-lua").grep({ 
          search = "TODO|FIX|FIXME|BUG", 
          no_esc = true,
          prompt = "Priority Todo❯ ",
        })
      end, desc = "Priority Todo" },
      { "<leader>uC", "<cmd>FzfLua colorschemes<cr>", desc = "Colorscheme with Preview" },
      {
        "<leader>ss",
        function()
          require("fzf-lua").lsp_document_symbols({
            regex_filter = symbols_filter,
          })
        end,
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        function()
          require("fzf-lua").lsp_live_workspace_symbols({
            regex_filter = symbols_filter,
          })
        end,
        desc = "Goto Symbol (Workspace)",
      },
    },
  },
  
  -- Enhanced todo-comments integration with comprehensive todo list support
  {
    "folke/todo-comments.nvim",
    optional = true,
    keys = {
      -- Basic todo search
      { "<leader>st", function() 
        if pcall(require, "todo-comments.fzf") then
          require("todo-comments.fzf").todo()
        else
          require("fzf-lua").grep({ 
            search = "TODO|HACK|BUG|NOTE|FIX|FIXME|WARNING|PERF|OPTIMIZE", 
            no_esc = true,
            prompt = "Todo❯ ",
          })
        end
      end, desc = "Todo" },
      
      -- High priority todos only
      { "<leader>sT", function() 
        if pcall(require, "todo-comments.fzf") then
          require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME", "BUG" } })
        else
          require("fzf-lua").grep({ 
            search = "TODO|FIX|FIXME|BUG", 
            no_esc = true,
            prompt = "Priority Todo❯ ",
          })
        end
      end, desc = "Todo/Fix/Fixme" },
      
      -- Search specific todo types
      { "<leader>stb", function()
        require("fzf-lua").grep({ 
          search = "\\b(BUG|BUGS?):", 
          no_esc = true,
          prompt = "Bugs❯ ",
        })
      end, desc = "Bugs" },
      
      { "<leader>stf", function()
        require("fzf-lua").grep({ 
          search = "\\b(FIX|FIXME):", 
          no_esc = true,
          prompt = "Fixes❯ ",
        })
      end, desc = "Fixes" },
      
      { "<leader>stn", function()
        require("fzf-lua").grep({ 
          search = "\\b(NOTE|NOTES?):", 
          no_esc = true,
          prompt = "Notes❯ ",
        })
      end, desc = "Notes" },
      
      { "<leader>sth", function()
        require("fzf-lua").grep({ 
          search = "\\b(HACK|HACKS?):", 
          no_esc = true,
          prompt = "Hacks❯ ",
        })
      end, desc = "Hacks" },
      
      { "<leader>stp", function()
        require("fzf-lua").grep({ 
          search = "\\b(PERF|PERFORMANCE|OPTIMIZE):", 
          no_esc = true,
          prompt = "Performance❯ ",
        })
      end, desc = "Performance" },
      
      -- Custom todo search
      { "<leader>stc", function()
        vim.ui.input({ prompt = "Search custom todo: " }, function(input)
          if input and input ~= "" then
            require("fzf-lua").grep({ 
              search = input, 
              no_esc = false,
              prompt = "Custom Todo❯ ",
            })
          end
        end)
      end, desc = "Custom Todo Search" },
      
      -- Todo in current buffer only
      { "<leader>stB", function()
        if pcall(require, "todo-comments.fzf") then
          require("todo-comments.fzf").todo({ cwd = vim.fn.expand("%:h") })
        else
          require("fzf-lua").grep_curbuf({ 
            search = "TODO|HACK|BUG|NOTE|FIX|FIXME|WARNING|PERF",
            prompt = "Buffer Todo❯ ",
          })
        end
      end, desc = "Todo (Buffer)" },
    },
  },
  
  -- LSP integration with fzf-lua
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = function()
      -- Add fzf-lua LSP keymaps if lspconfig is available
      return {}
    end,
    keys = {
      { "gd", "<cmd>FzfLua lsp_definitions jump1=true ignore_current_line=true<cr>", desc = "Goto Definition" },
      { "gr", "<cmd>FzfLua lsp_references jump1=true ignore_current_line=true<cr>", desc = "References", nowait = true },
      { "gI", "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>", desc = "Goto Implementation" },
      { "gy", "<cmd>FzfLua lsp_typedefs jump1=true ignore_current_line=true<cr>", desc = "Goto Type Definition" },
    },
  },
}