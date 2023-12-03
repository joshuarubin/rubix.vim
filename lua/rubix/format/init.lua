local M = {}

local function apply_action(action, client, wait_ms, ctx)
	if action.edit then
		vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
	end
	if action.command then
		local command = type(action.command) == "table" and action.command or action
		local fn = client.commands[command.command] or vim.lsp.commands[command.command]
		if fn then
			local enriched_ctx = vim.deepcopy(ctx)
			enriched_ctx.client_id = client.id
			fn(command, enriched_ctx)
		else
			-- Not using command directly to exclude extra properties,
			-- see https://github.com/python-lsp/python-lsp-server/issues/146
			local params = {
				command = command.command,
				arguments = command.arguments,
				workDoneToken = command.workDoneToken,
			}
			if ctx.sync then
				client.request_sync("workspace/executeCommand", params, wait_ms, ctx.bufnr)
			else
				client.request("workspace/executeCommand", params, nil, ctx.bufnr)
			end
		end
	end
end

local function resolve_and_apply_action(client_id, action, wait_ms, ctx)
	local client = vim.lsp.get_client_by_id(client_id)
	if
		not action.edit
		and client
		and type(client.resolved_capabilities.code_action) == "table"
		and client.resolved_capabilities.code_action.resolveProvider
	then
		local function handle_resolved_action(err, resolved_action)
			if err then
				vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR)
				return
			end
			apply_action(resolved_action, client, wait_ms, ctx)
		end

		if ctx.sync then
			local resolved_action, err = client.request_sync("codeAction/resolve", action, wait_ms, ctx.bufnr)
			handle_resolved_action(err, resolved_action)
		else
			client.request("codeAction/resolve", action, handle_resolved_action)
		end
	else
		apply_action(action, client, wait_ms, ctx)
	end
end

local function lsp_supports_method(ctx)
	for _, client in pairs(vim.lsp.buf_get_clients(ctx.bufnr or 0)) do
		if client.supports_method(ctx.method) then
			return true
		end
	end
	return false
end

local function organize_imports(bufnr, wait_ms)
	local ctx = {
		method = "textDocument/codeAction",
		bufnr = bufnr,
		params = vim.lsp.util.make_range_params(),
	}

	ctx.params.context = {
		only = { "source.organizeImports" },
		diagnostics = vim.lsp.diagnostic.get_line_diagnostics(ctx.bufnr),
	}

	if not lsp_supports_method(ctx) then
		return
	end

	vim.o.undolevels = math.floor(vim.o.undolevels) -- this, strangely, starts a new undo block for the next change

	ctx.sync = true

	local results = vim.lsp.buf_request_sync(ctx.bufnr, ctx.method, ctx.params, wait_ms)
	for client_id, result in pairs(results or {}) do
		for _, action in pairs(result.result or {}) do
			if action.kind == "source.organizeImports" then
				resolve_and_apply_action(client_id, action, wait_ms, ctx)
			end
		end
	end
end

local function lsp_format(opts)
	opts = opts or { buf = 0 }
	opts.buf = opts.buf or 0

	if vim.b[opts.buf].autoformat ~= 1 then
		return
	end

	organize_imports(opts.buf, 5000)

	vim.o.undolevels = math.floor(vim.o.undolevels) -- this, strangely, starts a new undo block for the next change

	vim.lsp.buf.format({
		timeout_ms = 5000,
		bufnr = opts.buf,
	})
end

local lsp_formatting_group = vim.api.nvim_create_augroup("LspFormatting", {})

M.on_attach = function(client, bufnr)
	if vim.b[bufnr].autoformat == nil then
		vim.b[bufnr].autoformat = 1
	end

	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({
			group = lsp_formatting_group,
			buffer = bufnr,
		})

		vim.api.nvim_create_autocmd("BufWritePre", {
			group = lsp_formatting_group,
			buffer = bufnr,
			callback = lsp_format,
		})
	end
end

M.setup = function()
	vim.api.nvim_create_user_command("ToggleAutoFormat", function()
		if vim.b.autoformat ~= 1 then
			vim.b.autoformat = 1
		else
			vim.b.autoformat = nil
		end
	end, {})

	vim.api.nvim_create_user_command("Format", lsp_format, {})
	vim.api.nvim_create_user_command("OrganizeImports", function()
		organize_imports(0, 5000)
	end, {})
end

return M
