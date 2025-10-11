-- co-pilot and related plugins

return {
  { -- co-pilot
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = false,
          auto_trigger = true,
          keymap = {
            accept = "<C-y>",
            accept_word = false,
            accept_line = false,
            next = "<C-n>",
            prev = "<C-p>",
            dismiss = "<C-e>",
          },
        },
        filetypes = {
          markdown = true,
        },
        copilot_node_command = "node",
      })
    end,
    dependencies = {},
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
  },
}
