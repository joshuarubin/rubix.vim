local go = require("rubix/go")
local dir = require("rubix/dir")

local M = {}

local function only(opts)
	local force = opts.bang or false

	local visible = {}
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
			local buf = vim.api.nvim_win_get_buf(win)
			visible[buf] = true
		end
	end

	local tally = 0
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if
			visible[buf] == nil
			and not vim.api.nvim_buf_get_option(buf, "modified")
			and (force or vim.api.nvim_buf_get_option(buf, "buftype") ~= "terminal")
		then
			if vim.api.nvim_buf_get_option(buf, "buftype") ~= "nofile" then
				tally = tally + 1
			end
			vim.api.nvim_buf_delete(buf, {
				force = force,
			})
		end
	end

	if tally > 0 then
		vim.notify("Deleted " .. tally .. " buffers", vim.log.levels.INFO)
	end
end

local function c_switch(opts)
	local buf = vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(buf)

	local find, matched = name:gsub("(%w+%.)c(p?p?)", "%1h%2")

	if matched == 0 then
		find, matched = name:gsub("(%w+%.)h(p?p?)", "%1c%2")
	end

	if matched == 0 then
		return
	end

	local paths = vim.fs.find(vim.fs.basename(find), {
		path = dir.project(),
	})

	for _, ret in ipairs(paths) do
		vim.cmd.edit(ret)
		return
	end
end

M.setup = function()
	vim.api.nvim_create_user_command("Only", only, {
		bang = true,
		desc = "Delete all buffers that are not visible",
	})

	vim.api.nvim_create_user_command("A", c_switch, {
		desc = "Switch between C header and source files",
	})

	go.setup()
end

return M
