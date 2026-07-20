return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Znajdź plik" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Grep w projekcie" },
      { "<leader>fw", function() require("telescope.builtin").grep_string() end, desc = "Grep słowo pod kursorem" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Otwarte bufory" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Pomoc Neovima" },
      { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Ostatnio otwierane" },
      { "<leader>fc", function() require("telescope.builtin").git_commits() end, desc = "Git commity" },
      { "<leader>fs", function() require("telescope.builtin").git_status() end, desc = "Git status" },
      { "<leader>fd", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostyka (cały projekt)" },
      { "<leader>fk", function() require("telescope.builtin").keymaps() end, desc = "Wszystkie keymapy" },
      { "<leader>fp", function() require("telescope.builtin").resume() end, desc = "Wznów ostatnie wyszukiwanie" },
      { "<leader>/", function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Szukaj w bieżącym pliku" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "  ",
          selection_caret = " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.9,
            height = 0.85,
          },

          file_ignore_patterns = {
            "%.git/", "node_modules/", "target/", "build/", "dist/",
            "%.lock", "__pycache__/", "%.class", "result/", ".direnv/",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
        },
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },
}
