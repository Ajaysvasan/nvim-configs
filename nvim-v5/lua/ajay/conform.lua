-- lua/ajay/conform.lua

local M = {}

function M.setup()
	local conform_ok, conform = pcall(require, "conform")
	if not conform_ok then
		vim.notify("Conform not installed. Run :Lazy sync", vim.log.levels.WARN)
		return
	end

	conform.setup({
		-- Define formatters by filetype
		formatters_by_ft = {
			-- Lua
			lua = { "stylua" },

			-- Python
			python = { "isort", "black" },

			-- JavaScript/TypeScript (IMPORTANT!)
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },

			-- Web
			html = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },

			-- C/C++
			c = { "clang_format" },
			cpp = { "clang_format" },

			-- Java
			java = { "google-java-format" },

			-- Shell
			sh = { "shfmt" },
			bash = { "shfmt" },
		},

		-- Format on save
		format_on_save = function(bufnr)
			-- Disable with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end

			return {
				timeout_ms = 3000,
				lsp_fallback = true, -- Use LSP if no formatter found
			}
		end,

		-- Customize formatters
		formatters = {
			stylua = {
				prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
			},
			prettier = {
				prepend_args = {
					"--tab-width",
					"2",
					"--use-tabs",
					"false",
					"--single-quote",
					"false",
					"--trailing-comma",
					"es5",
					"--semi",
					"true",
				},
			},
			black = {
				prepend_args = { "--line-length", "88" },
			},
		},
	})

	-- Command to format current buffer
	vim.api.nvim_create_user_command("Format", function(args)
		local range = nil
		if args.count ~= -1 then
			local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
			range = {
				start = { args.line1, 0 },
				["end"] = { args.line2, end_line:len() },
			}
		end
		require("conform").format({ async = true, lsp_fallback = true, range = range })
	end, { range = true })

	-- Toggle format on save
	vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
		if vim.g.disable_autoformat then
			vim.g.disable_autoformat = false
			vim.notify("✓ Format on save: ENABLED", vim.log.levels.INFO)
		else
			vim.g.disable_autoformat = true
			vim.notify("✗ Format on save: DISABLED", vim.log.levels.WARN)
		end
	end, { desc = "Toggle format on save" })

	-- Toggle format on save for current buffer only
	vim.api.nvim_create_user_command("ToggleFormatOnSaveBuffer", function()
		if vim.b.disable_autoformat then
			vim.b.disable_autoformat = false
			vim.notify("✓ Format on save (buffer): ENABLED", vim.log.levels.INFO)
		else
			vim.b.disable_autoformat = true
			vim.notify("✗ Format on save (buffer): DISABLED", vim.log.levels.WARN)
		end
	end, { desc = "Toggle format on save for current buffer" })

	-- Show format status
	vim.api.nvim_create_user_command("FormatStatus", function()
		local global = not vim.g.disable_autoformat
		local buffer = not vim.b.disable_autoformat

		local status = string.format(
			"Format on save:\n  Global: %s\n  Buffer: %s",
			global and "ENABLED ✓" or "DISABLED ✗",
			buffer and "ENABLED ✓" or "DISABLED ✗"
		)
		vim.notify(status, vim.log.levels.INFO)
	end, { desc = "Show format on save status" })

	-- Keymaps
	vim.keymap.set({ "n", "v" }, "<leader>lf", function()
		require("conform").format({ async = true, lsp_fallback = true })
	end, { desc = "Format buffer or range" })

	vim.keymap.set("n", "<leader>tf", ":ToggleFormatOnSave<CR>", {
		desc = "Toggle format on save (global)",
		silent = true,
	})

	vim.keymap.set("n", "<leader>tF", ":ToggleFormatOnSaveBuffer<CR>", {
		desc = "Toggle format on save (buffer)",
		silent = true,
	})

	vim.keymap.set("n", "<leader>ts", ":FormatStatus<CR>", {
		desc = "Format status",
		silent = true,
	})

	vim.keymap.set("n", "<leader>ti", ":ConformInfo<CR>", {
		desc = "Conform info",
		silent = true,
	})
end

return M
