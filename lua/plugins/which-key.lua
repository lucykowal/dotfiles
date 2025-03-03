-- shows key bindings in a popup window
return {
  "folke/which-key.nvim",
  event = "UIEnter",
  opts = {
    preset = "classic",
    filter = function(mapping)
      return mapping.desc and mapping.desc ~= ""
    end,

    spec = {
      { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
      { "<leader>d", group = "[D]ocument" },
      { "<leader>r", group = "[R]ename" },
      { "<leader>s", group = "[S]earch" },
      { "<leader>w", group = "[W]orkspace" },
      { "<leader>t", group = "[T]oggle" },
      { "<leader>v", group = "Love2D" },
    },
    win = { -- see `:help api-win_config`
      no_overlap = false,
      height = 10,
      row = vim.o.lines - 10,
      width = vim.o.columns,
      padding = { 0, 0 },
      -- clockwise from top left
      border = { "─", "─", "─", "", "", "", "", "" },
    },
    layout = {
      width = { min = 14, max = 40 },
      spacing = 2,
    },
    expand = 1,
    icons = {
      mappings = vim.g.have_nerd_font,
      keys = vim.g.have_nerd_font and {},
    },
    show_help = false,
  },
}
