return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
      { "-", function() require("oil").open() end, desc = "Otwórz katalog nadrzędny (Oil)" },
    },
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
      float = { border = "rounded" },
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
      },
    },
  },
}
