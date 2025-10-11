-- fuzzy finder
return {
  "junegunn/fzf",
  event = "VeryLazy",
  dependencies = { "junegunn/fzf.vim" },
  config = function()
    -- Keybindings for fzf
    vim.keymap.set("n", "<leader><leader>", ":Buffers<CR>", { desc = "Find Buffers" })
    vim.keymap.set("n", "<leader>sf", ":Files<CR>", { desc = "[S]earch [F]iles" })
    vim.keymap.set("n", "<leader>sh", ":Helptags<CR>", { desc = "[S]earch [H]elp tags" })
    vim.keymap.set("n", "<leader>sr", ":Rg<CR>", { desc = "[S]earch [R]ipgrep" })
    vim.keymap.set("n", "<leader>sc", ":Commands<CR>", { desc = "[S]earch [C]ommands" })
    vim.keymap.set("n", "<leader>sm", ":Marks<CR>", { desc = "[S]earch [M]arks" })
    vim.keymap.set("n", "<leader>sk", ":Keymaps<CR>", { desc = "[S]earch [K]eymaps" })
  end,
}
