-- lua/ajay/transparency.lua

local M = {}

function M.setup()
	-- Make background transparent
	vim.cmd([[
		highlight Normal guibg=NONE ctermbg=NONE
		highlight NormalNC guibg=NONE ctermbg=NONE
		highlight SignColumn guibg=NONE ctermbg=NONE
		highlight NormalFloat guibg=NONE ctermbg=NONE
		highlight FloatBorder guibg=NONE ctermbg=NONE
		highlight Pmenu guibg=NONE ctermbg=NONE
		highlight CursorLine guibg=NONE ctermbg=NONE
		highlight CursorLineNr guibg=NONE ctermbg=NONE
		highlight LineNr guibg=NONE ctermbg=NONE
		highlight Folded guibg=NONE ctermbg=NONE
		highlight NonText guibg=NONE ctermbg=NONE
		highlight SpecialKey guibg=NONE ctermbg=NONE
		highlight VertSplit guibg=NONE ctermbg=NONE
		highlight EndOfBuffer guibg=NONE ctermbg=NONE
		
		" Plugin specific
		highlight NeoTreeNormal guibg=NONE ctermbg=NONE
		highlight NeoTreeNormalNC guibg=NONE ctermbg=NONE
		highlight NeoTreeEndOfBuffer guibg=NONE ctermbg=NONE
		highlight TelescopeNormal guibg=NONE ctermbg=NONE
		highlight TelescopeBorder guibg=NONE ctermbg=NONE
		highlight WhichKeyFloat guibg=NONE ctermbg=NONE
	]])

	-- Toggle transparency function
	local transparency_enabled = true

	local function toggle_transparency()
		if transparency_enabled then
			-- Disable transparency (restore background)
			vim.cmd([[
				highlight Normal guibg=#1e1e1e ctermbg=234
				highlight NormalNC guibg=#1e1e1e ctermbg=234
				highlight SignColumn guibg=#1e1e1e ctermbg=234
				highlight NeoTreeNormal guibg=#1e1e1e ctermbg=234
			]])
			transparency_enabled = false
			vim.notify("Transparency: OFF", vim.log.levels.INFO)
		else
			-- Enable transparency
			M.setup()
			transparency_enabled = true
			vim.notify("Transparency: ON", vim.log.levels.INFO)
		end
	end

	-- Command to toggle
	vim.api.nvim_create_user_command("ToggleTransparency", toggle_transparency, {
		desc = "Toggle transparent background",
	})

	-- Keymap
	vim.keymap.set("n", "<leader>tt", toggle_transparency, {
		desc = "Toggle transparency",
		silent = true,
	})

	vim.notify("✓ Transparency enabled. Use <leader>tt to toggle", vim.log.levels.INFO)
end

return M
