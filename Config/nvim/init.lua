vim.g.mapleader = " "
vim.g.maplocalleader = " "

local disabled_built_ins = {
  "netrwPlugin",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
}
for _, plugin in ipairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

require("config.options")
require("config.keymaps")
require("config.lazy")
require("config.autocmds")
