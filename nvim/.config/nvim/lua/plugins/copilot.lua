-- co-pilot and related plugins
local settings = require("settings")

-- register cmp source to override complete in copilot chat
local function register_cmp()
  local copilot = require("CopilotChat")
  local utils = require("CopilotChat.utils")
  local cmp = require("cmp")
  local comp_tbl = copilot.complete_info()

  -- this table is used to provide completions for chat contexts
  local contexts = {
    buffer = function()
      return vim.tbl_map(
        function(buf)
          local data = { id = buf, name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p:.") }
          return { label = "#buffer:" .. data.id, detail = data.name }
        end,
        vim.tbl_filter(function(buf)
          return utils.buf_valid(buf) and vim.fn.buflisted(buf) == 1
        end, vim.api.nvim_list_bufs())
      )
    end,
    buffers = function()
      return { { label = "#buffers:listed" }, { label = "#buffers:visible" } }
    end,
    file = function()
      local cwd = vim.fn.getcwd()
      local files = require("plenary.scandir").scan_dir(cwd, {
        add_dirs = false,
        respect_gitignore = true,
        max_files = 100,
      })
      return vim.tbl_map(function(file)
        return { label = "#file:" .. tostring(file), kind = 15 }
      end, files)
    end,
    -- TODO: refactor
    files = function()
      local cwd = vim.fn.getcwd()
      local files = require("plenary.scandir").scan_dir(cwd, {
        add_dirs = false,
        respect_gitignore = true,
        max_files = 100,
      })
      return vim.tbl_map(function(file)
        return { label = "#files:" .. tostring(file), kind = 15 }
      end, files)
    end,
    git = function()
      return { { label = "#git:unstaged" }, { label = "#git:staged" } }
    end,
    url = function()
      return { { label = "#url:https://", kind = 15 } }
    end,
    register = function()
      local choices = utils.kv_list({
        ["+"] = "synchronized with the system clipboard",
        ["*"] = "synchronized with the selection clipboard",
        ['"'] = "last deleted, changed, or yanked content",
        ["0"] = "last yank",
        ["-"] = "deleted or changed content smaller than one line",
        ["."] = "last inserted text",
        ["%"] = "name of the current file",
        [":"] = "most recent executed command",
        ["#"] = "alternate buffer",
        ["="] = "result of an expression",
        ["/"] = "last search pattern",
      })
      return vim.tbl_map(function(choice)
        return {
          label = "#register:" .. choice.key,
          kind = 15,
          documentation = { kind = "plaintext", value = choice.value },
        } -- detail or documentation?
      end, choices)
    end,
    system = function()
      local cmds = {} -- TODO: would be cool to check for build tools like gradle and suggest those if relevant
      -- other things i use are git diff, but use the git context instead for that!
      return vim.tbl_map(function(c)
        return {
          label = "#system:'" .. c .. "'",
          kind = 15,
          documentation = { kind = "plaintext", value = "Enter command" },
        }
      end, cmds)
    end,
  }

  -- define the source
  local source = {
    -- modified pattern, adds : as a trigger
    get_keyword_pattern = function()
      return [[\%(@\|/\|#\|\$\|:\)\S*]]
    end,

    -- modified trigger characters, adds :
    get_trigger_characters = function()
      local trigs = comp_tbl.triggers
      table.insert(trigs, ":")
      return trigs
    end,

    -- provide completions
    -- source, params, callback -> void
    complete = function(_, params, callback)
      -- are we completing a context?
      local before = params.context.cursor_before_line
      if before and vim.endswith(before, ":") then
        -- yes: get the prefix and call the context to get completions
        local matches = string.match(before:reverse(), ":(.*)[@/#%$]")
        local prefix = (matches or ""):reverse()
        local context = contexts[prefix]
        vim.notify(prefix)
        if context then
          callback(context())
        end
      else
        -- no: call copilot chat to get completions
        local items = copilot.complete_items()
        local mapped_items = vim.tbl_map(function(i)
          return { label = i.word }
        end, items)
        callback(mapped_items)
      end
    end,

    -- execute the completion
    execute = function(_, item, callback)
      callback(item)
    end,
  }

  cmp.register_source("copilot-chat", source)

  -- additional filetype settings. configures other sources
  cmp.setup.filetype("copilot-chat", {
    sources = {
      { name = "path" },
      {
        name = "dictionary",
        keyword_length = 2,
        max_item_count = 5,
      },
      {
        name = "copilot-chat",
        keyword_length = 0,
      },
      { name = "buffer" },
      { name = "copilot" },
    },
  })
end

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
  { -- chat with copilot
    "CopilotC-Nvim/CopilotChat.nvim",
    version = "~3.10.1",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    keys = { "<leader>gf", "<leader>gs", "<leader>gv", "<leader>ggp" },
    build = "make tiktoken", -- Only on MacOS or Linux
    config = function()
      local chat = require("CopilotChat")
      register_cmp()

      chat.setup({
        window = {
          layout = "float",
          relative = "win",
        },
        auto_follow_cursor = false,
        auto_insert_mode = false,
        insert_at_end = false,
        highlight_headers = false,
        chat_autocomplete = false,
        question_header = "__User__",
        answer_header = "__Copilot__",
        error_header = "__Error__",
        separator = "",
        mappings = {
          complete = {
            insert = "<C-Space>",
            callback = function(_)
              require("cmp").complete({
                config = {
                  sources = {
                    { name = "copilot-chat" },
                  },
                },
              })
            end,
          },
          accept_diff = {
            normal = "<C-a>",
            insert = "<C-a>",
          },
        },
        model = "claude-3.5-sonnet",
        providers = {
          github_models = { disabled = true },
        },
      })

      -- more customized open panel logic
      vim.keymap.set({ "n", "v" }, "<leader>gf", function()
        if vim.api.nvim_win_get_config(0).width * 0.4 > 60 then
          chat.open({
            window = {
              layout = "float",
              relative = "win",
              row = 1,
              col = math.floor(vim.api.nvim_win_get_config(0).width * 0.6),
              width = math.floor(vim.api.nvim_win_get_config(0).width * 0.4),
              height = vim.api.nvim_win_get_config(0).height - 2,
              anchor = "NE",
            },
          })
        else
          chat.open({
            window = {
              layout = "float",
              relative = "win",
              row = math.floor(vim.api.nvim_win_get_config(0).height * 0.6),
              col = 1,
              width = vim.api.nvim_win_get_config(0).width - 2,
              height = math.floor(vim.api.nvim_win_get_config(0).height * 0.4),
              anchor = "NE",
            },
          })
        end
      end, { desc = "[G] CopilotChat [F]loat" })

      vim.keymap.set({ "n", "v" }, "<leader>gs", function()
        chat.open({
          window = {
            layout = "horizontal",
          },
        })
      end, { desc = "[G] CopilotChat [S]plit" })

      vim.keymap.set({ "n", "v" }, "<leader>gv", function()
        chat.open({
          window = {
            layout = "vertical",
          },
        })
      end, { desc = "[G] CopilotChat [V]ertical Split" })

      vim.keymap.set("n", "<leader>ggp", function()
        require("CopilotChat").select_prompt()
      end, { desc = "[G][G] CopilotChat - [P]rompt actions" })
    end,
  },
}
