return {

  -- Pure Lua local dev server: live reload for HTML/CSS/JS in the browser.
  {
    "selimacerbas/live-server.nvim",
    dependencies = {
      "folke/which-key.nvim",
      "nvim-telescope/telescope.nvim",
    },
    init = function()
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add({ { "<leader>l", group = "LiveServer" } })
      end
    end,
    opts = {
      default_port = 8000,
      live_reload = { enabled = true, inject_script = true, debounce = 120, css_inject = true },
      directory_listing = { enabled = true, show_hidden = false },
    },
    keys = {
      { "<leader>ls", "<cmd>LiveServerStart<CR>", desc = "LiveServer: uruchom (wybierz ścieżkę i port)" },
      { "<leader>lo", "<cmd>LiveServerOpen<CR>", desc = "LiveServer: otwórz istniejący port w przeglądarce" },
      { "<leader>lr", "<cmd>LiveServerReload<CR>", desc = "LiveServer: wymuś odświeżenie" },
      { "<leader>lt", "<cmd>LiveServerToggleLive<CR>", desc = "LiveServer: włącz/wyłącz live-reload" },
      { "<leader>li", "<cmd>LiveServerStatus<CR>", desc = "LiveServer: status serwerów" },
      { "<leader>lS", "<cmd>LiveServerStop<CR>", desc = "LiveServer: zatrzymaj jeden (wybierz port)" },
      { "<leader>lA", "<cmd>LiveServerStopAll<CR>", desc = "LiveServer: zatrzymaj wszystkie" },
    },
    config = function(_, opts)
      require("live_server").setup(opts)
    end,
  },

  -- Live Markdown preview in the browser, built on top of live-server.nvim.
  {
    "selimacerbas/markdown-preview.nvim",
    dependencies = { "selimacerbas/live-server.nvim" },
    ft = { "markdown" },
    keys = {
      { "<leader>mps", "<cmd>MarkdownPreview<CR>", desc = "Markdown: uruchom podgląd na żywo" },
      { "<leader>mpr", "<cmd>MarkdownPreviewRefresh<CR>", desc = "Markdown: wymuś odświeżenie podglądu" },
      { "<leader>mpS", "<cmd>MarkdownPreviewStop<CR>", desc = "Markdown: zatrzymaj podgląd" },
    },
    config = function()
      require("markdown_preview").setup({
        instance_mode = "takeover",
        port = 0,
        open_browser = true,
        auto_refresh = true,
        debounce_ms = 300,
        scroll_sync = true,
      })
    end,
  },

}
