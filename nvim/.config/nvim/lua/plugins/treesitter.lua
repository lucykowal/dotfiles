return { -- highlight, edit, navigate
  "nvim-treesitter/nvim-treesitter",
  event = "VeryLazy",
  build = ":TSUpdate",
  main = "nvim-treesitter.configs", -- sets main module to use for opts
  -- see `:help nvim-treesitter`
  opts = {
    ensure_installed = {
      "bash",
      "c",
      "diff",
      "html",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "vim",
      "vimdoc",
      "java",
      "tmux",
    },
    auto_install = true,
    highlight = {
      enable = true,
      disable = { "tmux" },
      additional_vim_regex_highlighting = { "ruby" },
    },
    indent = { enable = false, disable = { "ruby" } },
  },
}
