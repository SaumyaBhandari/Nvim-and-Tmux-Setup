-- lsp.lua  (put in ~/.config/nvim/lua/plugins/lsp.lua or wherever Lazy expects it)
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "hrsh7th/cmp-nvim-lsp",
    { "j-hui/fidget.nvim", tag = "v1.4.0", opts = {} },
  },
  config = function()
    ---------------------------------------------------------------------------
    -- 1. Common goodies (mappings, highlights, capabilities)
    ---------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
      callback = function(args)
        local buf, client = args.buf, vim.lsp.get_client_by_id(args.data.client_id)
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
        end

        -- navigation
        map("gd", vim.lsp.buf.definition,          "[G]oto [D]efinition")
        map("gr", vim.lsp.buf.references,          "[G]oto [R]eferences")
        map("gI", vim.lsp.buf.implementation,      "[G]oto [I]mplementation")
        map("gD", vim.lsp.buf.declaration,         "[G]oto [D]eclaration")
        map("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")

        -- symbols
        map("<leader>ds", vim.lsp.buf.document_symbol,        "[D]ocument [S]ymbols")
        map("<leader>ws", vim.lsp.buf.workspace_symbol,       "[W]orkspace [S]ymbols")

        -- actions
        map("<leader>rn", vim.lsp.buf.rename,                  "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action,             "[C]ode [A]ction")
        map("K",          vim.lsp.buf.hover,                   "Hover Documentation")

        -- workspace folders
        map("<leader>wa", vim.lsp.buf.add_workspace_folder,    "[W]orkspace [A]dd Folder")
        map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
        map("<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "[W]orkspace [L]ist Folders")

        -- document highlight (if server supports it)
        if client and client.server_capabilities.documentHighlightProvider then
          local hl = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = hl, buffer = buf, callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = hl, buffer = buf, callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    ---------------------------------------------------------------------------
    -- 2. Capabilities (with nvim-cmp integration)
    ---------------------------------------------------------------------------
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities,
                                       require("cmp_nvim_lsp").default_capabilities())

    ---------------------------------------------------------------------------
    -- 3. Language servers we actually want
    ---------------------------------------------------------------------------
    local servers = {
      -- Python -----------------------------------------------------------------
      ruff = {
        -- keep quotes untouched
        settings = {
          tool = { format = { quoteStyle = "preserve" } },
        },
        -- optional: turn off Ruff's own highlighting so we only get diagnostics
        on_attach = function(client, _)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
        -- custom command for “Organise imports”
        commands = {
          RuffOrganiseImports = {
            function()
              vim.uri_from_bufnr(0)
              vim.lsp.buf.execute_command({
                command = "ruff.applyOrganizeImports",
                arguments = { { uri = vim.uri_from_bufnr(0) } },
              })
            end,
            description = "Ruff: organise imports",
          },
        },
      },

      -- Everything else you already had ---------------------------------------
      html   = { filetypes = { "html", "twig", "hbs" } },
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = {
                "${3rd}/luv/library",
                unpack(vim.api.nvim_get_runtime_file("", true)),
              },
            },
            completion = { callSnippet = "Replace" },
            telemetry  = { enable = false },
            diagnostics = { disable = { "missing-fields" } },
          },
        },
      },
      dockerls = {},
      docker_compose_language_service = {},
      rust_analyzer = {
        ["rust-analyzer"] = {
          cargo = { features = "all" },
          checkOnSave = { command = "clippy" },
        },
      },
      tailwindcss = {},
      jsonls      = {},
      sqlls       = {},
      terraformls = {},
      yamlls      = {},
      bashls      = {},
      graphql     = {},
      cssls       = {},
      ltex        = {},
      texlab      = {},
    }

    ---------------------------------------------------------------------------
    -- 4. Mason bootstrapping
    ---------------------------------------------------------------------------
    require("mason").setup()
    local ensure_installed = vim.tbl_keys(servers)
    vim.list_extend(ensure_installed, { "stylua" }) -- extra tool
    require("mason-tool-installer").setup { ensure_installed = ensure_installed }

    require("mason-lspconfig").setup {
      automatic_enable = false,
      handlers = {
        function(server_name)
          local cfg = servers[server_name] or {}
          cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, cfg.capabilities or {})
          require("lspconfig")[server_name].setup(cfg)
        end,
      },
    }
  end,
}


