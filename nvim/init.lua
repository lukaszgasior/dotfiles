local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- set colorscheme
vim.cmd('let g:gruvbox_contrast_dark="hard"')
vim.cmd('set background=dark')
vim.cmd('colorscheme gruvbox')

require("options")
require("lazy").setup("plugins")
