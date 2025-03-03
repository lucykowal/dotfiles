-- plugins.lua: plugin specs
local settings = require("settings")

-- all plugins/*.lua get merged with this return spec
return {
  { -- detect tabstop and shiftwidth automatically
    -- *very* nice with https://editorconfig.org/
    "tpope/vim-sleuth",
    event = "VimEnter",
  },
  { -- adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
    },
  },
  { -- lsp bootstrap
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },
  { -- autoformat
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      notify_on_error = true,
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        markdown = { "deno_fmt" },
        go = { "gofmt" },
        java = { "google-java-format" },
      },
    },
  },
  { -- for love2d
    "S1M0N38/love2d.nvim",
    cmd = "LoveRun",
    opts = {},
    config = function()
      vim.keymap.set("n", "<leader>vv", "<cmd>LoveRun<cr>", { ft = "lua", desc = "Run LOVE" })
      vim.keymap.set("n", "<leader>vs", "<cmd>LoveRun<cr>", { ft = "lua", desc = "Stop LOVE" })
    end,
  },
  { -- render markdown
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    ft = { "markdown", "copilot-chat" },
    opts = {
      preset = "lazy",
    },
  },
  { -- terminal float
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      open_mapping = [[<c-\>]],
      shade_terminals = false,
      direction = "float",
      float_opts = vim.tbl_extend("force", settings.window, {}),
      highlights = {
        NormalFloat = {
          link = "NormalFloat",
        },
        FloatBorder = {
          link = "FloatBorder",
        },
      },
    },
  },
}
