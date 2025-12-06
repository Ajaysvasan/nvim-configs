-- config/neotree.lua
require("neo-tree").setup({
  close_if_last_window = false,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  
  filesystem = {
    follow_current_file = {
      enabled = true,
    },
    use_libuv_file_watcher = true,
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
  
  window = {
    position = "left",
    width = 30,
    mapping_options = {
      noremap = true,
      nowait = true,
    },
  },
})

-- Smart toggle: toggle if closed, focus if open but not focused
vim.keymap.set("n", "<C-n>", function()
  local manager = require("neo-tree.sources.manager")
  local state = manager.get_state("filesystem")
  
  -- Check if neo-tree is visible
  local neo_tree_visible = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    if ft == "neo-tree" then
      neo_tree_visible = true
      -- Check if we're currently in neo-tree
      if vim.api.nvim_get_current_win() == win then
        -- Already in neo-tree, toggle it closed
        vim.cmd("Neotree close")
        return
      else
        -- Neo-tree is open but we're not in it, focus it
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end
  
  -- Neo-tree is not visible, open it
  vim.cmd("Neotree focus")
end, { noremap = true, silent = true, desc = "Toggle/Focus Neo-tree" })
