-- supercollider

return { -- supercollider
  "davidgranstrom/scnvim",
  ft = { "supercollider" },
  config = function()
    local scnvim = require("scnvim")
    local map = scnvim.map

    scnvim.setup({
      documentation = {
        cmd = "/opt/homebrew/bin/pandoc",
      },
      keymaps = {
        ["<leader>E"] = map("editor.send_line", { "i", "n" }),
        ["<leader>e"] = {
          map("editor.send_block", { "i", "n" }),
          map("editor.send_selection", { "x" }),
        },
      },
      postwin = {
        size = require("settings").window.width,
      },
    })

    vim.api.nvim_set_keymap(
      "n",
      "<leader>sc",
      "<cmd>Telescope scdoc<CR>",
      { desc = "[S]earch Super[C]ollider documentation" }
    )

    -- TODO: autocommand on open/close to open/close server?
  end,
}
