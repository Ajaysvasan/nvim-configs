-- lua/ajay/lazygit.lua

local M = {}

function M.setup()
  -- LazyGit keymaps
  vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>", { 
    desc = "Open LazyGit", 
    silent = true, 
    noremap = true 
  })
  
  vim.keymap.set("n", "<leader>gc", ":LazyGitConfig<CR>", { 
    desc = "LazyGit Config", 
    silent = true, 
    noremap = true 
  })
  
  vim.keymap.set("n", "<leader>gf", ":LazyGitCurrentFile<CR>", { 
    desc = "LazyGit Current File", 
    silent = true, 
    noremap = true 
  })
  
  vim.keymap.set("n", "<leader>gl", ":LazyGitFilter<CR>", { 
    desc = "LazyGit Filter", 
    silent = true, 
    noremap = true 
  })
  
  vim.keymap.set("n", "<leader>gL", ":LazyGitFilterCurrentFile<CR>", { 
    desc = "LazyGit Filter Current File", 
    silent = true, 
    noremap = true 
  })

  -- Configure LazyGit to use a floating window
  vim.g.lazygit_floating_window_winblend = 0
  vim.g.lazygit_floating_window_scaling_factor = 0.9
  vim.g.lazygit_floating_window_border_chars = {'╭','─', '╮', '│', '╯','─', '╰', '│'}
  vim.g.lazygit_floating_window_use_plenary = 0
  vim.g.lazygit_use_neovim_remote = 1
  vim.g.lazygit_use_custom_config_file_path = 0
end

return M
