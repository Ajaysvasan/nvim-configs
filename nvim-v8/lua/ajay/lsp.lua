-- lua/ajay/lsp.lua

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

-- Try to load mason-tool-installer (optional)
local mason_tool_installer_ok, mason_tool_installer = pcall(require, "mason-tool-installer")

-- Configure diagnostics display with new API
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "✘",
			[vim.diagnostic.severity.WARN] = "▲",
			[vim.diagnostic.severity.HINT] = "⚑",
			[vim.diagnostic.severity.INFO] = "»",
		},
	},
	virtual_text = {
		severity = vim.diagnostic.severity.ERROR,
		spacing = 2,
	},
	float = {
		border = "rounded",
		source = "always",
	},
	severity_sort = true,
	update_in_insert = false,
})

-- Servers to install
local ensure_servers = {
	"pyright",
	"clangd",
	"jdtls",
	"ts_ls",
	"eslint",
	"html",
	"cssls",
	"lua_ls",
	"tailwindcss",
}

-- Tools to install
local ensure_tools = {
	"prettier",
	"eslint_d",
	"clang-format",
	"black",
	"isort",
	"stylua",
}

-- Setup Mason
mason.setup({
	ui = {
		border = "rounded",
	},
})

mason_lspconfig.setup({
	ensure_installed = ensure_servers,
	automatic_installation = true,
})

-- Setup mason-tool-installer only if available
if mason_tool_installer_ok then
	mason_tool_installer.setup({
		ensure_installed = ensure_tools,
		auto_update = true,
		run_on_start = true,
	})
end

-- Get capabilities for LSP
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_nvim_lsp_ok then
	capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- Enhanced on_attach with better keymaps
local on_attach = function(client, bufnr)
	local buf_map = function(mode, lhs, rhs, opts)
		opts = vim.tbl_extend("force", { noremap = true, silent = true, buffer = bufnr }, opts or {})
		vim.keymap.set(mode, lhs, rhs, opts)
	end

	-- Navigation
	buf_map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
	buf_map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
	buf_map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
	buf_map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
	buf_map("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

	-- Hover and help
	buf_map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
	buf_map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

	-- Code actions
	buf_map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
	buf_map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
	buf_map("n", "<leader>lf", function()
		vim.lsp.buf.format({ async = true })
	end, { desc = "Format buffer" })

	-- Diagnostics
	buf_map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
	buf_map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
	buf_map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
	buf_map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic list" })

	-- Workspace
	buf_map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
	buf_map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
	buf_map("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, { desc = "List workspace folders" })

	-- Enable inlay hints if supported
	if client.supports_method("textDocument/inlayHint") and vim.lsp.inlay_hint then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end
end

-- Setup LSP servers using new vim.lsp.config API
local function setup_servers()
	-- HTML
	vim.lsp.config.html = {
		cmd = { "vscode-html-language-server", "--stdio" },
		filetypes = { "html" },
		root_markers = { ".git" },
		capabilities = capabilities,
		on_attach = on_attach,
	}

	-- CSS
	vim.lsp.config.cssls = {
		cmd = { "vscode-css-language-server", "--stdio" },
		filetypes = { "css", "scss", "less" },
		root_markers = { ".git" },
		capabilities = capabilities,
		on_attach = on_attach,
	}

	-- Clangd (C/C++)
	vim.lsp.config.clangd = {
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--completion-style=detailed",
			"--header-insertion=iwyu",
		},
		filetypes = { "c", "cpp", "objc", "objcpp" },
		root_markers = { "compile_commands.json", "compile_flags.txt", "CMakeLists.txt", ".git" },
		capabilities = capabilities,
		on_attach = on_attach,
	}

	-- Pyright (Python)
	vim.lsp.config.pyright = {
		cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", ".git" },
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "basic",
					useLibraryCodeForTypes = true,
					autoSearchPaths = true,
					diagnosticMode = "workspace",
				},
			},
		},
	}

	-- Lua LS
	vim.lsp.config.lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".git", ".luarc.json", ".luacheckrc" },
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				telemetry = { enable = false },
			},
		},
	}

	-- TypeScript/JavaScript
	vim.lsp.config.ts_ls = {
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			-- Disable tsserver formatting (prefer prettier/eslint)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
			on_attach(client, bufnr)
		end,
	}

	-- ESLint
	vim.lsp.config.eslint = {
		cmd = { "vscode-eslint-language-server", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "package.json", ".git" },
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			-- ESLint can format
			client.server_capabilities.documentFormattingProvider = true

			-- Auto-fix on save
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = bufnr,
				callback = function()
					local ok = pcall(vim.cmd, "EslintFixAll")
					if not ok then
						-- Silently ignore if EslintFixAll is not available
					end
				end,
			})
			on_attach(client, bufnr)
		end,
	}

	-- Tailwind CSS
	vim.lsp.config.tailwindcss = {
		cmd = { "tailwindcss-language-server", "--stdio" },
		filetypes = {
			"html",
			"css",
			"scss",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
		},
		root_markers = {
			"tailwind.config.js",
			"tailwind.config.ts",
			"tailwind.config.cjs",
			"postcss.config.js",
			".git",
		},
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			tailwindCSS = {
				classAttributes = { "class", "className", "classList", "ngClass" },
				lint = {
					cssConflict = "warning",
					invalidApply = "error",
					invalidConfigPath = "error",
					invalidScreen = "error",
					invalidTailwindDirective = "error",
					invalidVariant = "error",
					recommendedVariantOrder = "warning",
				},
				validate = true,
			},
		},
	}

	-- Java (JDTLS) - Special setup required
	-- Note: JDTLS is complex and needs per-project configuration
	-- This is a basic setup that works for simple Java projects
	local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
	local jdtls_bin = jdtls_path .. "/bin/jdtls"

	-- Only setup if jdtls is installed
	if vim.fn.executable(jdtls_bin) == 1 then
		vim.lsp.config.jdtls = {
			cmd = { jdtls_bin },
			filetypes = { "java" },
			root_markers = { 
				"pom.xml", 
				"build.gradle", 
				"build.gradle.kts",
				".git",
				"mvnw",
				"gradlew",
			},
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				java = {
					signatureHelp = { enabled = true },
					contentProvider = { preferred = "fernflower" },
					completion = {
						favoriteStaticMembers = {
							"org.junit.Assert.*",
							"org.junit.Assume.*",
							"org.junit.jupiter.api.Assertions.*",
							"org.junit.jupiter.api.Assumptions.*",
							"org.junit.jupiter.api.DynamicContainer.*",
							"org.junit.jupiter.api.DynamicTest.*",
						},
					},
					sources = {
						organizeImports = {
							starThreshold = 9999,
							staticStarThreshold = 9999,
						},
					},
					codeGeneration = {
						toString = {
							template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
						},
						useBlocks = true,
					},
					configuration = {
						runtimes = {
							-- Add Java runtimes here if needed
							-- {
							--   name = "JavaSE-11",
							--   path = "/usr/lib/jvm/java-11-openjdk",
							-- },
						},
					},
				},
			},
		}
	end
end

-- Setup all servers
setup_servers()

-- Enable all LSP servers (remove jdtls if not installed)
local servers_to_enable = {
	"html",
	"cssls",
	"clangd",
	"pyright",
	"lua_ls",
	"ts_ls",
	"eslint",
	"tailwindcss",
}

-- Only enable jdtls if it's installed
local jdtls_bin = vim.fn.stdpath("data") .. "/mason/packages/jdtls/bin/jdtls"
if vim.fn.executable(jdtls_bin) == 1 then
	table.insert(servers_to_enable, "jdtls")
end

vim.lsp.enable(servers_to_enable)

-- Auto-command to restart LSP
vim.api.nvim_create_user_command("LspRestart", function()
	local clients = vim.lsp.get_clients()
	for _, client in ipairs(clients) do
		vim.lsp.stop_client(client.id)
	end
	vim.defer_fn(function()
		vim.cmd("edit")
	end, 100)
end, { desc = "Restart LSP servers" })
