--- Snack.nvim configuration
local function snack_options()
  return {
    bigfile = { enabled = false },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    git = { enabled = false },
    indent = { enabled = false },
    input = {
      enabled = true,
    },
    picker = { enabled = false },
    notifier = {
      enabled = true,
      margin = { top = 0, right = 0, bottom = 0 },
      icons = {
        error = "",
        warn = "",
        info = "",
        debug = "",
        trace = "",
      },
      padding = false,
      height = { min = 1, max = 0.3 },
    },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
    styles = {
      input = {
        row = require("settings").window.row,
        border = require("settings").window.border,
        b = {
          completion = true,
        },
      },
      notification = {
        border = require("settings").window.border,
      },
    },
  }
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = snack_options(),
}
