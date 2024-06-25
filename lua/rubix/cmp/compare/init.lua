local types = require("cmp.types")

local M = {}

-- pulled from from nvim-cmp/lua/cmp/types/lsp.lua
-- move Constant to just above Method in "kind" ordering
local CompletionItemKind = {}
CompletionItemKind[types.lsp.CompletionItemKind.Text] = 1
CompletionItemKind[types.lsp.CompletionItemKind.Constant] = 2
CompletionItemKind[types.lsp.CompletionItemKind.Method] = 3
CompletionItemKind[types.lsp.CompletionItemKind.Function] = 4
CompletionItemKind[types.lsp.CompletionItemKind.Constructor] = 5
CompletionItemKind[types.lsp.CompletionItemKind.Field] = 6
CompletionItemKind[types.lsp.CompletionItemKind.Variable] = 7
CompletionItemKind[types.lsp.CompletionItemKind.Class] = 8
CompletionItemKind[types.lsp.CompletionItemKind.Interface] = 9
CompletionItemKind[types.lsp.CompletionItemKind.Module] = 10
CompletionItemKind[types.lsp.CompletionItemKind.Property] = 11
CompletionItemKind[types.lsp.CompletionItemKind.Unit] = 12
CompletionItemKind[types.lsp.CompletionItemKind.Value] = 13
CompletionItemKind[types.lsp.CompletionItemKind.Enum] = 14
CompletionItemKind[types.lsp.CompletionItemKind.Keyword] = 15
CompletionItemKind[types.lsp.CompletionItemKind.Snippet] = 16
CompletionItemKind[types.lsp.CompletionItemKind.Color] = 17
CompletionItemKind[types.lsp.CompletionItemKind.File] = 18
CompletionItemKind[types.lsp.CompletionItemKind.Reference] = 19
CompletionItemKind[types.lsp.CompletionItemKind.Folder] = 20
CompletionItemKind[types.lsp.CompletionItemKind.EnumMember] = 21
CompletionItemKind[types.lsp.CompletionItemKind.Struct] = 23
CompletionItemKind[types.lsp.CompletionItemKind.Event] = 24
CompletionItemKind[types.lsp.CompletionItemKind.Operator] = 24
CompletionItemKind[types.lsp.CompletionItemKind.TypeParameter] = 26

-- modified from nvim-cmp/lua/cmp/config/compare.lua
-- use the new "kind" ordering defined above
M.kind = function(entry1, entry2)
	local kind1 = CompletionItemKind[entry1:get_kind()]
	local kind2 = CompletionItemKind[entry2:get_kind()]
	kind1 = kind1 == CompletionItemKind.Text and 100 or kind1
	kind2 = kind2 == CompletionItemKind.Text and 100 or kind2
	if kind1 ~= kind2 then
		if kind1 == CompletionItemKind.Snippet then
			return true
		end
		if kind2 == CompletionItemKind.Snippet then
			return false
		end
		local diff = kind1 - kind2
		if diff < 0 then
			return true
		elseif diff > 0 then
			return false
		end
	end
	return nil
end

return M
