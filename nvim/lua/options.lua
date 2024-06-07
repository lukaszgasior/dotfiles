vim.g.mapleader = " "
vim.g.netrw_banner = 0

local options = {
	smartindent = true,
	swapfile = false,
	tabstop = 2,
	softtabstop = 2,
	shiftwidth = 2,
	cursorline = true,
	relativenumber = true,
	encoding = 'utf-8',
	title = true,
	autoindent = true,
	incsearch = true,
	backup = false,
	showcmd = true,
	cmdheight = 1,
	laststatus = 2,
	expandtab = true,
	scrolloff = 10,
	inccommand = 'split',
	smarttab = true,
	wrap = false,
	backspace = { 'start', 'eol', 'indent' },
	hlsearch = false,
	number = true,
	mouse = 'a',
	clipboard = 'unnamedplus',
	breakindent = true,
	undofile = true,
	ignorecase = true,
	smartcase = true,
	signcolumn = 'yes',
	updatetime = 250,
	timeoutlen = 300,
	completeopt = 'menuone,noselect',
	termguicolors = true,
}

for k, v in pairs(options) do
	vim.opt[k] = v
end
