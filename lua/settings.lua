-- some common settings
return {
  ollama_host = vim.env.SERVER_ADDR,
  window = {
    border = "single",
    row = 1,
    height = math.floor(vim.o.lines * 0.75),
    width = math.floor(vim.o.columns * 0.8),
    title_pos = "center",
    winblend = 0,
  },
}
