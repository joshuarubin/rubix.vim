local alternate = require("rubix/alternate")
local format = require("rubix/format")
local go = require("rubix/go")
local only = require("rubix/only")

local M = {}

M.setup = function()
	alternate.setup()
	format.setup()
	go.setup()
	only.setup()
end

if not vim.g.vscode then
	M.cmp = require("rubix/cmp")
end

return M
