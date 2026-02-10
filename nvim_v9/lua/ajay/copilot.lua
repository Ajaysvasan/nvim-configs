-- lua/ajay/copilot.lua

local M = {}

function M.setup()
  -- Check if copilot is available
  local copilot_ok, copilot = pcall(require, "copilot")
  if not copilot_ok then
    vim.notify("Copilot not installed", vim.log.levels.WARN)
    return
  end

  -- Setup GitHub Copilot
  copilot.setup({
    panel = {
      enabled = true,
      auto_refresh = true,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<CR>",
        refresh = "gr",
        open = "<M-CR>", -- Alt+Enter
      },
      layout = {
        position = "bottom", -- | top | left | right
        ratio = 0.4,
      },
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = "<M-l>", -- Alt+l (like Tab in VS Code)
        accept_word = false,
        accept_line = false,
        next = "<M-]>", -- Alt+]
        prev = "<M-[>", -- Alt+[
        dismiss = "<C-]>", -- Ctrl+]
      },
    },
    filetypes = {
      yaml = false,
      markdown = false,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false,
    },
    copilot_node_command = "node", -- Node.js version must be > 18.x
    server_opts_overrides = {},
  })

  -- Setup Copilot CMP source (for nvim-cmp integration)
  local cmp_copilot_ok, copilot_cmp = pcall(require, "copilot_cmp")
  if cmp_copilot_ok then
    copilot_cmp.setup()
  end

  -- Toggle Copilot commands
  vim.api.nvim_create_user_command("CopilotToggle", function()
    vim.cmd("Copilot toggle")
  end, { desc = "Toggle GitHub Copilot" })

  vim.api.nvim_create_user_command("CopilotStatus", function()
    vim.cmd("Copilot status")
  end, { desc = "Show Copilot status" })

  -- Keymaps
  vim.keymap.set("n", "<leader>ct", ":Copilot toggle<CR>", {
    desc = "Toggle Copilot",
    silent = true,
  })

  vim.keymap.set("n", "<leader>cs", ":Copilot status<CR>", {
    desc = "Copilot status",
    silent = true,
  })

  vim.keymap.set("n", "<leader>cp", ":Copilot panel<CR>", {
    desc = "Copilot panel",
    silent = true,
  })

  vim.notify("✓ GitHub Copilot configured", vim.log.levels.INFO)
end

return M
