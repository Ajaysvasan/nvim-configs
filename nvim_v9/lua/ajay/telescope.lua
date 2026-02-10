-- lua/ajay/telescope.lua

local M = {}

function M.setup()
	local telescope = require("telescope")
	local actions = require("telescope.actions")
	local builtin = require("telescope.builtin")

	telescope.setup({
		defaults = {
			prompt_prefix = " 🔍 ",
			selection_caret = " ➤ ",
			path_display = { "truncate" },
			file_ignore_patterns = {
				"node_modules",
				".git/",
				"dist/",
				"build/",
				"target/",
				"*.class",
				"__pycache__",
				"*.pyc",
			},
			mappings = {
				i = {
					["<C-j>"] = actions.move_selection_next,
					["<C-k>"] = actions.move_selection_previous,
					["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
					["<C-x>"] = actions.delete_buffer,
					["<esc>"] = actions.close,
				},
				n = {
					["q"] = actions.close,
					["<C-x>"] = actions.delete_buffer,
				},
			},
		},
		pickers = {
			find_files = {
				theme = "dropdown",
				previewer = false,
				hidden = true,
			},
			buffers = {
				theme = "dropdown",
				previewer = false,
				initial_mode = "normal",
				mappings = {
					i = {
						["<C-d>"] = actions.delete_buffer,
					},
					n = {
						["dd"] = actions.delete_buffer,
					},
				},
			},
			git_branches = {
				theme = "dropdown",
				previewer = false,
			},
			lsp_references = {
				theme = "cursor",
				initial_mode = "normal",
			},
			lsp_definitions = {
				theme = "cursor",
				initial_mode = "normal",
			},
			lsp_document_symbols = {
				theme = "dropdown",
			},
			lsp_workspace_symbols = {
				theme = "dropdown",
			},
		},
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	})

	-- Load extensions
	pcall(telescope.load_extension, "fzf")

	-- ============================================================
	-- KEYMAPS
	-- ============================================================

	-- File Navigation
	vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
	vim.keymap.set("n", "<leader>fa", function()
		builtin.find_files({ hidden = true, no_ignore = true })
	end, { desc = "Find all files (including hidden)" })
	vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })

	-- Search Content
	vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
	vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find word under cursor" })
	vim.keymap.set("n", "<leader>fs", function()
		builtin.grep_string({ search = vim.fn.input("Grep > ") })
	end, { desc = "Search string" })

	-- Buffer Management
	vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
	vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Quick buffer switch" })

	-- LSP & Symbols
	vim.keymap.set("n", "<leader>fd", builtin.lsp_document_symbols, { desc = "Document symbols" })
	vim.keymap.set("n", "<leader>fD", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
	vim.keymap.set("n", "<leader>fi", builtin.lsp_implementations, { desc = "Implementations" })
	vim.keymap.set("n", "<leader>fR", builtin.lsp_references, { desc = "References" })

	-- Diagnostics
	vim.keymap.set("n", "<leader>fe", builtin.diagnostics, { desc = "Diagnostics (all)" })
	vim.keymap.set("n", "<leader>fE", function()
		builtin.diagnostics({ bufnr = 0 })
	end, { desc = "Diagnostics (current buffer)" })

	-- Git
	vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
	vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
	vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
	vim.keymap.set("n", "<leader>gS", builtin.git_stash, { desc = "Git stash" })

	-- TODOs & Comments
	vim.keymap.set("n", "<leader>ft", function()
		builtin.grep_string({
			search = "TODO|FIXME|NOTE|HACK|PERF|WARNING",
			use_regex = true,
		})
	end, { desc = "Find TODOs/FIXMEs" })

	-- Neovim Internals
	vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
	vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
	vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Commands" })
	vim.keymap.set("n", "<leader>fC", builtin.colorscheme, { desc = "Colorschemes" })
	vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "Marks" })
	vim.keymap.set("n", "<leader>fj", builtin.jumplist, { desc = "Jumplist" })
	vim.keymap.set("n", "<leader>fq", builtin.quickfix, { desc = "Quickfix" })
	vim.keymap.set("n", "<leader>fl", builtin.loclist, { desc = "Location list" })

	-- Search in current buffer
	vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in buffer" })

	-- Resume last picker
	vim.keymap.set("n", "<leader>fp", builtin.resume, { desc = "Resume last picker" })
end

return M
