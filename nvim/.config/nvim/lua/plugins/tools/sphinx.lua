return {
    'stsewd/sphinx.nvim',
    event = { "BufReadPre", "BufNewFile" },
    ft = { 'rst' },
    build = ':UpdateRemotePlugins',
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {
        -- Sphinx source directory (where conf.py is located)
        src_dir = "docs",
        -- Sphinx build directory (where output files are generated)
        build_dir = "_buildresults/docs",
        -- Default builder (html, latex, epub, etc.)
        builder = "html",
        -- Additional sphinx-build options
        options = {}
    },
}
