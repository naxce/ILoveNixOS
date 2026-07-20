local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes:1"
opt.termguicolors = true
opt.showmode = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.pumheight = 12
opt.splitright = true
opt.splitbelow = true
opt.laststatus = 3
opt.cmdheight = 1
opt.winminwidth = 5
opt.fillchars = { eob = " ", fold = " ", foldopen = "▶", foldsep = " ", foldclose = "▶" }

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.breakindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.timeoutlen = 400
opt.autoread = true

opt.hidden = true
opt.lazyredraw = false
opt.synmaxcol = 300
opt.redrawtime = 1500
opt.ttimeoutlen = 10
opt.updatecount = 100

vim.g.large_file_size = 1024 * 1024

opt.clipboard = "unnamedplus"
opt.mouse = "a"

opt.linebreak = true
opt.showbreak = "↳ "
opt.conceallevel = 2
opt.concealcursor = ""

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false
opt.foldlevel = 99

opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

opt.spelllang = { "en", "pl" }

vim.g.have_nerd_font = true
