-- supercollider
-- TODO: debug and integrate

-- fixing help?
-- require("scnvim.help").on_open:replace(function(err, uri, pattern)
-- 	print("lookin for " .. uri)
-- end)

return { -- supercollider
  "davidgranstrom/scnvim",
  ft = { "supercollider" },
  config = function()
    local scnvim = require("scnvim")
    local map = scnvim.map
    local map_expr = scnvim.map_expr

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
        float = {
          enabled = true,
          config = {
            border = border,
            anchor = "SE",
          },
        },
      },
    })

    -- require("scnvim.help").on_open:replace(function(err, uri, pattern)
    -- 	print("lookin for " .. uri)
    -- end)
  end,
}
