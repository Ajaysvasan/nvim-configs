-- lua/ajay/comment.lua

local M = {}

function M.setup()
  local comment_ok, comment = pcall(require, "Comment")
  if not comment_ok then
    return
  end

  comment.setup({
    -- Add a space between comment and the line
    padding = true,
    -- Should comment out empty or whitespace only lines
    sticky = true,
    -- Ignore empty lines
    ignore = '^$',
    -- LHS of toggle mappings in NORMAL mode
    toggler = {
      line = '<C-_>',  -- This is Ctrl+/ (terminal sees it as Ctrl+_)
      block = '<C-S-_>', -- Ctrl+Shift+/
    },
    -- LHS of operator-pending mappings in NORMAL and VISUAL mode
    opleader = {
      line = '<C-_>',
      block = '<C-S-_>',
    },
    -- LHS of extra mappings
    extra = {
      above = 'gcO', -- Add comment on the line above
      below = 'gco', -- Add comment on the line below
      eol = 'gcA',   -- Add comment at the end of line
    },
    -- Enable keybindings
    mappings = {
      basic = true,
      extra = true,
    },
  })

  -- VS Code style keymaps for Ctrl+/
  -- Normal mode: toggle current line
  vim.keymap.set('n', '<C-/>', '<Plug>(comment_toggle_linewise_current)', { desc = "Toggle comment" })
  
  -- Visual mode: toggle selected lines
  vim.keymap.set('v', '<C-/>', '<Plug>(comment_toggle_linewise_visual)', { desc = "Toggle comment" })
  
  -- Alternative keymaps in case terminal doesn't recognize Ctrl+/
  vim.keymap.set('n', '<C-_>', '<Plug>(comment_toggle_linewise_current)', { desc = "Toggle comment" })
  vim.keymap.set('v', '<C-_>', '<Plug>(comment_toggle_linewise_visual)', { desc = "Toggle comment" })
  
  -- Block comment with Ctrl+Shift+/
  vim.keymap.set('n', '<C-S-/>', '<Plug>(comment_toggle_blockwise_current)', { desc = "Toggle block comment" })
  vim.keymap.set('v', '<C-S-/>', '<Plug>(comment_toggle_blockwise_visual)', { desc = "Toggle block comment" })
end

return M
