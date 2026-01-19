-- lua/ajay/treesitter.lua

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"c",
		"cpp",
		"python",
		"java",
		"javascript",
		"typescript", -- These include JSX/TSX support
		"html",
		"css",
		"json",
		"lua",
		"bash",
		"markdown",
		"markdown_inline",
		"vim",
		"vimdoc",
		"regex",
	},

	sync_install = false,
	auto_install = true,

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},

	indent = {
		enable = true,
	},

	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},

	-- Textobjects requires nvim-treesitter-textobjects plugin
	-- Uncomment after installing the plugin
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
	},
})
