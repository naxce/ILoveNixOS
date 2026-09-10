return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls",

        "pyright",
        "ruff",
        "rust_analyzer",
        "clangd",
        "ts_ls",
        "jdtls",
        "bashls",
        "jsonls",
        "yamlls",
        "taplo",
        "marksman",
        "html",
        "cssls",
      },
      automatic_installation = true,
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "j-hui/fidget.nvim", opts = { notification = { window = { winblend = 0 } } } },
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(client, bufnr)
        local map = function(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        map("gd", vim.lsp.buf.definition, "Idź do definicji")
        map("gD", vim.lsp.buf.declaration, "Idź do deklaracji")
        map("gr", require("telescope.builtin").lsp_references, "Referencje (Telescope)")
        map("gI", vim.lsp.buf.implementation, "Idź do implementacji")
        map("gy", vim.lsp.buf.type_definition, "Idź do definicji typu")
        map("K", vim.lsp.buf.hover, "Hover dokumentacja")
        map("<C-k>", vim.lsp.buf.signature_help, "Podpowiedź sygnatury")
        map("<leader>rn", vim.lsp.buf.rename, "Zmień nazwę (rename)")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "Symbole w pliku")
        map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Symbole w projekcie")

        if client.server_capabilities.documentHighlightProvider then
          local hl_group = vim.api.nvim_create_augroup("lsp-highlight-" .. bufnr, { clear = true })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = hl_group,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = hl_group,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
          })
        end

        if client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          map("<leader>th", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
          end, "Przełącz inlay hints")
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client then
            on_attach(client, event.buf)
          end
        end,
      })

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              hint = { enable = true },
            },
          },
        },
        nil_ls = {},
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        ruff = {},
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = { command = "clippy" },
              inlayHints = {
                bindingModeHints = { enable = true },
                closureReturnTypeHints = { enable = "always" },
              },
            },
          },
        },
        clangd = {
          cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
        },
        ts_ls = {
          settings = {
            typescript = { inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayFunctionLikeReturnTypeHints = true,
            } },
          },
        },
        bashls = {},
        jsonls = {},
        yamlls = {},
        taplo = {},
        marksman = {},
        html = {},
        cssls = {},

      }

      for server, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end

      vim.diagnostic.config({
        virtual_text = { prefix = "●", spacing = 4 },
        severity_sort = true,
        float = { border = "rounded", source = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✖",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.INFO] = "●",
            [vim.diagnostic.severity.HINT] = "○",
          },
        },
      })
    end,
  },

  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local jdtls_ok, jdtls = pcall(require, "jdtls")
      if not jdtls_ok then return end
      local root = require("jdtls.setup").find_root({ "pom.xml", "build.gradle", ".git" })
      if not root then return end
      local workspace = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root, ":p:h:t")
      jdtls.start_or_attach({
        cmd = { "jdtls", "-data", workspace },
        root_dir = root,
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Formatuj plik" },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        nix = { "nixfmt" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        sh = { "shfmt" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost", "InsertLeave" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function() lint.try_lint() end,
      })
    end,
  },
}
