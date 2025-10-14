-- fuzzy finder
return {
  "junegunn/fzf",
  event = "VeryLazy",
  dependencies = { "junegunn/fzf.vim", "folke/snacks.nvim" },
  config = function()
    -- Keybindings for fzf pickers
    vim.keymap.set("n", "<leader><leader>", ":Buffers<CR>", { desc = "Find Buffers" })
    vim.keymap.set("n", "<leader>sf", ":Files<CR>", { desc = "[S]earch [F]iles" })
    vim.keymap.set("n", "<leader>sh", ":Helptags<CR>", { desc = "[S]earch [H]elp tags" })
    vim.keymap.set("n", "<leader>sr", ":Rg<CR>", { desc = "[S]earch [R]ipgrep" })
    vim.keymap.set("n", "<leader>sc", ":Commands<CR>", { desc = "[S]earch [C]ommands" })
    vim.keymap.set("n", "<leader>sm", ":Marks<CR>", { desc = "[S]earch [M]arks" })
    vim.keymap.set("n", "<leader>so", ":History<CR>", { desc = "[S]earch [O]ld files" })
    vim.keymap.set("n", "<leader>s:", ":History:<CR>", { desc = "[S]earch command history [:]" })

    vim.keymap.set("n", "<leader>sn", function()
      local notifications = require("snacks").notifier.get_history()
      notifications = vim.tbl_map(function(item)
        return item.msg
      end, notifications)
      vim.fn["fzf#run"](vim.fn["fzf#wrap"]({
        source = notifications,
        sink = function(selection)
          vim.fn.setreg('"', selection)
        end,
      }))
    end, { desc = "[S]earch [N]otifications" })

    vim.g.fzf_layout = {
      window = { -- pop-up at bottom
        width = 1.0,
        height = 0.4,
        relative = false,
        yoffset = 1.0,
      },
    }

    -- keys:
    -- ctrl-c (or -x, -q) to exit. faster than esc due to nvim key handling.
    -- ctrl-s, ctrl-v to open in split, vsplit
    -- ctrl-'-' to toggle preview
    -- ctrl-w to toggle wrapping
    vim.g.fzf_action = {
      ["ctrl-s"] = "split",
      ["ctrl-v"] = "vsplit",
      ["esc"] = "bell",
    }
  end,
}
