-- theme config
return {
  "sonph/onehalf",
  priority = 999,
  config = function(plugin)
    -- have to fix highlights for:
    -- cmp (or not? remove it?)
    -- mason
    -- fidget
    -- maybe native lsp
    -- mini (statusline)
    -- Best to fix at the source. I prefer using default highlight groups anyways.
    vim.opt.rtp:append(plugin.dir .. "/vim")
    vim.cmd.colorscheme("onehalflight")
  end,
}
