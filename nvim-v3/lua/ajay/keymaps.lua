local map = vim.keymap.set

-- easier window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- save & quit
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")

-- clear search
map("n", "<leader>h", ":nohlsearch<CR>")

-- fast moving
map("n", "H", "^")
map("n", "L", "$")
-- Compile/run for C++ (g++)
vim.keymap.set("n", "<leader>r", function()
	local file = vim.fn.expand("%")
	vim.cmd("split | terminal g++ -std=c++17 " .. file .. " -o out && ./out")
end)

-- Run Python
vim.keymap.set("n", "<leader>p", function()
	local file = vim.fn.expand("%")
	vim.cmd("split | terminal python3 " .. file)
end)

-- Run Java
vim.keymap.set("n", "<leader>j", function()
	local file = vim.fn.expand("%")
	vim.cmd("split | terminal javac " .. file .. " && java " .. vim.fn.expand("%:r"))
end)
-- CMake build (Release mode)
vim.keymap.set("n", "<leader>cb", function()
	vim.cmd("split | terminal mkdir -p build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make")
end)
vim.keymap.set("n", "<leader>cr", function()
	vim.cmd("split | terminal ./build/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"))
end)

-- Format current buffer (explicit)
vim.keymap.set("n", "<leader>F", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "LSP Format" })

-- Diagnostics list
vim.keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", { desc = "Diagnostics" })

-- Quick fix / code actions
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

-- go to next diagnostic (error)
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next)

-- go to previous diagnostic
vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev)

-- open floating diagnostic window (like VSCode hover)
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float)
-- search files
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>")

-- search text in project
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")

-- search symbols in current buffer
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>")

-- search symbols across workspace (like VSCode)
vim.keymap.set("n", "<leader>fw", "<cmd>Telescope lsp_workspace_symbols<CR>")
vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", { silent = true })

-- config/keymaps.lua
-- General keymaps
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>x", ":wq<CR>", { desc = "Save and quit" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Remove conflicting <leader>f keymap if it exists
-- DO NOT map <leader>f alone - let it wait for second key
-- vim.keymap.set("n", "<leader>f", ...) -- REMOVE THIS IF EXISTS

-- Resize windows
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Resize up" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Resize down" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Resize left" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Resize right" })

-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Move text up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Clear search highlight
vim.keymap.set("n", "<Esc>", ":noh<CR>", { silent = true, desc = "Clear search" })
