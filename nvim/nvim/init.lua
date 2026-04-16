vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.termguicolors = true
vim.cmd("syntax on") -- ensure syntax on

vim.opt.colorcolumn = "80"

require("special_chars")

function map(new_cmd, old_cmd)
    vim.keymap.set("n", new_cmd, old_cmd, { noremap = true, silent = true })
end

-- pane movement
map("<leader>h", "<C-w>h") -- left
map("<leader>j", "<C-w>j") -- down
map("<leader>k", "<C-w>k") -- up
map("<leader>l", "<C-w>l") -- right

-- window creation
map("<leader>-", "<C-w>s")
map("<leader>|", "<C-w>v")

-- Set a tab to 4 spaces
vim.o.tabstop = 4       -- How many spaces a tab counts for
vim.o.softtabstop = 4   -- How many spaces a Tab key inserts in insert mode
vim.o.shiftwidth = 4    -- Number of spaces used for auto-indent
vim.o.expandtab = true  -- Use spaces instead of actual tab characters

require("config.lazy")
