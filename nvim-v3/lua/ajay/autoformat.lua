-- lua/ajay/autoformat.lua

-- Enable format on save by default
local format_on_save_enabled = true

-- Format on save function
local function format_on_save()
	if not format_on_save_enabled then
		return
	end

	-- Get all LSP clients for current buffer
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	if #clients == 0 then
		return
	end

	-- Check if any client supports formatting
	local can_format = false
	for _, client in ipairs(clients) do
		if client.server_capabilities.documentFormattingProvider then
			can_format = true
			break
		end
	end

	-- Format if available
	if can_format then
		vim.lsp.buf.format({
			bufnr = bufnr,
			async = false,
			timeout_ms = 2000,
		})
	end
end

-- Create autoformat group
local augroup = vim.api.nvim_create_augroup("AutoFormat", { clear = true })

-- Setup format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = "*",
	callback = format_on_save,
})

-- Toggle format on save command
vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
	format_on_save_enabled = not format_on_save_enabled
	if format_on_save_enabled then
		vim.notify("✓ Format on save: ENABLED", vim.log.levels.INFO)
	else
		vim.notify("✗ Format on save: DISABLED", vim.log.levels.WARN)
	end
end, { desc = "Toggle format on save" })

-- Show current status command
vim.api.nvim_create_user_command("FormatOnSaveStatus", function()
	local status = format_on_save_enabled and "ENABLED ✓" or "DISABLED ✗"
	vim.notify("Format on save: " .. status, vim.log.levels.INFO)
end, { desc = "Show format on save status" })

-- Keymap to toggle
vim.keymap.set("n", "<leader>tf", ":ToggleFormatOnSave<CR>", {
	desc = "Toggle format on save",
	silent = true,
	noremap = true,
})

-- Keymap to check status
vim.keymap.set("n", "<leader>ts", ":FormatOnSaveStatus<CR>", {
	desc = "Format on save status",
	silent = true,
	noremap = true,
})

