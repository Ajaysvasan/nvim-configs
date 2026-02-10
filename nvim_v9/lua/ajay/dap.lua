-- lua/ajay/dap.lua

local M = {}

function M.setup()
	local dap_ok, dap = pcall(require, "dap")
	if not dap_ok then
		vim.notify("nvim-dap not installed", vim.log.levels.ERROR)
		return
	end

	local dapui_ok, dapui = pcall(require, "dapui")
	if not dapui_ok then
		vim.notify("nvim-dap-ui not installed", vim.log.levels.ERROR)
		return
	end

	local mason_dap_ok, mason_dap = pcall(require, "mason-nvim-dap")
	if not mason_dap_ok then
		vim.notify("mason-nvim-dap not installed", vim.log.levels.ERROR)
		return
	end

	-- Setup Mason DAP
	mason_dap.setup({
		ensure_installed = {
			"python",
			"codelldb", -- C/C++/Rust
			"node2", -- JavaScript/TypeScript
			"java-debug-adapter",
		},
		automatic_installation = true,
		handlers = {},
	})

	-- Setup DAP UI
	dapui.setup({
		icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
		mappings = {
			expand = { "<CR>", "<2-LeftMouse>" },
			open = "o",
			remove = "d",
			edit = "e",
			repl = "r",
			toggle = "t",
		},
		layouts = {
			{
				elements = {
					{ id = "scopes", size = 0.25 },
					{ id = "breakpoints", size = 0.25 },
					{ id = "stacks", size = 0.25 },
					{ id = "watches", size = 0.25 },
				},
				size = 40,
				position = "left",
			},
			{
				elements = {
					{ id = "repl", size = 0.5 },
					{ id = "console", size = 0.5 },
				},
				size = 10,
				position = "bottom",
			},
		},
		floating = {
			max_height = nil,
			max_width = nil,
			border = "rounded",
			mappings = {
				close = { "q", "<Esc>" },
			},
		},
		windows = { indent = 1 },
	})

	-- Setup virtual text
	local virtual_text_ok, virtual_text = pcall(require, "nvim-dap-virtual-text")
	if virtual_text_ok then
		virtual_text.setup({
			enabled = true,
			enabled_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = false,
			show_stop_reason = true,
			commented = false,
			only_first_definition = true,
			all_references = false,
			filter_references_pattern = "<module",
			virt_text_pos = "eol",
			all_frames = false,
			virt_lines = false,
			virt_text_win_col = nil,
		})
	end

	-- Auto open/close UI
	dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated["dapui_config"] = function()
		dapui.close()
	end
	dap.listeners.before.event_exited["dapui_config"] = function()
		dapui.close()
	end

	-- Debugger signs
	vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DiagnosticError", linehl = "", numhl = "" })
	vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
	vim.fn.sign_define("DapBreakpointRejected", { text = "⭕", texthl = "DiagnosticError", linehl = "", numhl = "" })
	vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
	vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DiagnosticWarn", linehl = "Visual", numhl = "" })

	-- ============================================================
	-- LANGUAGE CONFIGURATIONS
	-- ============================================================

	-- Python debugger (debugpy)
	dap.adapters.python = {
		type = "executable",
		command = "python",
		args = { "-m", "debugpy.adapter" },
	}

	dap.configurations.python = {
		{
			type = "python",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			pythonPath = function()
				return "python"
			end,
		},
		{
			type = "python",
			request = "launch",
			name = "Launch file with arguments",
			program = "${file}",
			args = function()
				local args_string = vim.fn.input("Arguments: ")
				return vim.split(args_string, " +")
			end,
			pythonPath = function()
				return "python"
			end,
		},
	}

	-- C/C++ debugger (codelldb)
	dap.adapters.codelldb = {
		type = "server",
		port = "${port}",
		executable = {
			command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
			args = { "--port", "${port}" },
		},
	}

	dap.configurations.cpp = {
		{
			name = "Launch file",
			type = "codelldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
		},
	}

	dap.configurations.c = dap.configurations.cpp

	-- JavaScript/TypeScript debugger (node2)
	dap.adapters.node2 = {
		type = "executable",
		command = "node",
		args = { vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
	}

	dap.configurations.javascript = {
		{
			name = "Launch",
			type = "node2",
			request = "launch",
			program = "${file}",
			cwd = vim.fn.getcwd(),
			sourceMaps = true,
			protocol = "inspector",
			console = "integratedTerminal",
		},
		{
			name = "Attach to process",
			type = "node2",
			request = "attach",
			processId = require("dap.utils").pick_process,
		},
	}

	dap.configurations.typescript = dap.configurations.javascript

	-- ============================================================
	-- KEYMAPS
	-- ============================================================

	-- Start/Stop debugging
	vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
	vim.keymap.set("n", "<F6>", dap.terminate, { desc = "Debug: Stop" })
	vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
	vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "Debug: Stop" })

	-- Stepping
	vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
	vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
	vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
	vim.keymap.set("n", "<leader>dso", dap.step_over, { desc = "Debug: Step Over" })
	vim.keymap.set("n", "<leader>dsi", dap.step_into, { desc = "Debug: Step Into" })
	vim.keymap.set("n", "<leader>dsO", dap.step_out, { desc = "Debug: Step Out" })

	-- Breakpoints
	vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
	vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
	vim.keymap.set("n", "<leader>dB", function()
		dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
	end, { desc = "Debug: Set Conditional Breakpoint" })
	vim.keymap.set("n", "<leader>dl", function()
		dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
	end, { desc = "Debug: Set Log Point" })

	-- UI toggles
	vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
	vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: Toggle REPL" })
	vim.keymap.set("n", "<leader>dk", dapui.eval, { desc = "Debug: Evaluate Expression" })

	-- Run last
	vim.keymap.set("n", "<leader>dL", dap.run_last, { desc = "Debug: Run Last" })

	vim.notify("✓ Debugger (DAP) configured", vim.log.levels.INFO)
end

return M
