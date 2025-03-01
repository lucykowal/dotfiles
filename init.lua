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
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
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
            i = {
              ["<esc>"] = require("telescope.actions").close,
              ["<CR>"] = function(bufnr)
                local a, b = require("telescope.actions").select_default(bufnr)
                require("CopilotChat").close()
                return a, b
              end,
            },
            n = {
              ["q"] = require("telescope.actions").close,
              ["<C-n>"] = require("telescope.actions").move_selection_next,
              ["<C-p>"] = require("telescope.actions").move_selection_previous,
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

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
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
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      {
        "j-hui/fidget.nvim",
        opts = {
          progress = {
            suppress_on_insert = true,
            ignore_done_already = true,
            display = {
              render_limit = 4,
              done_ttl = 1,
            },
          },
          notification = {
            window = {
              align = "top",
            },
          },
        },
      },

      -- Allows extra capabilities provided by nvim-cmp
      "hrsh7th/cmp-nvim-lsp",
      "nvim-java/nvim-java",
    },
    config = function()
      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

          -- Find references for the word under your cursor.
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      -- custom float style (global)
      local orig_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        local border = {
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
        opts.border = opts.border or border
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

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- See `:help lspconfig-all` for a list of all the pre-configured LSPs
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      require("mason").setup({
        ui = {
          border = border,
          width = popup_width,
        },
      })

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua", -- Used to format Lua code
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })

      require("lspconfig").jdtls.setup({})
    end,
  },

  { -- Autoformat
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = "never"
        else
          lsp_format_opt = "fallback"
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        markdown = { "deno_fmt" },
        go = { "gofmt" },
        java = { "google-java-format" },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
  { -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          },
        },
      },
      "saadparwaiz1/cmp_luasnip",

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
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
        completion = { completeopt = "menu,menuone,noinsert" },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert({
          -- Select the [n]ext item
          ["<C-n>"] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ["<C-p>"] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ["<C-Space>"] = cmp.mapping.complete({}),

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { "i", "s" }),
          ["<C-h>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { "i", "s" }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        }),
        sources = {
          {
            name = "lazydev",
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = "minuet" },
          { name = "copilot" },
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "luasnip" },
          { name = "dictionary", keyword_length = 2 },
        },
      })
    end,
  },

  {
    -- To see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Make sure to load this before all the other start plugins.
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
            TodoBgTODO = { bg = colors.blue, fg = colors.base, style = { "bold" } },
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
      -- Load the colorscheme here.
      vim.cmd.colorscheme("catppuccin-latte")

      -- You can configure highlights by doing something like:
      -- vim.cmd.hi("Comment gui=none")
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },

  { -- Collection of various small independent plugins/modules
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup({ n_lines = 500 })

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.surround").setup()

      -- Comment from Normal mode
      --
      -- - gcc - Comment line
      require("mini.comment").setup()

      -- Welcome screen
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
          local handle = io.popen("fortune")
          local fortune = handle:read("*a")
          handle:close()
          fortune = fortune:gsub("\n", "\n")
          return "Hi Lucy.\n\n" .. fortune
        end,
      })

      -- Ranger-like file browser
      --
      -- - [] - open
      require("mini.files").setup({})
      local minifiles_toggle = function(...)
        if not MiniFiles.close() then
          MiniFiles.open(...)
        end
      end
      vim.keymap.set("n", "<leader>a", minifiles_toggle, { desc = "Open file r[a]nger" })

      --  See: https://github.com/echasnovski/mini.nvim
    end,
  },

  { -- Vim movement guide
    "tris203/precognition.nvim",
    event = "VeryLazy",
    config = function()
      require("precognition").setup({
        startVisible = false,
      })
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = { --[[ things you want to change go here]]
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

  { -- Highlight, edit, and navigate code
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
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = { enable = true, disable = { "ruby" } },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },

  -- supercollider
  {
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

  -- for love lua dev
  {
    "S1M0N38/love2d.nvim",
    cmd = "LoveRun",
    opts = {},
    ft = "lua",
    keys = {
      { "<leader>v", ft = "lua", dev = "LÖVE" },
      { "<leader>vv", "<cmd>LoveRun<cr>", ft = "lua", desc = "Run LÖVE" },
      { "<leader>vs", "<cmd>LoveStop<cr>", ft = "lua", desc = "Stop LÖVE" },
    },
  },

  -- Render markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    ft = { "markdown", "codecompanion" },
    opts = {},
  },

  -- Some word-processing plugins
  -- Dictionary recommendations
  {
    "uga-rosa/cmp-dictionary",
    name = "cmp_dictionary",
    config = function()
      require("cmp_dictionary").setup({
        paths = { "/usr/share/dict/words" },
        exact_length = 2,
      })
    end,
  },
  -- Grammar check. Not great, but there aren't many options nowadays
  {
    "rhysd/vim-grammarous",
  },

  { -- Co-pilot for work :(
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = false,
          auto_trigger = true, --  NOTE: may want to toggle, since this might get annoying.
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
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      if ollama_host then
        require("minuet").setup({
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
        })
      end
    end,
  },
  -- plugin is kinda annoying, back to copilot chat for now.
  -- {
  --   "olimorris/codecompanion.nvim",
  --   config = function()
  --     require("codecompanion").setup({
  --       strategies = {
  --         chat = {
  --           adapter = "copilot",
  --         },
  --       },
  --       display = {
  --         action_palette = { provider = "telescope" },
  --         chat = {
  --           intro_message = "Hi Lucy, how can I help? Press ? for options",
  --           -- start_in_insert_mode = true,
  --           window = {
  --             layout = "float",
  --             position = "top",
  --             border = border,
  --             width = popup_width,
  --             height = 0.75,
  --           },
  --         },
  --       },
  --     })
  --     local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})
  --     -- Modify buffer
  --     vim.api.nvim_create_autocmd({ "User" }, {
  --       pattern = "CodeCompanionChatOpened",
  --       group = group,
  --       callback = function(request)
  --         local bufnr = request.data.bufnr
  --         local win_id = vim.fn.bufwinid(bufnr)
  --         vim.api.nvim_win_set_config(
  --           vim.fn.win_id2win(win_id),
  --           vim.tbl_deep_extend("keep", vim.api.nvim_win_get_config(win_id), { { anchor = "N" } })
  --         )
  --       end,
  --     })
  --     -- Format the buffer after the inline request has completed
  --     vim.api.nvim_create_autocmd({ "User" }, {
  --       pattern = "CodeCompanionInline*",
  --       group = group,
  --       callback = function(request)
  --         if request.match == "CodeCompanionInlineFinished" then
  --           require("conform").format({ bufnr = request.buf })
  --         end
  --       end,
  --     })
  --   end,
  --   keys = {
  --     { "<leader>g", "<cmd>CodeCompanionChat toggle<cr>", desc = "Open Code Companion Chat" },
  --   },
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  -- },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
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
              error(err)
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
          layout = "float",
          relative = "win",
          border = border,
          width = popup_width,
          height = 0.75,
          row = 1,
        },
        shared = {
          auto_insert_mode = true,
        },
        mappings = {
          complete = {
            insert = "<C-y>",
          },
        },
        model = ollama_host and "codellama:7b-instruct" or "claude-3.7-sonnet",
        providers = ollama_host and {
          ollama = ollama_provider("http://localhost:11434"),
          ollama_ubuntu = ollama_provider(ollama_host .. ":11434"),
        } or nil,
      })
      vim.keymap.set("n", "<leader>g", function()
        chat.open()
      end, { desc = "Open AI chat" })
    end,
  },
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
