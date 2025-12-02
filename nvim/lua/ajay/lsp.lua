-- config/lsp.lua
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_tool_installer = require("mason-tool-installer")

-- Configure diagnostics display
vim.diagnostic.config({
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
}

-- Tools to install
local ensure_tools = {
  "prettier",
  "eslint_d",
  "clang-format",
  "black",
  "isort",
  "stylua"
}

-- Setup Mason
mason.setup({
    ui = {
        border = "rounded",
    }
})

mason_lspconfig.setup({
  ensure_installed = ensure_servers,
  automatic_installation = true,
})

mason_tool_installer.setup({
  ensure_installed = ensure_tools,
  auto_update = true,
  run_on_start = true,
})

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
  buf_map({"n", "v"}, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
  buf_map("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, { desc = "Format buffer" })

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
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

-- Helper function to find root directory
local function root_pattern(...)
  local patterns = {...}
  return function(fname)
    local util = require('lspconfig.util')
    return util.root_pattern(unpack(patterns))(fname) or vim.fn.getcwd()
  end
end

-- === HTML ===
vim.lsp.config("html", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  capabilities = capabilities,
  on_attach = on_attach,
})

-- === CSS ===
vim.lsp.config("cssls", {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  capabilities = capabilities,
  on_attach = on_attach,
})

-- === clangd (C / C++) ===
vim.lsp.config("clangd", {
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
})

-- === pyright (Python) ===
vim.lsp.config("pyright", {
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
      }
    }
  }
})

-- === ts_ls (TypeScript / JavaScript) ===
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    on_attach(client, bufnr)
  end,
})

-- === eslint ===
vim.lsp.config("eslint", {
  cmd = { "vscode-eslint-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "package.json", ".git" },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
    on_attach(client, bufnr)
  end,
})

-- === jdtls (Java) ===
vim.lsp.config("jdtls", {
  cmd = { "jdtls" },
  filetypes = { "java" },
  root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".git" },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },
    }
  }
})

-- Enable LSP servers
vim.lsp.enable({
  "html",
  "cssls", 
  "clangd",
  "pyright",
  "ts_ls",
  "eslint",
  "jdtls"
})

-- Diagnostic signs
local signs = { 
  Error = "✘ ", 
  Warn = "▲ ", 
  Hint = "⚑ ", 
  Info = "» " 
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Auto-command to restart LSP on save (for debugging)
vim.api.nvim_create_user_command("LspRestart", function()
  vim.lsp.stop_client(vim.lsp.get_clients())
  vim.cmd("edit")
end, {})
