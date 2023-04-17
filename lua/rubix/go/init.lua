local M = {}

local template_file = [[
package main

func main() {
	
}]]

local template_test_file = [[


import "testing"

func TestFoo(t *testing.T) {
	
}]]

local function template_create()
	local olddir = vim.fn.getcwd()
	local wd = vim.fn.expand("%:p:h")
	vim.cmd("lcd " .. vim.fn.fnameescape(wd))

	local go = function(args)
		if vim.fn.executable("go") ~= 1 then
			return ""
		end

		return vim.trim(vim.fn.system("go " .. args .. " 2>/dev/null"))
	end

	local package = go("list -f {{.Name}}")
	local mod_dir = go("list -m -f {{.Dir}}")

	local content = ""
	local pos = { 1, 0 }
	local new_package = true

	if package == "" and mod_dir ~= "" and mod_dir ~= wd then
		-- we are in an empty directory that is the subdirectory of a module
		-- use the directory name as the package name
		package = vim.fn.fnamemodify(wd, ":t")
	elseif package == "" then
		-- there are no other go files in this directory and we are not in a
		-- subdirectory of a module
		package = "main"
	else
		-- we are in a directory with other go files
		new_package = false
	end

	local filename = vim.fn.expand("%:t")

	if string.match(filename, "_test%.go$") ~= nil then
		content = "package " .. package .. template_test_file
		pos = { 6, 0 }
	elseif package == "main" and new_package then
		content = template_file
		pos = { 4, 0 }
	else
		content = "package " .. package .. "\n\n"
		pos = { 3, 0 }
	end

	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n"))
	vim.api.nvim_win_set_cursor(0, pos)

	vim.cmd("lcd " .. vim.fn.fnameescape(olddir))
end

M.setup = function()
	vim.api.nvim_create_autocmd("BufNewFile", {
		pattern = "*.go",
		callback = template_create,
	})
end

return M
