local null_ls_ok, null_ls = pcall(require, "null-ls")
if not null_ls_ok then return end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local actions = null_ls.builtins.code_actions

null_ls.setup({
  debug = false,
  sources = {
    -- formatters
    formatting.prettier.with({ extra_args = { "--no-semi", "--single-quote" } }), -- JS/TS/JSON/HTML/CSS
    formatting.clang_format,   -- C/C++
    formatting.black.with({ extra_args = { "--fast" } }), -- python
    formatting.isort,          -- python imports
    formatting.stylua,         -- lua (if you use lua)
    -- diagnostics
    diagnostics.eslint_d,      -- fast eslint diagnostics
    diagnostics.ruff,          -- optional python linter if you prefer ruff (install via mason)
    -- code actions
    actions.eslint_d,
  },
  on_attach = function(client, bufnr)
    -- format on save via null-ls
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = "LspFormatting", buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})

