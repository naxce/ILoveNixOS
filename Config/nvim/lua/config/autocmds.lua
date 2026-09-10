local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd("BufReadPost", {
	group = augroup("restore-cursor", { clear = true }),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

autocmd("TextYankPost", {
	group = augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
})

autocmd("BufWritePre", {
	group = augroup("trim-whitespace", { clear = true }),
	pattern = "*",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		pcall(function()
			vim.cmd([[%s/\s\+$//e]])
		end)
		vim.fn.setpos(".", save_cursor)
	end,
})

autocmd("BufReadPre", {
	group = augroup("big-file-detection", { clear = true }),
	callback = function(args)
		local ok, stats = pcall(function()
			return vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
		end)
		if ok and stats and stats.size > vim.g.large_file_size then
			vim.b[args.buf].large_file = true
			vim.opt_local.eventignore:append("FileType")
			vim.opt_local.undofile = false
			vim.opt_local.swapfile = false
			vim.opt_local.foldmethod = "manual"
			vim.opt_local.spell = false
			vim.notify("Duży plik — część funkcji (treesitter/undofile) wyłączona.", vim.log.levels.WARN)
		end
	end,
})

autocmd("VimEnter", {
	group = augroup("auto-root", { clear = true }),
	callback = function()
		local start_dir = vim.fn.getcwd()
		if start_dir == "" or vim.fn.isdirectory(start_dir) == 0 then
			return
		end

		local git_dir = vim.fn.finddir(".git", start_dir .. ";")
		if git_dir == "" then
			return
		end

		local root = vim.fn.fnamemodify(git_dir, ":h")
		if root == "" or vim.fn.isdirectory(root) == 0 then
			return
		end

		local ok = pcall(vim.cmd.cd, vim.fn.fnameescape(root))
		if not ok then
			vim.notify("auto-root: nie udało się przełączyć cwd na " .. root, vim.log.levels.WARN)
		end
	end,
})

autocmd({ "WinEnter", "BufEnter" }, {
	group = augroup("cursorline-active-win", { clear = true }),
	callback = function()
		vim.opt_local.cursorline = true
	end,
})
autocmd({ "WinLeave", "BufLeave" }, {
	group = augroup("cursorline-inactive-win", { clear = true }),
	callback = function()
		vim.opt_local.cursorline = false
	end,
})

autocmd("FileType", {
	group = augroup("close-with-q", { clear = true }),
	pattern = {
		"help",
		"qf",
		"lspinfo",
		"man",
		"notify",
		"checkhealth",
		"trouble",
		"startuptime",
	},
	callback = function(args)
		vim.bo[args.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true })
	end,
})
