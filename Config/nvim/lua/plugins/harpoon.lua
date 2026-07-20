return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      return {
        { "<leader>ha", function() harpoon:list():add() end, desc = "Harpoon: dodaj plik" },
        { "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon: menu" },
        { "<leader>1", function() harpoon:list():select(1) end, desc = "Harpoon plik 1" },
        { "<leader>2", function() harpoon:list():select(2) end, desc = "Harpoon plik 2" },
        { "<leader>3", function() harpoon:list():select(3) end, desc = "Harpoon plik 3" },
        { "<leader>4", function() harpoon:list():select(4) end, desc = "Harpoon plik 4" },
        { "<C-S-P>", function() harpoon:list():prev() end, desc = "Harpoon: poprzedni" },
        { "<C-S-N>", function() harpoon:list():next() end, desc = "Harpoon: następny" },
      }
    end,
  },
}
