local util = require('utils.util')

local treesitter_parsers = {
    'bash',
    'c',
    'cpp',
    'gitcommit',
    'html',
    'json',
    'just',
    'lua',
    'markdown',
    'markdown_inline', -- markdown code blocks
    'meson',
    'python',
    'ruby',
    'rust',
    'vim',
    'vimdoc',
    'yaml',
}


local lsp_servers = {
    'bashls',
    'lua_ls',
    'vimls',
    'cmake',
    'stylua',
    'black',
    'json-lsp',
    'prettier',
    'ruff',
    'yaml-language-server',
    'dockerfile-language-server',
    'docker-compose-language-service',
    'rust_analyzer', -- Rust
    'robotframework_ls',
    'clangd',
    'clang-format',
}

-- if util.is_present('npm') then
--     table.insert(lsp_servers, 'eslint')
--     table.insert(lsp_servers, 'ts_ls')
-- end

-- if util.is_present('gem') then
--     table.insert(lsp_servers, 'solargraph')
--     table.insert(lsp_servers, 'rubocop')
-- end

-- if util.is_present('go') then
--     table.insert(lsp_servers, 'gopls')
-- end

-- if util.is_present('dart') then
--     table.insert(lsp_servers, 'dartls')
-- end

-- if util.is_present('java') then
--     table.insert(lsp_servers, 'jdtls')
-- end

-- if util.is_present('pip') then
--     table.insert(lsp_servers, 'ruff')
--     table.insert(lsp_servers, 'pylsp')
-- end

-- if util.is_present('mix') then
--     table.insert(lsp_servers, 'elixirls')
-- end

if util.is_present('cargo') then
    table.insert(lsp_servers, 'rust_analyzer')
end

-- plugins = vim.tbl_extend('force', plugins, util.get_user_config('user_plugins', {}))
lsp_servers = vim.tbl_extend('force', lsp_servers, util.get_user_config('user_lsp_servers', {}))
-- null_ls_sources = vim.tbl_extend('force', null_ls_sources, util.get_user_config('user_null_ls_sources', {}))
treesitter_parsers = vim.tbl_extend('force', treesitter_parsers, util.get_user_config('user_tresitter_parsers', {}))

return {
    -- plugins = plugins,
    lsp_servers = lsp_servers,
    ts_parsers = treesitter_parsers,
}