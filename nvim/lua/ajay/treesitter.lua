require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "c", "cpp", "python", "java",
    "javascript", "typescript", "tsx", "jsx",
    "html", "css", "json", "lua"
  },
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = true },  -- smart indentation using treesitter
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
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
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 2000,
  },
})

