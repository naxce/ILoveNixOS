return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>ee", "<cmd>Neotree toggle<CR>", desc = "Drzewo plików: pokaż/ukryj" },
      { "<leader>ef", "<cmd>Neotree reveal<CR>", desc = "Drzewo plików: pokaż bieżący plik" },
      { "<leader>eg", "<cmd>Neotree float git_status<CR>", desc = "Drzewo plików: status gita" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = { with_expanders = true, expander_collapsed = "", expander_expanded = "" },
        icon = { folder_closed = "", folder_open = "", folder_empty = "" },
        git_status = {
          symbols = {
            added = "✚", modified = "●", deleted = "✖", renamed = "➜",
            untracked = "?", ignored = "", unstaged = "", staged = "", conflict = "",
          },
        },
      },
      window = {
        position = "left",
        width = 32,
        mappings = {
          ["<space>"] = "none",
          ["l"] = "open",
          ["h"] = "close_node",
          ["<CR>"] = "open",
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      default_source = "filesystem",
    },
  },
}
