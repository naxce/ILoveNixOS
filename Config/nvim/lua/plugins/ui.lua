return {

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      local noir = {
        normal = { a = { fg = "#000000", bg = "#ffffff", gui = "bold" }, b = { fg = "#e8e8e8", bg = "#1a1a1a" }, c = { fg = "#8a8a8a", bg = "#000000" } },
        insert = { a = { fg = "#000000", bg = "#e8e8e8", gui = "bold" }, b = { fg = "#e8e8e8", bg = "#1a1a1a" }, c = { fg = "#8a8a8a", bg = "#000000" } },
        visual = { a = { fg = "#000000", bg = "#b0b0b0", gui = "bold" }, b = { fg = "#e8e8e8", bg = "#1a1a1a" }, c = { fg = "#8a8a8a", bg = "#000000" } },
        replace = { a = { fg = "#ffffff", bg = "#333333", gui = "bold" }, b = { fg = "#e8e8e8", bg = "#1a1a1a" }, c = { fg = "#8a8a8a", bg = "#000000" } },
        command = { a = { fg = "#000000", bg = "#ffffff", gui = "bold" }, b = { fg = "#e8e8e8", bg = "#1a1a1a" }, c = { fg = "#8a8a8a", bg = "#000000" } },
        inactive = { a = { fg = "#6a6a6a", bg = "#0a0a0a" }, b = { fg = "#6a6a6a", bg = "#0a0a0a" }, c = { fg = "#6a6a6a", bg = "#0a0a0a" } },
      }

      require("lualine").setup({
        options = {
          theme = noir,
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = {
            { "diagnostics", symbols = { error = "✖ ", warn = "▲ ", info = "● ", hint = "○ " } },
            { "filename", path = 1 },
          },
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      win = { border = "rounded" },
      icons = { mappings = false },
    },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Pokaż wszystkie skróty w buforze",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      max_lines = 3,
      mode = "cursor",
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({})
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n" },
      { "gc", mode = { "n", "v" } },
    },
    opts = {},
  },

  {
    "norcalli/nvim-colorizer.lua",
    ft = { "css", "html", "javascript", "typescript", "lua", "conf" },
    opts = {},
  },

  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "",
        "  ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
        "  ████╗  ██║██║   ██║██║████╗ ████║",
        "  ██╔██╗ ██║██║   ██║██║██╔████╔██║",
        "  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "           N O I R   E D I T",
        "",
      }
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Znajdź plik", ":Telescope find_files<CR>"),
        dashboard.button("g", "  Grep w projekcie", ":Telescope live_grep<CR>"),
        dashboard.button("r", "  Ostatnie pliki", ":Telescope oldfiles<CR>"),
        dashboard.button("e", "  Drzewo plików", ":Neotree toggle<CR>"),
        dashboard.button("y", "  Otwórz Yazi", ":lua require('yazi').yazi()<CR>"),
        dashboard.button("l", "  Lazy (pluginy)", ":Lazy<CR>"),
        dashboard.button("q", "  Wyjście", ":qa<CR>"),
      }
      dashboard.section.footer.val = ""

      for _, section in pairs({ dashboard.section.header, dashboard.section.buttons, dashboard.section.footer }) do
        section.opts = section.opts or {}
        section.opts.hl = "Normal"
      end
      dashboard.section.header.opts.hl = "Title"

      alpha.setup(dashboard.opts)
    end,
  },
}
