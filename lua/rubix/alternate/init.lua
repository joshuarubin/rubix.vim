local dir = require("rubix/dir")

local M = {}

local extensions = {
	h = { "c", "cpp", "cxx", "cc", "CC" },
	H = { "C", "CPP", "CXX", "CC" },
	hpp = { "cpp", "c" },
	HPP = { "CPP", "C" },
	c = { "h" },
	C = { "H" },
	cpp = { "h", "hpp" },
	CPP = { "H", "HPP" },
	cc = { "h" },
	CC = { "H", "h" },
	cxx = { "h" },
	CXX = { "H" },
}

local function alternate(opts)
	opts = opts or { args = "" }

	local cmd = "edit"
	if opts.args == "v" then
		cmd = "vsplit"
	elseif opts.args == "s" then
		cmd = "split"
	end

	local buf = vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(buf)
	local bufext = vim.fn.fnamemodify(name, ":e")
	local exts = extensions[bufext]

	if not exts then
		return
	end

	local basename = vim.fn.fnamemodify(vim.fs.basename(name), ":r")
	local projectdir = dir.project()

	for _, ext in ipairs(exts) do
		local file = basename .. "." .. ext
		local paths = vim.fs.find(file, { path = projectdir })

		for _, ret in ipairs(paths) do
			vim.cmd[cmd](ret)
			return
		end
	end
end

M.setup = function()
	vim.api.nvim_create_user_command("A", alternate, {
		nargs = "?",
		desc = "Switch between header and source files",
	})

	vim.api.nvim_create_user_command("AV", function(opts)
		opts.args = "v"
		alternate(opts)
	end, {
		nargs = "?",
		desc = "Switch between header and source files with vertical split",
	})

	vim.api.nvim_create_user_command("AS", function(opts)
		opts.args = "s"
		alternate(opts)
	end, {
		nargs = "?",
		desc = "Switch between header and source files with horizontal split",
	})
end

return M
