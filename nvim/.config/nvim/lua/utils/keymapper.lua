local vim_modes = {
	n = "n",
	i = "i",
	v = "v",
}

local default_opts = {
	noremap = true,
	silent = true,
}

--- @param opts (table|nil)
--- @return table
local get_opts = function(opts)
	local all_opts = opts
	if all_opts == nil then
		all_opts = {}
	end
	for k, v in pairs(default_opts) do
		all_opts[k] = all_opts[k] or v
	end
	return all_opts
end

--- @param vimmode (string|nil)
--- @return string
local get_mode = function(vimmode)
	local modeString = vim_modes[vimmode]
	if modeString == nil then
		return "n"
	else
		return modeString
	end
end

--- @param command (string)
--- @return string
local get_cmd_string = function(command)
	return [[<cmd>]] .. command .. [[<CR>]]
end

--- @param keymaps string
--- @param command string
--- @param vimmode (string|nil)
--- @param options (table|nil)
--- @return nil
local mapvimkey = function(keymaps, command, vimmode, options)
	local mode = get_mode(vimmode)
	local lhs = keymaps
	local rhs = get_cmd_string(command)
	local opts = get_opts(options)
	vim.keymap.set(mode, lhs, rhs, opts)
end

--- @param keymaps string
--- @param cmd (function|string)
--- @param desc (string|nil)
--- @return table
local maplazykey = function(keymaps, cmd, desc)
	if type(cmd) ~= "function" then
		cmd = get_cmd_string(cmd)
	end
	return { keymaps, cmd, desc = desc }
end

return {
	mapvimkey = mapvimkey,
	maplazykey = maplazykey,
}

{
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Ensure mason installs the server
      clangd = {
        keys = {
          { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
        },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern(
            "Makefile",
            "configure.ac",
            "configure.in",
            "config.h.in",
            "meson.build",
            "meson_options.txt",
            "build.ninja"
          )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
            fname
          ) or require("lspconfig.util").find_git_ancestor(fname)
        end,
        capabilities = {
          offsetEncoding = { "utf-16" },
        },
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      },
    },
    setup = {
      clangd = function(_, opts)
        local clangd_ext_opts = LazyVim.opts("clangd_extensions.nvim")
        require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
        return false
      end,
    },
  },
}