-- ==================
-- lucy's nvim config
-- ==================

local popup_width = 0.8
local border = "single"
local ollama_host = vim.env.SERVER_ADDR

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`

-- Disable spell checking, but add a toggle keymap to enable.
vim.o.spell = false
vim.o.spelllang = "en_us"
vim.keymap.set("n", "<leader>S", ":set spell!<CR>", { desc = "[S]pell check toggle" })

-- Enable true color support
vim.o.termguicolors = true

-- Window options
vim.o.ead = "ver"
vim.o.ea = false
vim.o.splitright = true
vim.o.splitbelow = true

-- QoL/UX options
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300 -- for mapped sequences
vim.o.updatetime = 250
vim.o.undofile = true
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- UI
vim.o.number = true
vim.o.signcolumn = "yes"
vim.o.breakindent = true
vim.o.inccommand = "split"
vim.o.list = true
vim.opt.listchars = { tab = "| ", trail = "·", nbsp = "␣", extends = "→", precedes = "←" }
vim.opt.cursorline = true
vim.o.scrolloff = 30

-- [[ Basic Keymaps ]]
-- See `:help vim.keymap`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear highlights on <Esc>
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<CS-H>", "<C-w>H", { desc = "Move window to the far left" })
vim.keymap.set("n", "<CS-L>", "<C-w>L", { desc = "Move window to the far right" })
vim.keymap.set("n", "<CS-J>", "<C-w>J", { desc = "Move window to the far top" })
vim.keymap.set("n", "<CS-K>", "<C-w>K", { desc = "Move window to the far bottom" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Force help windows to the right",
  group = vim.api.nvim_create_augroup("help-win-right", { clear = true }),
  pattern = "*/doc/*",
  callback = function(ev)
    local rtp = vim.o.runtimepath
    local files = vim.fn.globpath(rtp, "doc/*", true, 1)
    if ev.file and vim.list_contains(files, ev.file) then
      vim.cmd.wincmd("L")
      vim.cmd("vert resize " .. math.max(90, math.min(60, math.floor(vim.o.columns * 0.4))))
    end
  end,
})

-- [[ Filetypes ]]
vim.filetype.add({ extension = { frag = "glsl" } })

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt`
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require("lazy").setup({
  { -- Detect tabstop and shiftwidth automatically
    -- *very* nice with https://editorconfig.org/
    "tpope/vim-sleuth",
    event = "VimEnter",
  },

  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
    },
  },

  { -- Show key binds
    "folke/which-key.nvim",
    event = "UIEnter",
    opts = {
      preset = "classic",
      filter = function(mapping)
        return mapping.desc and mapping.desc ~= ""
      end,
      spec = {
        { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
        { "<leader>d", group = "[D]ocument" },
        { "<leader>r", group = "[R]ename" },
        { "<leader>s", group = "[S]earch" },
        { "<leader>w", group = "[W]orkspace" },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>v", group = "Love2D" },
      },
      win = { -- see `:help api-win_config`
        height = 10,
        row = vim.o.lines - 10,
        width = vim.o.columns,
        padding = { 0, 0 },
        -- clockwise from top left
        border = { "─", "─", "─", "", "", "", "", "" },
      },
      layout = {
        width = { min = 14, max = 40 },
        spacing = 2,
      },
      expand = 1,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {},
      },
      show_help = false,
    },
  },

  { -- Telescope, incredibly powerful fuzzy finder
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },

      { -- supercollider docs
        -- TODO: make sure this works
        "davidgranstrom/telescope-scdoc.nvim",
      },

      { -- recent/frequent files
        "nvim-telescope/telescope-frecency.nvim",
        -- install the latest stable version
        version = "*",
        config = function()
          vim.keymap.set("n", "<leader>sf", function()
            require("telescope").extensions.frecency.frecency({ workspace = "CWD" })
          end, { desc = "[S]earch [F]iles" })
        end,
      },
    },
    config = function() -- See `:help telescope` and `:help telescope.setup()`
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          sorting_strategy = "ascending",
          selection_strategy = "closest",
          layout_config = {
            horizontal = {
              anchor = "N",
              prompt_position = "top",
              height = 0.75,
              width = { popup_width, max = 300, min = 30 },
              preview_width = { 0.5, max = 40, min = 10 },
            },
          },
          path_display = {
            truncate = 2,
            shorten = { len = 3, exclude = { -1, -2 } },
          },
          initial_mode = "normal",
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          mappings = { -- See `:help telescope.actions`
            n = {
              ["q"] = require("telescope.actions").close,
              ["<C-n>"] = require("telescope.actions").move_selection_next,
              ["<C-p>"] = require("telescope.actions").move_selection_previous,
              ["<C-y"] = require("telescope.actions").select_default,
            },
          },
          dynamic_preview_title = true,
        },
        pickers = {
          find_files = {
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
          },
          buffers = {
            mappings = {
              n = {
                ["d"] = require("telescope.actions").delete_buffer + require("telescope.actions").move_to_top,
              },
            },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              layout_config = {
                anchor = "N",
              },
              borderchars = {
                { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
                results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
                preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
              },
            }),
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
      pcall(telescope.load_extension, "frecency")
      pcall(telescope.load_extension, "scdoc")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
      vim.keymap.set(
        "n",
        "<leader>/",
        builtin.current_buffer_fuzzy_find,
        { desc = "[/] Fuzzily search in current buffer" }
      )
      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, { desc = "[S]earch [/] in Open Files" })
    end,
  },

  { -- LSP bootstrap for Neovim
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },

  {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    dependencies = {
      { -- NOTE: Must be loaded before dependants
        "williamboman/mason.nvim",
        config = true,
      },
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      { -- Status updates, notifications
        "j-hui/fidget.nvim",
        event = "UIEnter",
        opts = {
          progress = {
            suppress_on_insert = true,
            ignore_done_already = true,
            display = {
              render_limit = 8,
              done_ttl = 1,
            },
          },
          notification = {
            override_vim_notify = true,
            view = {
              stack_upwards = false,
            },
            window = {
              winblend = 0,
              border = border,
              x_padding = 1,
              align = "top",
            },
          },
        },
      },
      "hrsh7th/cmp-nvim-lsp",
      "nvim-java/nvim-java",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(attach_event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = attach_event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
          map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
          map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
          map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

          -- Usually apply to errors
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- Setup symbol highlights on cursor hold
          -- See `:help CursorHold`
          local client = vim.lsp.get_client_by_id(attach_event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = attach_event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = attach_event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(detach_event)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = detach_event.buf })
              end,
            })
          end
        end,
      })

      -- replace the default floating preview with a custom one
      local orig_open_floating_preview = vim.lsp.util.open_floating_preview
      ---@diagnostic disable-next-line: duplicate-set-field
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        local borderchars = {
          { "┌", "FloatBorder" },
          { "─", "FloatBorder" },
          { "┐", "FloatBorder" },
          { "│", "FloatBorder" },
          { "┘", "FloatBorder" },
          { "─", "FloatBorder" },
          { "└", "FloatBorder" },
          { "│", "FloatBorder" },
        }
        opts = opts or {}
        ---@diagnostic disable-next-line: inject-field
        opts.border = opts.border or borderchars
        return orig_open_floating_preview(contents, syntax, opts, ...)
      end

      -- Change diagnostic symbols in the sign column (gutter)
      if vim.g.have_nerd_font then
        local signs = { Error = "", Warn = "", Hint = "", Info = "" }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
      end

      -- broadcast cmp capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      --  required lsps with overridable configs
      --  - cmd (table): Command to start server
      --  - filetypes (table): filetypes to attach to the server
      --  - capabilities (table): change capabilities
      --  - settings (table): default settings - i.e. args
      local servers = {
        -- See `:help lspconfig-all` for a list of all the pre-configured LSPs
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = { disable = { "missing-fields" } },
            },
          },
        },
        jdtls = {},
        gopls = {},
        yamlls = { -- NOTE: requires `yarn`
          settings = {
            redhat = {
              telemetry = { enabled = false },
            },
          },
        },
        cssls = {}, -- NOTE: requires `npm`
        html = {},
        harper_ls = { -- check grammar
          filetypes = { "markdown" },
        },
      }

      -- see :Mason to manage
      require("mason").setup({
        ui = {
          border = border,
          width = popup_width,
        },
      })

      -- tools beyond lspconfig for mason to install
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua",
        "google-java-format",
        "prettier",
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- set capabilities with force to use above `server` configs
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },

  { -- autoformat
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      notify_on_error = true,
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        markdown = { "deno_fmt" },
        go = { "gofmt" },
        java = { "google-java-format" },
      },
    },
  },

  { -- autocomplete
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      { -- snippets in nvim-cmp
        "L3MON4D3/LuaSnip",
        build = (function()
          -- build for regex support in snippets
          return "make install_jsregexp"
        end)(),
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          },
        },
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
    },
    config = function()
      -- See `:help cmp`
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete({}), -- trigger completion
          ["<C-l>"] = cmp.mapping(function() -- move forward in snippet
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { "i", "s" }),
          ["<C-h>"] = cmp.mapping(function() -- and backwards
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { "i", "s" }),
        }),
        sources = {
          {
            name = "lazydev",
            group_index = 0, -- skip loading completions
          },
          { name = "copilot" },
          { name = "nvim_lsp" },
          { name = "minuet", max_item_count = 2 },
          { name = "path" },
          { name = "luasnip" },
          {
            name = "dictionary",
            keyword_length = 2,
            max_item_count = 5,
          },
        },
        window = {
          completion = cmp.config.window.bordered({
            focusable = false,
            winblend = 100,
            border = border,
          }),
          documentation = cmp.config.window.bordered({
            winblend = 0,
            border = border,
          }),
        },
      })
    end,
  },

  -- TODO: debug, integrate
  { -- supercollider
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
  },

  { -- for love2d
    "S1M0N38/love2d.nvim",
    cmd = "LoveRun",
    opts = {},
    config = function()
      vim.keymap.set("n", "<leader>vv", "<cmd>LoveRun<cr>", { ft = "lua", desc = "Run LOVE" })
      vim.keymap.set("n", "<leader>vs", "<cmd>LoveRun<cr>", { ft = "lua", desc = "Stop LOVE" })
    end,
  },

  { -- render markdown
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    ft = { "markdown", "copilot-chat" },
    opts = {
      preset = "lazy",
    },
  },

  { -- dictionary recommendations
    "uga-rosa/cmp-dictionary",
    name = "cmp_dictionary",
    ft = { "markdown", "copilot-chat" },
    config = function()
      require("cmp_dictionary").setup({
        paths = { "/usr/share/dict/words" },
        exact_length = 2,
      })
    end,
  },

  { -- theme
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      require("catppuccin").setup({
        flavour = "latte",
        color_overrides = {
          latte = {},
        },
        custom_highlights = function(colors)
          return {
            NormalFloat = { bg = colors.base },
            FloatBorder = { fg = colors.text },
            FloatTitle = { fg = colors.text },
            TodoBgTODO = {
              bg = colors.blue,
              fg = colors.base,
              style = { "bold" },
            },
            TodoFgTODO = { fg = colors.blue },
          }
        end,
        styles = {
          comments = { "italic" },
        },
        integrations = {
          cmp = true,
          treesitter = true,
          mason = true,
          telescope = { enabled = true },
          mini = { enabled = true },
          which_key = true,
          gitsigns = true,
          render_markdown = true,
          fidget = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
              ok = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
              ok = { "underline" },
            },
          },
        },
      })
      vim.cmd.colorscheme("catppuccin-latte")
    end,
  },

  { -- collection of various small independent plugins/modules
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
  },

  { -- terminal float
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      open_mapping = [[<c-\>]],
      shade_terminals = false,
      direction = "float",
      float_opts = {
        border = border,
        row = 1,
        height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        width = function()
          return math.floor(vim.o.columns * popup_width)
        end,
        title_pos = "center",
      },
    },
  },

  { -- highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs", -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
        "java",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = { enable = true, disable = { "ruby" } },
    },
  },

  { -- co-pilot
    "zbirenbaum/copilot.lua",
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
  },

  { -- local completions
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    cond = ollama_host ~= nil,
    opt = {
      provider = "openai_fim_compatible",
      context_window = 512,
      n_completions = 2,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Ollama",
          end_point = ollama_host .. ":11434/v1/completions",
          model = "qwen2.5-coder:1.5b-base-q3_K_S",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
        },
      },
    },
  },

  { -- chat with copilot
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    config = function()
      local chat = require("CopilotChat")
      -- helper since I run ollama on 2 computers...
      local ollama_provider = function(host)
        return {
          embed = "copilot_embeddings",
          prepare_input = require("CopilotChat.config.providers").copilot.prepare_input,
          prepare_output = require("CopilotChat.config.providers").copilot.prepare_output,

          get_models = function(headers)
            local response, err = require("CopilotChat.utils").curl_get(host .. "/api/tags", {
              headers = headers,
              json_response = true,
            })

            if err then
              vim.notify(err, vim.log.levels.ERROR)
              response = { body = { models = {} } }
            end

            return vim.tbl_map(function(model)
              return {
                id = model.name,
                name = model.name,
              }
            end, response.body.models)
          end,

          get_url = function()
            return host .. "/api/chat"
          end,
        }
      end
      chat.setup({
        window = {
          layout = "vertical",
          width = 0.4,

          -- relative = "editor",
          -- border = border,
          -- width = popup_width,
          -- height = 0.75,
          -- row = 1,
        },
        highlight_headers = false,
        insert_at_end = true,
        mappings = {
          complete = {
            insert = "<C-y>",
          },
          accept_diff = {
            normal = "<C-a>",
            insert = "<C-a>",
          },
        },
        model = "claude-3.7-sonnet",
        providers = ollama_host and {
          ollama = ollama_provider("http://localhost:11434"),
          ollama_ubuntu = ollama_provider(ollama_host .. ":11434"),
          github_models = nil,
          copilot_embeddings = nil,
        } or {
          github_models = nil,
          copilot_embeddings = nil,
        },
      })

      -- vim.api.nvim_create_autocmd("BufWinEnter", {
      --   pattern = "copilot-*",
      --   callback = function(ev)
      --     -- buf, id?
      --     local wins = vim.api.nvim_list_wins()
      --     -- if more than 2 windows
      --     if #wins > 2 then
      --       -- close new copilot window
      --       local max_win = 0
      --       local max_col = 0
      --       for _, win in ipairs(wins) do
      --         if vim.api.nvim_win_get_buf(win) == ev.buf then
      --           vim.api.nvim_win_close(win, false)
      --         else
      --           local _, c = vim.api.nvim_win_get_config(win)
      --           if c and c > max_col then
      --             max_col = c
      --             max_win = win
      --           end
      --         end
      --         -- put in existing window
      --         vim.api.nvim_win_set_buf(max_win, ev.buf)
      --       end
      --     end
      --     vim.opt_local.relativenumber = false
      --     vim.opt_local.number = false
      --   end,
      -- })

      vim.keymap.set("n", "<leader>g", function()
        chat.open()
      end, { desc = "Open AI chat" })

      vim.keymap.set("n", "<leader>ccp", function()
        local actions = require("CopilotChat.actions")
        require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
      end, { desc = "CopilotChat - Prompt actions" })
    end,
  },

  -- end plugins
}, {
  ui = {
    border = border,
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
