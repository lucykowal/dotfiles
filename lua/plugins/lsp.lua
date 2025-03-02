local settings = require("settings")

return {
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
            winblend = settings.window.winblend,
            border = settings.window.border,
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
        border = settings.window.border,
        backdrop = 100,
        width = settings.window.width,
        height = settings.window.height,
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
}
