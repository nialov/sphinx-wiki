local path = require("plenary.path")

local template_path = path:new("~/sphinx_wiki/template.svg")

local M = {}

local inkscape_img = function(img_filename, make_copy)
    -- Check that template svg exists.

    if vim.fn.filereadable(tostring(template_path:expand())) == 0 then
        error("Could not find template svg file at: " .. tostring(template_path))
        return
    end

    if make_copy then

        -- Copy template to img_filename
        vim.cmd(string.format("!cp %s %s", template_path, img_filename))
    end

    -- Start inkscape with img_filename
    vim.cmd(string.format("!inkscape %s", img_filename))

end

local get_img_path_at_current_line = function()
    -- Get current line
    local current_line = vim.api.nvim_get_current_line()
    -- Either match figure or img in current line
    local fig_or_img_match = string.match(current_line, "figure") or
                                 string.match(current_line, "image")
    -- If no match then exit with print
    if not fig_or_img_match or #fig_or_img_match == 0 then
        print("No img or fig found on line " .. vim.fn.line(".") .. ".")
        return
    end
    -- If matched then find the filename at the end after figure or img
    local _, _, captured_filename = string.find(current_line, string.format(
                                                    ".*%s:: (.+)",
                                                    fig_or_img_match))
    print("Found filename: " .. captured_filename)
    -- use plenary.path to join the relative img filepath with absolute
    -- path to current file. I.e. image path must be relative to current file's
    -- parent directory.
    local img_filename = path:new(vim.fn.expand("%:p")):parent():joinpath(
                             captured_filename)
    return img_filename
end

M.open_wiki_html = function()
    local curr_file = vim.fn.expand('%')
    local html_file_base = vim.fn.substitute(curr_file, 'sphinx_wiki',
                                             'sphinx_wiki_html', '')
    local html_file = '~/' ..
                          vim.fn.substitute(html_file_base, '.rst', '.html', '')
    print(html_file)
    vim.fn.system('xdg-open ' .. html_file)
end

M.wiki = function()
    local proj_wiki_file = vim.fn.system("projwiki")
    if not proj_wiki_file or #proj_wiki_file == 0 then return end
    print(proj_wiki_file)
    vim.cmd("e" .. proj_wiki_file)
end

M.wiki_img_show = function()
    local img_filename = get_img_path_at_current_line()
    -- Check if img exists at path
    if vim.fn.filereadable(tostring(img_filename)) == 0 then
        -- If not then report to use and do nothing
        print("No img file found at: " .. tostring(img_filename))
        return
    end
    local full_cmd = "!xdg-open " .. tostring(img_filename)
    vim.cmd(full_cmd)
end

M.wiki_img_edit = function()
    if vim.fn.executable("inkscape") ~= 1 then
        error("No inkscape executable found. Install before running this cmd.")
    end
    local img_filename = get_img_path_at_current_line()
    -- Check if img exists at path
    if vim.fn.filereadable(tostring(img_filename)) == 0 then
        if vim.fn.isdirectory(path:new(img_filename):parent()) == 0 then
            error("No parent directory for img file at: " .. img_filename)
            return
        end
        -- If not and parent dir exists then open inkscape to make a new one
        inkscape_img(img_filename, true)
    end
    -- Open found file with inkscape for editing
    inkscape_img(img_filename, false)
end

return M
