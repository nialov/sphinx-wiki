local path = require("plenary.path")

local template_path = path:new("~/sphinx_wiki/template.svg")

local M = {}

M.vimwiki_env = "VIMWIKI"
M.vimwiki_html_env = "VIMWIKI_HTML"

M.sphinx_autobuild = "sphinx-autobuild"
M.sphinx_build = "sphinx-build"
M.ip_addr = "http://localhost:8000"

M.check_env_variables = function(wikipath)
	return wikipath and #wikipath > 0
end

M.check_paths = function(wikipath)
	return vim.fn.isdirectory(wikipath) == 1
end

M.check_wikienv = function(vimwiki_env)
	if not M.check_env_variables(vimwiki_env) then
		error(vimwiki_env .. " must be non-empty defined env variable.")
	end
	local wikipath = vim.fn.environ()[vimwiki_env]
	if not M.check_paths(wikipath) then
		error(string.format("Wiki directory at %s must exist.", wikipath))
	end
end

M.check_wikienv(M.vimwiki_env)

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
	local dispatch = "Dispatch"

	local prefix
	if vim.fn.exists(string.format(":%s", dispatch)) == 1 then
		prefix = dispatch .. " "
	else
		prefix = "!"
	end
	-- Start inkscape with img_filename
	vim.cmd(string.format("%sinkscape %s", prefix, img_filename))
end

local get_img_path_at_current_line = function()
	-- Get current line
	local current_line = vim.api.nvim_get_current_line()
	-- Either match figure or img in current line
	local fig_or_img_match = string.match(current_line, "figure") or string.match(current_line, "image")
	-- If no match then exit with print
	if not fig_or_img_match or #fig_or_img_match == 0 then
		print("No img or fig found on line " .. vim.fn.line(".") .. ".")
		return
	end
	-- If matched then find the filename at the end after figure or img
	local _, _, captured_filename = string.find(current_line, string.format(".*%s:: (.+)", fig_or_img_match))
	print("Found filename: " .. captured_filename)
	-- use plenary.path to join the relative img filepath with absolute
	-- path to current file. I.e. image path must be relative to current file's
	-- parent directory.
	local img_filename = path:new(vim.fn.expand("%:p")):parent():joinpath(captured_filename)
	return img_filename
end

M.resolve_matching_html_file = function()
	-- Get absolute path to current file
	local curr_file = vim.fn.expand("%:p")
	-- Get path to rst wiki and built wiki
	local wikipath, wikipath_html = M.resolve_wiki_paths()

	-- Substitute rst path to the built html path
	local html_file_base = vim.fn.substitute(curr_file, wikipath, wikipath_html, "")
	-- Substitute extension
	local html_file = vim.fn.substitute(html_file_base, ".rst", ".html", "")
	return html_file
end

M.resolve_matching_ip_url = function(html_file)
	local _, wikipath_html = M.resolve_wiki_paths()
	-- Uses the resolved html_file path to create url
	return vim.fn.substitute(html_file, wikipath_html, M.ip_addr, "")
end

M.open_wiki_html = function()
	local html_file = M.resolve_matching_html_file()
	print(string.format("Opening html file at %s", html_file))
	vim.fn.system("xdg-open " .. html_file)
end

M.open_wiki_url = function()
	-- local html_file = M.resolve_matching_html_file()
	local html_url = M.resolve_matching_ip_url(M.resolve_matching_html_file())
	print(string.format("Opening html url at %s", html_url))
	vim.cmd("!xdg-open " .. html_url)
end

M.wiki = function()
	local proj_wiki_file = vim.fn.system("projwiki")
	if not proj_wiki_file or #proj_wiki_file == 0 then
		return
	end
	vim.cmd("e" .. proj_wiki_file)
end

M.wiki_img_show = function()
	local img_filename = get_img_path_at_current_line()
	-- Check if img exists at path
	if not img_filename or vim.fn.filereadable(tostring(img_filename)) == 0 then
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
	if not img_filename then
		return
	end
	-- Check if img exists at path
	if vim.fn.filereadable(tostring(img_filename)) == 0 then
		if vim.fn.isdirectory(tostring(path:new(img_filename):parent())) == 0 then
			error("No parent directory for img file at: " .. img_filename)
			return
		end
		-- If not and parent dir exists then open inkscape to make a new one
		inkscape_img(img_filename, true)
	end
	-- Open found file with inkscape for editing
	inkscape_img(img_filename, false)
end

M.resolve_wiki_paths = function()
	-- Get environment table
	local environ_table = vim.fn.environ()

	-- Get values for both env variables
	local wikipath = environ_table[M.vimwiki_env]
	local wikipath_html = environ_table[M.vimwiki_html_env]

	if not wikipath_html then
		wikipath_html = string.format("%s_html", wikipath)
	end
	-- local syspython_bin = environ_table[syspython_bin_env]
	return vim.fn.expand(wikipath), vim.fn.expand(wikipath_html)
end

local function check_if_executable(executable)
	if vim.fn.executable(executable) ~= 1 then
		error(string.format("%s should be executable.", executable))
	end
end

M.wiki_build = function()
	local wikipath, wikipath_html = M.resolve_wiki_paths()

	check_if_executable(M.sphinx_build)

	-- Resolve full command to build wiki
	-- local sphinx_args = wikipath .. " ~/sphinx_wiki_html -b html"
	local sphinx_args = string.format("%s %s -b html", wikipath, wikipath_html)
	-- local sphinx_full_cmd = sphinx_path .. " " .. sphinx_args
	local sphinx_full_cmd = string.format("%s %s", M.sphinx_build, sphinx_args)

	-- Run with vim-dispatch
	vim.cmd("Dispatch " .. sphinx_full_cmd)
end

M.wiki_serve = function()
	local wikipath, wikipath_html = M.resolve_wiki_paths()

	check_if_executable(M.sphinx_autobuild)

	-- Resolve full command to serve wiki
	local sphinx_args = string.format("%s %s", wikipath, wikipath_html)
	local sphinx_full_cmd = string.format("%s %s", M.sphinx_autobuild, sphinx_args)

	-- Run with vim-dispatch
	vim.cmd("Dispatch! " .. sphinx_full_cmd)

	-- Open file from url
	M.open_wiki_url()
end

return M
