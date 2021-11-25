local M = {}

local utils = require("sphinx-wiki.utils")

M.setup = function()

    -- TODO: Is this needed?
    vim.g.rst_style = 1

    -- Env variables that need to be setup
    local vimwiki_env = "VIMWIKI"
    -- local syspython_bin_env = "SYSPYTHON_BIN"

    -- Get environment table
    local environ_table = vim.fn.environ()

    -- Get values for both env variables
    local wikipath = environ_table[vimwiki_env]
    -- local syspython_bin = environ_table[syspython_bin_env]

    -- Check that variables and their values exist and that they are valid
    -- paths to existing directories.
    utils.check_wikienv(vimwiki_env, wikipath)

    -- Resolve full command to build wiki
    -- local sphinx_full_cmd = "lua require('sphinx-wiki.utils').wiki_build()"

    -- Register vim autocmds and commands
    -- vim.cmd("")
    vim.cmd [[
        augroup rst_aus
            autocmd!
            autocmd! BufReadPost ~/sphinx_wiki/diary/diary.rst $
        augroup end

        command! WikiBuild lua require("sphinx-wiki.utils").wiki_build()
        command! Wiki lua require("sphinx-wiki.utils").wiki()
        command! WikiImgShow lua require("sphinx-wiki.utils").wiki_img_show()
        command! WikiImgEdit lua require("sphinx-wiki.utils").wiki_img_edit()
        command! WikiOpen lua require("sphinx-wiki.utils").open_wiki_html()
        command! WikiServe lua require("sphinx-wiki.utils").wiki_serve()
    ]]

end
return M
