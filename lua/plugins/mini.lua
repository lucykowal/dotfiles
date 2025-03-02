return { -- collection of various small independent plugins/modules
  "echasnovski/mini.nvim",
  config = function()
    -- around/inside i.e.
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require("mini.ai").setup({ n_lines = 500 })

    -- add/delete/replace surroundings (brackets, quotes, etc.)
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require("mini.surround").setup()

    -- move selection or line up/down
    -- - <M-hjkl> to move, where M is Alt
    require("mini.move").setup()

    -- autopairs
    require("mini.pairs").setup()

    -- - gcc - comment line
    require("mini.comment").setup()

    -- welcome screen
    local starter = require("mini.starter")
    starter.setup({
      items = {
        {
          { action = "Telescope find_files", name = "Files", section = "Telescope" },
          { action = "Telescope live_grep", name = "Live grep", section = "Telescope" },
          { action = "Telescope command_history", name = "Command history", section = "Telescope" },
        },
      },
      header = function()
        local handle = io.popen("fortune") or {}
        local fortune = handle:read("*a")
        handle:close()
        fortune = fortune:gsub("\n", "\n")
        return "Hi Lucy.\n\n" .. fortune
      end,
    })

    -- Ranger-like file browser
    -- TODO: keep?
    require("mini.files").setup({})
    local minifiles_toggle = function(...)
      if not MiniFiles.close() then
        MiniFiles.open(...)
      end
    end
    vim.keymap.set("n", "<leader>a", minifiles_toggle, { desc = "Open file r[a]nger" })
  end,
}
