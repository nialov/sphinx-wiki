local M = {}

local check_env_variables =
    function(wikipath) return wikipath and #wikipath > 0 end

local check_paths =
    function(wikipath) return vim.fn.isdirectory(wikipath) == 1 end

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
    if not check_env_variables(wikipath) then
        error(vimwiki_env .. " must be non-empty defined env variable.")
    end
    if not check_paths(wikipath) then
        error(string.format("Wiki directory at %s must exist.", wikipath))
    end

    -- Sphinx-build should be installed to $PATH (recommended with pipx)
    local sphinx_path = "sphinx-build"

    -- Check it
    if vim.fn.executable(sphinx_path) ~= 1 then
        error(string.format("%s should be executable.", sphinx_path))
    end

    -- Resolve full command to build wiki
    local sphinx_args = wikipath .. " ~/sphinx_wiki_html -b html"
    local sphinx_full_cmd = sphinx_path .. " " .. sphinx_args

    -- Register vim autocmds and commands
    vim.cmd("command! WikiBuild Dispatch " .. sphinx_full_cmd)
    vim.cmd [[
        augroup rst_aus
            autocmd!
            autocmd! BufReadPost ~/sphinx_wiki/diary/diary.rst $
        augroup end

        command! Wiki lua require("sphinx-wiki.utils").wiki()
        command! WikiImgShow lua require("sphinx-wiki.utils").wiki_img_show()
        command! WikiImgEdit lua require("sphinx-wiki.utils").wiki_img_edit()
        command! WikiOpen lua require("sphinx-wiki.utils").open_wiki_html()
    ]]

end
return M
