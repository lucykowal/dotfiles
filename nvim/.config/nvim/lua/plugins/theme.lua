-- theme config
return {
  -- "sonph/onehalf",
  "e-ink-colorscheme/e-ink.nvim",
  priority = 999,
  config = function(plugin)
    -- Best to fix at the source. I prefer using default highlight groups anyways.
    require("e-ink").setup()
    vim.opt.rtp:append(plugin.dir .. "/vim")

    vim.cmd.colorscheme("e-ink")
    vim.opt.background = "light"

    local palette = require("e-ink.palette").everforest()

    -- fixes most plugins
    vim.cmd.highlight("NormalFloat", "guibg=NONE")
    vim.cmd.highlight("StatusLine", "guibg=NONE")
    vim.cmd.highlight("StatusLineNC", "guibg=NONE")

    -- fix LSP diagnostics
    local mapping = {
      -- let g:terminal_color_0 = s:black.gui
      --
      -- let g:terminal_color_1 = s:red.gui
      -- let g:terminal_color_2 = s:green.gui
      -- let g:terminal_color_3 = s:yellow.gui
      -- let g:terminal_color_4 = s:blue.gui
      -- let g:terminal_color_5 = s:purple.gui
      -- let g:terminal_color_6 = s:cyan.gui
      -- let g:terminal_color_7 = s:white.gui
      -- let g:terminal_color_8 = s:black.gui
      -- let g:terminal_color_9 = s:red.gui
      -- let g:terminal_color_10 = s:green.gui
      -- let g:terminal_color_11 = s:yellow.gui
      -- let g:terminal_color_12 = s:blue.gui
      -- let g:terminal_color_13 = s:purple.gui
      -- let g:terminal_color_14 = s:cyan.gui
      -- let g:terminal_color_15 = s:white.gui
      Ok = palette.green,
      Hint = palette.aqua,
      Info = palette.blue,
      Warn = palette.yellow,
      Error = palette.red,
      Deprecated = palette.purple,
    }
    for k, v in pairs(mapping) do
      vim.cmd.highlight("Diagnostic" .. k, "guifg=" .. v)
      vim.cmd.highlight("DiagnosticUnderline" .. k, "guifg=" .. v)
    end

    -- italic comments
    vim.cmd.highlight("Comment", "gui=italic")

    -- transparent background
    local no_guibg = {
      "Normal",
      "LineNr",
      "GitGutterAdd",
      "GitGutterAdd",
      "GitGutterChange",
      "GitGutterDelete",
      "GitGutterChangeDelete",
      "GitSignsUntracked",
      "GitSignsUntrackedLn",
      "GitSignsUntrackedNr",
      "GitSignsUntrackedCul",
      "GitSignsStagedUntracked",
      "GitSignsStagedUntrackedLn",
      "GitSignsStagedUntrackedNr",
      "GitSignsStagedUntrackedCul",
      "GitSignsCurrentLineBlame",
    }
    for _, group in ipairs(no_guibg) do
      vim.cmd.highlight(group, "guibg=NONE ctermbg=NONE")
    end
  end,
}
