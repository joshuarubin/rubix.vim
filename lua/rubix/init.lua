local alternate = require("rubix/alternate")
local go = require("rubix/go")
local only = require("rubix/only")

local M = {}

M.setup = function()
	alternate.setup()
	go.setup()
	only.setup()
end

return M
