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
        local sep = {
          fg = colors.surface2,
          bg = colors.base,
          style = { "bold" },
        }
        return {
          NormalFloat = {
            bg = colors.base,
          },
          FloatBorder = sep,
          FloatTitle = sep,
          WinSeparator = sep,

          StatusLine = sep,
          StatusLineNC = sep,
          MiniStatuslineFilename = {
            bg = colors.base,
            fg = colors.surface2,
            style = { "bold" },
          }, -- active
          MiniStatuslineInactive = {
            fg = colors.surface2,
            bg = colors.base,
          }, -- inactive
          MiniStatuslineFileinfo = {
            fg = colors.surface2,
            bg = colors.base,
          }, -- common to both
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
