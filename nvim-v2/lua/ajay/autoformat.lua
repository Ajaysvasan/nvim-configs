-- lua/ajay/autoformat.lua

-- Create autoformat group
local augroup = vim.api.nvim_create_augroup("AutoFormat", { clear = true })

-- Format on save for all filetypes that have LSP attached
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = "*",
  callback = function()
    -- Get LSP clients attached to current buffer
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    
    -- Check if any client supports formatting
    local has_formatter = false
    for _, client in ipairs(clients) do
      if client.server_capabilities.documentFormattingProvider then
        has_formatter = true
        break
      end
    end
    
    -- Format if formatter is available
    if has_formatter then
      vim.lsp.buf.format({
        async = false,
        timeout_ms = 2000,
      })
    end
  end,
})

-- Toggle format on save with a command
local format_on_save = true

vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
  format_on_save = not format_on_save
  if format_on_save then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      pattern = "*",
      callback = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local has_formatter = false
        for _, client in ipairs(clients) do
          if client.server_capabilities.documentFormattingProvider then
            has_formatter = true
            break
          end
        end
        if has_formatter then
          vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
        end
      end,
    })
    vim.notify("Format on save: ENABLED", vim.log.levels.INFO)
  else
    vim.api.nvim_clear_autocmds({ group = augroup })
    vim.notify("Format on save: DISABLED", vim.log.levels.WARN)
  end
end, { desc = "Toggle format on save" })

-- Show status
vim.keymap.set("n", "<leader>tf", ":ToggleFormatOnSave<CR>", { 
  desc = "Toggle format on save",
  silent = true 
})
