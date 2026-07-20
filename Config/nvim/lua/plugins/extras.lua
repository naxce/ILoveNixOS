return {

  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Undotree" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Znajdź TODO w projekcie" },
    },
    opts = {
      signs = false,
      keywords = {
        FIX = { icon = "✖", color = "#ffffff" },
        TODO = { icon = "●", color = "#e8e8e8" },
        HACK = { icon = "▲", color = "#b0b0b0" },
        WARN = { icon = "▲", color = "#b0b0b0" },
        NOTE = { icon = "○", color = "#8a8a8a" },
      },
    },
  },

  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
    init = function()
      vim.g.VM_theme = "iceblue"
      vim.g.VM_default_mappings = 1
      vim.g.VM_maps = {
        ["Find Under"] = "<C-d>",
        ["Find Subword Under"] = "<C-d>",
      }
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash: skok" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash: skok po składni" },
    },
    opts = {},
  },

  { "andymass/vim-matchup", event = { "BufReadPost", "BufNewFile" } },

  { "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } },

  { "kylechui/nvim-surround", event = { "BufReadPost", "BufNewFile" }, opts = {} },
}
