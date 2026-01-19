-- lua/ajay/jupyter.lua

local M = {}

function M.setup()
  -- Molten (Jupyter kernel) keymaps
  vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>", {
    desc = "Initialize Molten (Jupyter kernel)",
    silent = true,
  })

  vim.keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>", {
    desc = "Evaluate operator",
    silent = true,
  })

  vim.keymap.set("n", "<leader>ml", ":MoltenEvaluateLine<CR>", {
    desc = "Evaluate line",
    silent = true,
  })

  vim.keymap.set("n", "<leader>mr", ":MoltenReevaluateCell<CR>", {
    desc = "Re-evaluate cell",
    silent = true,
  })

  vim.keymap.set("v", "<leader>me", ":<C-u>MoltenEvaluateVisual<CR>gv", {
    desc = "Evaluate visual selection",
    silent = true,
  })

  vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>", {
    desc = "Delete Molten cell",
    silent = true,
  })

  vim.keymap.set("n", "<leader>mo", ":MoltenShowOutput<CR>", {
    desc = "Show output",
    silent = true,
  })

  vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>", {
    desc = "Hide output",
    silent = true,
  })

  vim.keymap.set("n", "<leader>mq", ":MoltenInterrupt<CR>", {
    desc = "Interrupt kernel",
    silent = true,
  })

  -- Run cell and move to next (like Jupyter)
  vim.keymap.set("n", "<leader>mn", function()
    vim.cmd("MoltenEvaluateLine")
    vim.cmd("normal! j")
  end, {
    desc = "Run cell and move to next",
    silent = true,
  })

  -- Run all cells above
  vim.keymap.set("n", "<leader>ma", ":MoltenEvaluateAll<CR>", {
    desc = "Evaluate all cells",
    silent = true,
  })

  -- Auto-initialize Molten for Python files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python", "markdown" },
    callback = function()
      -- Show helpful message
      vim.notify("Jupyter notebook features available! Use <leader>mi to initialize kernel", vim.log.levels.INFO)
    end,
  })

  vim.notify("✓ Jupyter notebook support configured", vim.log.levels.INFO)
end

return M
