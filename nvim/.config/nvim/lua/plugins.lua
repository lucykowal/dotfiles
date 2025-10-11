-- plugins.lua: plugin specs
local settings = require("settings")

-- for quicker
vim.keymap.set("n", "<leader>qd", function()
  vim.call("setqflist", vim.diagnostic.toqflist(vim.diagnostic.get(0)))
  require("quicker").open()
end, { desc = "[Q]uickfix [D]iagnostics" })

-- all plugins/*.lua get merged with this return spec
return {
  { -- detect tabstop and shiftwidth automatically
    -- *very* nice with https://editorconfig.org/
    "tpope/vim-sleuth",
    event = "VimEnter",
  },
  { -- lsp bootstrap
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
      enabled = function(root_dir)
        return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
      end,
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
        timeout_ms = 800,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        markdown = { "deno_fmt" },
        go = { "gofmt" },
        java = { "google-java-format", timeout_ms = 2000 },
        python = { "autopep8", "darker", "black", stop_after_first = true, timeout_ms = 2000 },
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
  { -- improved quickfix
    "stevearc/quicker.nvim",
    event = "FileType qf",
    config = function()
      require("quicker").setup({
        edit = {
          enabled = false,
        },
        constrain_cursor = true,
      })
      vim.keymap.set("n", "<leader>qf", function()
        require("quicker").toggle()
      end, { desc = "Toggle [Q]uick[F]ix" })
      vim.keymap.set("n", "<leader>qd", function()
        require("quicker").toggle({ loclist = true })
      end, { desc = "Toggle [Q]uickfix [D]iagnostics" })
    end,
  },
  { -- Status updates, notifications
    "j-hui/fidget.nvim",
    event = "UIEnter",
    opts = {
      progress = {
        suppress_on_insert = true,
        ignore_done_already = true,
        display = {
          render_limit = 8,
          done_ttl = 1,
        },
      },
      notification = {
        override_vim_notify = true,
        configs = {
          default = {
            icon_on_left = true,
          },
        },
        view = {
          stack_upwards = false,
        },
        window = {
          winblend = settings.window.winblend,
          border = settings.window.border,
          max_width = math.floor(settings.window.width() * 0.5),
          x_padding = 1,
          align = "top",
        },
      },
    },
  },
  { -- smart splits
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
}
