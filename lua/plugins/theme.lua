-- theme config

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "latte",
      color_overrides = {
        latte = {},
      },
      custom_highlights = function(colors)
        return {
          NormalFloat = { bg = colors.base },
          FloatBorder = { fg = colors.text },
          FloatTitle = { fg = colors.text },
          TodoBgTODO = {
            bg = colors.blue,
            fg = colors.base,
            style = { "bold" },
          },
          TodoFgTODO = { fg = colors.blue },
        }
      end,
      styles = {
        comments = { "italic" },
      },
      integrations = {
        cmp = true,
        treesitter = true,
        mason = true,
        telescope = { enabled = true },
        mini = { enabled = true },
        which_key = true,
        gitsigns = true,
        render_markdown = true,
        fidget = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" },
          },
        },
      },
    })
    vim.cmd.colorscheme("catppuccin-latte")
  end,
}
