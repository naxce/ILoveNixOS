local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Błąd klonowania lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nNaciśnij dowolny klawisz, żeby kontynuować..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  install = { colorscheme = { "noir" } },
  change_detection = { notify = false },

  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
  ui = {
    border = "rounded",
    icons = {
      cmd = "⌘", config = "🛠", event = "📅", ft = "📂",
      init = "⚙", keys = "🔑", plugin = "🔌", runtime = "💻",
      require = "🌙", source = "📄", start = "🚀", task = "📌",
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})
