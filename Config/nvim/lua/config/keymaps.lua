local map = vim.keymap.set
local silent = { silent = true }

map("i", "jk", "<Esc>", silent)
map("n", "<Esc>", "<cmd>nohlsearch<CR>", silent)
map("n", "x", '"_x', silent)

map("v", "<", "<gv", silent)
map("v", ">", ">gv", silent)

map("v", "J", ":m '>+1<CR>gv=gv", silent)
map("v", "K", ":m '<-2<CR>gv=gv", silent)

map("v", "p", '"_dP', silent)

map("n", "<C-h>", "<C-w>h", silent)
map("n", "<C-j>", "<C-w>j", silent)
map("n", "<C-k>", "<C-w>k", silent)
map("n", "<C-l>", "<C-w>l", silent)

map("n", "<C-Up>", "<cmd>resize +2<CR>", silent)
map("n", "<C-Down>", "<cmd>resize -2<CR>", silent)
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", silent)
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", silent)

map("n", "<S-h>", "<cmd>bprevious<CR>", silent)
map("n", "<S-l>", "<cmd>bnext<CR>", silent)
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Zamknij bufor", silent = true })

map("n", "<C-d>", "<C-d>zz", silent)
map("n", "<C-u>", "<C-u>zz", silent)
map("n", "n", "nzzzv", silent)
map("n", "N", "Nzzzv", silent)

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Zapisz plik", silent = true })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Zamknij okno", silent = true })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Wyjdź bez zapisu", silent = true })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Poprzedni błąd/warning" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Następny błąd/warning" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Pokaż diagnostykę w linii" })
map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diagnostyka -> loclist" })

map("n", "<leader>tt", "<cmd>botright split | resize 15 | terminal<CR>i", { desc = "Terminal na dole" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", silent)
