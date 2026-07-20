return {
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>-",
        function() require("yazi").yazi() end,
        desc = "Yazi w katalogu bieżącego pliku",
      },
      {
        "<leader>cw",
        function() require("yazi").yazi(nil, vim.fn.getcwd()) end,
        desc = "Yazi w katalogu roboczym (cwd)",
      },
      {
        "<c-up>",
        function() require("yazi").toggle() end,
        desc = "Wznów ostatnią sesję Yazi",
      },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
        open_file_in_vertical_split = "<c-v>",
        open_file_in_horizontal_split = "<c-x>",
        open_file_in_tab = "<c-t>",
        grep_in_directory = "<c-s>",
        replace_in_directory = "<c-g>",
        cycle_open_buffers = "<tab>",
        copy_relative_path_to_selected_files = "<c-y>",
      },
      floating_window_scaling_factor = 0.9,
      yazi_floating_window_border = "rounded",
    },
  },
}
