local settings = require("settings")

local function get_jdtls_root()
  local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
  return vim.fs.root(0, root_markers)
end

-- get my jdtls bundles from mason
local function get_jdtls_bundles()
  local mason_packages = require("mason.settings").current.install_root_dir .. "/packages"

  local jdebug_path = mason_packages .. "/java-debug-adapter"

  local bundles = {
    vim.fn.glob(jdebug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true),
  }
  vim.list_extend(bundles, require("spring_boot").java_extensions())

  return bundles
end

-- helpers to get the jdtls command, pulling in jars from mason
local function get_jdtls_cmd()
  local home = vim.fn.getenv("HOME")

  local project_name = vim.fn.fnamemodify(get_jdtls_root(), ":p:h:t")
  local workspace_dir = home .. "/.cache/jdtls/workspace" .. project_name

  local mason_packages = require("mason.settings").current.install_root_dir .. "/packages"

  local jdtls_path = mason_packages .. "/jdtls"

  local config_type = "/config_mac" .. (vim.uv.os_uname().machine == "x86_64" and "" or "_arm")
  local config_path = jdtls_path .. config_type
  local lombok_path = mason_packages .. "/lombok-nightly/lombok.jar"

  local jar_path = jdtls_path .. "/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar"

  return {
    -- NOTE: you must set $JAVA_HOME to `/usr/libexec/java_home -v 21`
    vim.fn.getenv("JAVA_HOME") .. "/bin/java",

    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "-javaagent:" .. lombok_path,
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",

    "-jar",
    jar_path,

    "-configuration",
    config_path,

    "-data",
    workspace_dir,
  }
end

return {
  { -- java support
    "JavaHello/spring-boot.nvim",
    ft = { "java", "yaml", "jproperties" },
    dependencies = {
      {
        "mfussenegger/nvim-jdtls",
        ft = { "java", "yaml", "jproperties" },
        config = function()
          require("jdtls")
        end,
      },
    },
    opts = {},
  },
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

      "mfussenegger/nvim-dap",
      "jay-babu/mason-nvim-dap.nvim",
      "hrsh7th/cmp-nvim-lsp",
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
          map("<leader>cd", require("telescope.builtin").lsp_document_symbols, "[C]ode [D]ocument symbols")
          map("<leader>cw", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[C]ode [W]orkspace symbols")
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
        jdtls = function() -- lazy load, spring tools is slow to require
          return {
            cmd = get_jdtls_cmd(),
            root_dir = get_jdtls_root(),
            filetypes = { "java", "jproperties", "yaml" },
            handlers = require("lspconfig.configs.jdtls").default_config.handlers,
            init_options = {
              bundles = get_jdtls_bundles(),
            },
            settings = {
              java = {
                references = {
                  includeDecompiledSources = true,
                },
                format = {
                  enabled = false,
                },
                eclipse = {
                  downloadSources = true,
                },
                maven = {
                  downloadSources = true,
                },
                signatureHelp = {
                  enabled = true,
                },
                filteredTypes = {
                  "com.sun.*",
                  "io.micrometer.shaded.*",
                  "java.awt.*",
                  "sun.*",
                },
                importOrder = {
                  "java",
                  "javax",
                  "com",
                  "org",
                },
              },
              sources = {
                organizeImports = {
                  starThreshold = 9999,
                  staticStarThreshold = 9999,
                },
              },
            },
          }
        end,
        -- python
        pylsp = {},
        basedpyright = {},
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
          width = settings.window.width(),
          height = settings.window.height(),
        },
        registries = {
          "github:mason-org/mason-registry",
          "github:nvim-java/mason-registry",
        },
      })

      -- tools beyond lspconfig for mason to install
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        -- lua
        "stylua",
        -- java
        "google-java-format",
        "java-debug-adapter",
        "java-test",
        "lombok-nightly",
        "spring-boot-tools",
        -- python
        "autopep8",
        -- json, etc.
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
          ["harper_ls"] = function(_)
            local server = servers["harper_ls"]
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig").harper_ls.setup(server)
            -- TODO: figure out an appropriate config that isn't annoying :P
          end,
          ["jdtls"] = function(_)
            -- no-op, use autocommand instead for java
          end,
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "java", "jproperties", "yaml" },
        callback = function()
          require("spring_boot").init_lsp_commands()
          require("jdtls").start_or_attach(servers.jdtls(), {})
        end,
      })
    end,
  },
}
