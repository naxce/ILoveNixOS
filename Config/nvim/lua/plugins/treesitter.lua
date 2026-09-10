return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup({})

      local ensure_installed = {
        "nix", "lua", "vim", "vimdoc",
        "python", "rust", "c", "cpp",
        "javascript", "typescript", "tsx",
        "java", "go",
        "bash", "fish",
        "json", "jsonc", "yaml", "toml",
        "markdown", "markdown_inline",
        "html", "css",
        "sql", "regex",
        "gitcommit", "gitignore", "diff",
        "dockerfile",
      }

      local installed = require("nvim-treesitter.config").get_installed()
      local to_install = vim.iter(ensure_installed)
        :filter(function(lang) return not vim.tbl_contains(installed, lang) end)
        :totable()
      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if ok then
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.bo[args.buf].indentexpr = "v:lua.vim.treesitter.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },
}
