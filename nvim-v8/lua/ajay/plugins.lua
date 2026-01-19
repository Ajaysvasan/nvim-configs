-- config/plugins.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- THEMES
	{ "ellisonleao/gruvbox.nvim", priority = 1000 },

	{
		"GCBallesteros/jupytext.nvim",
		config = function()
			require("jupytext").setup({
				style = "markdown",
				output_extension = "md",
				force_ft = "markdown",
				custom_language_formatting = {},
			})
		end,
	},
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		build = ":UpdateRemotePlugins",
		enabled = true,
		init = function()
			vim.g.molten_image_provider = "none"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = false
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_output = true
		end,
		config = function()
			require("ajay.jupyter").setup()
		end,
	},
	-- DASHBOARD / STARTUP SCREEN
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("ajay.dashboard").setup()
		end,
	},

	-- IMAGE SUPPORT (Optional - for displaying actual images)
	{
		"3rd/image.nvim",
		enabled = false, -- Set to true if you want to use real images
		dependencies = {
			"leafo/magick",
		},
		config = function()
			require("image").setup({
				backend = "kitty",
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = true,
						only_render_image_at_cursor = false,
					},
				},
				max_width = nil,
				max_height = nil,
				max_width_window_percentage = nil,
				max_height_window_percentage = 50,
				kitty_method = "normal",
			})
		end,
	},

	-- AUTOPAIRS
	{ "windwp/nvim-autopairs", config = true },

	-- FILE TREE
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
	},

	-- LSP & MASON
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
	},

	-- COMPLETION
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
	},

	-- EMMET for HTML/JSX/TSX
	{
		"olrtg/nvim-emmet",
		config = function()
			vim.keymap.set({ "n", "v" }, "<leader>xe", require("nvim-emmet").wrap_with_abbreviation)
		end,
	},

	-- INDENT GUIDES
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	-- RAINBOW DELIMITERS
	{
		"HiPhish/rainbow-delimiters.nvim",
	},

	-- STATUSLINE
	{ "nvim-lualine/lualine.nvim", config = true },

	-- TREESITTER
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

	-- TELESCOPE
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			require("ajay.telescope").setup()
		end,
	},

	-- GIT
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("ajay.gitsigns").setup()
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("ajay.lazygit").setup()
		end,
	},

	-- QUALITY OF LIFE
	{
		"numToStr/Comment.nvim",
		config = function()
			require("ajay.comment").setup()
		end,
	},

	-- AI COPILOT (GitHub Copilot)
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("ajay.copilot").setup()
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		dependencies = { "zbirenbaum/copilot.lua" },
		config = function()
			require("copilot_cmp").setup()
		end,
	},

	-- FORMATTING (Better than built-in)
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		config = function()
			require("ajay.conform").setup()
		end,
	},

	-- DEBUGGER (DAP)
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
			"jay-babu/mason-nvim-dap.nvim",
		},
		config = function()
			require("ajay.dap").setup()
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = { "mfussenegger/nvim-dap" },
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
	},

	-- HARPOON
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup({
				settings = {
					save_on_toggle = false,
					sync_on_ui_close = true,
					key = function()
						return vim.loop.cwd()
					end,
				},
			})

			vim.keymap.set("n", "<leader>a", function()
				local current_file = vim.fn.expand("%:p")
				if current_file == "" then
					vim.notify("No file to add", vim.log.levels.WARN)
					return
				end
				harpoon:list():append()
				vim.notify("Added to Harpoon: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
			end, { desc = "Harpoon Add File" })

			vim.keymap.set("n", "<leader>dr", function()
				harpoon:list():remove()
				vim.notify("Removed from Harpoon", vim.log.levels.INFO)
			end, { desc = "Harpoon Remove File" })

			vim.keymap.set("n", "<leader>dc", function()
				harpoon:list():clear()
				vim.notify("Cleared Harpoon list", vim.log.levels.INFO)
			end, { desc = "Harpoon Clear All" })

			vim.keymap.set("n", "<leader>hh", function()
				local conf = require("telescope.config").values
				local file_paths = {}
				for _, item in ipairs(harpoon:list().items) do
					table.insert(file_paths, item.value)
				end

				require("telescope.pickers")
					.new({}, {
						prompt_title = "Harpoon",
						finder = require("telescope.finders").new_table({
							results = file_paths,
						}),
						previewer = conf.file_previewer({}),
						sorter = conf.generic_sorter({}),
					})
					:find()
			end, { desc = "Harpoon Telescope" })

			vim.keymap.set("n", "<leader>he", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon Quick Menu" })

			vim.keymap.set("n", "<leader>hn", function()
				harpoon:list():next()
			end, { desc = "Harpoon Next" })

			vim.keymap.set("n", "<leader>hp", function()
				harpoon:list():prev()
			end, { desc = "Harpoon Prev" })

			vim.keymap.set("n", "<A-1>", function()
				harpoon:list():select(1)
			end, { desc = "Harpoon Select 1" })

			vim.keymap.set("n", "<A-2>", function()
				harpoon:list():select(2)
			end, { desc = "Harpoon Select 2" })

			vim.keymap.set("n", "<A-3>", function()
				harpoon:list():select(3)
			end, { desc = "Harpoon Select 3" })

			vim.keymap.set("n", "<A-4>", function()
				harpoon:list():select(4)
			end, { desc = "Harpoon Select 4" })

			vim.keymap.set("n", "<A-5>", function()
				harpoon:list():select(5)
			end, { desc = "Harpoon Select 5" })
		end,
	},
})
