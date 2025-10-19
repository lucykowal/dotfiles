-- fuzzy finder

-- custom actions for fzf pickers:
-- fzf over current buffer with line numbers
local function fzf_current_buffer()
  local sel_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local numbered_lines = {}
  for i, line in ipairs(sel_lines) do
    table.insert(numbered_lines, string.format("%4d: %s", i, line))
  end

  vim.fn["fzf#run"](vim.fn["fzf#wrap"]({
    source = numbered_lines,
    -- activate a search based on query
    ["sink*"] = function(lines)
      if #lines >= 2 then
        -- extract selected line/# and query
        local query = lines[1]
        local selected_line = lines[2]
        local line_num = tonumber(selected_line:match("^%s*(%d+):"))

        if line_num then
          -- go to the line
          vim.api.nvim_win_set_cursor(0, { line_num, 0 })
          vim.cmd("normal! zz")

          -- if there was a query, use it as search pattern
          if query and query ~= "" then
            -- defer to allow cursor move to complete
            vim.defer_fn(function()
              -- escape special characters for literal search
              local escaped_query = vim.fn.escape(query, [[\/.*$^~[]])
              vim.fn.setreg("/", escaped_query)
              vim.fn.histadd("/", escaped_query)
              vim.o.hlsearch = true

              -- do the search
              vim.fn.search(escaped_query, "c")
            end, 10)
          end
        end
      end
    end,
    options = { "--prompt=Lines>", "--print-query" },
  }))
end

-- config
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

    vim.keymap.set("n", "<leader>s/", fzf_current_buffer, { desc = "[S]earch current buffer [/]" })

    vim.g.fzf_layout = {
      window = { -- pop-up at bottom
        width = 1.0,
        height = 0.4,
        relative = false,
        yoffset = 1.0,
      },
    }

    vim.g.fzf_colors = {
      fg = { "fg", "Normal" },
      bg = { "bg", "Normal" },
      hl = { "fg", "Comment" },
      ["fg+"] = { "fg", "CursorLine", "CursorColumn", "Normal" },
      ["bg+"] = { "bg", "CursorLine", "CursorColumn" },
      ["hl+"] = { "fg", "Statement" },
      info = { "fg", "PreProc" },
      border = { "fg", "Ignore" },
      prompt = { "fg", "Conditional" },
      pointer = { "fg", "Exception" },
      marker = { "fg", "Keyword" },
      spinner = { "fg", "Label" },
      header = { "fg", "Comment" },
    }

    -- keys:
    -- ctrl-c (or -x, -q) to exit. faster than esc due to nvim key handling.
    -- ctrl-s, ctrl-v to open in split, vsplit
    -- ctrl-'-' to toggle preview
    -- ctrl-w to toggle wrapping
    vim.g.fzf_action = {
      ["ctrl-s"] = "split",
      ["ctrl-v"] = "vsplit",
      ["esc"] = function()
        vim.notify("Use <ctrl>+c instead of <esc>")
      end,
    }
  end,
}
