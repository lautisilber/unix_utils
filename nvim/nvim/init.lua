vim.opt.number = true
vim.opt.relativenumber = true

-- pane movement
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true }) -- left
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true }) -- down
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true }) -- up
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true }) -- right

-- Set a tab to 4 spaces
vim.o.tabstop = 4       -- How many spaces a tab counts for
vim.o.softtabstop = 4   -- How many spaces a Tab key inserts in insert mode
vim.o.shiftwidth = 4    -- Number of spaces used for auto-indent
vim.o.expandtab = true  -- Use spaces instead of actual tab characters

require("config.lazy")
