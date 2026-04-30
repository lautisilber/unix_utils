vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.termguicolors = true
vim.cmd("syntax on") -- ensure syntax on

vim.opt.colorcolumn = "80"

vim.opt.incsearch  = true
vim.opt.scrolloff  = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 1000 -- in ms

-- Set a tab to 4 spaces
vim.o.tabstop = 4      -- How many spaces a tab counts for
vim.o.softtabstop = 4  -- How many spaces a Tab key inserts in insert mode
vim.o.shiftwidth = 4   -- Number of spaces used for auto-indent
vim.o.expandtab = true -- Use spaces instead of actual tab characters
