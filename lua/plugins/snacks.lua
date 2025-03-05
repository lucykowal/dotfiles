return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = false },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = {
      indent = {
        enabled = true,
        only_scope = true,
        only_window = true,
      },
      animate = {
        enabled = false,
      },
      scope = {
        enabled = true,
        only_current = true,
      },
    },
    input = {
      enabled = true,
    },
    picker = { enabled = false },
    notifier = {
      enabled = false,
    },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
    styles = {
      input = {
        border = require("settings").window.border,
      },
    },
  },
}
