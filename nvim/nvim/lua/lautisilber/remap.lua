require("lautisilber.utils")

-- pane movement
Nmap("<leader>h", "<C-w>h", "pane movement: left") -- left
Nmap("<leader>j", "<C-w>j", "pane movement: down") -- down
Nmap("<leader>k", "<C-w>k", "pane movement: up") -- up
Nmap("<leader>l", "<C-w>l", "pane movement: right") -- right

-- window creation
Nmap("<leader>-", ":split<CR>", "window creation: horizontal")
Nmap("<leader>|", ":vsplit<CR>", "window creation: vertical")

-- move selected lines
Vmap("J", ":m '>+1<CR>gv=gv", "move selected lines: down")
Vmap("K", ":m '<-2<CR>gv=gv", "move selected lines: up")
Vmap("<S-Down>", ":m '>+1<CR>gv=gv", "move selected lines: down")
Vmap("<S-Up>", ":m '<-2<CR>gv=gv", "move selected lines: up")

-- keep search in the middle
Nmap("n", "nzzzv", "keep search in the middle: next")
Nmap("N", "Nzzzv", "keep search in the middle: previous")

-- yank to clipboard
Map({"n", "v"}, "<leader>y", [["+y]], "yank to clipboard")
Nmap("<leader>Y", [["+Y]], "yank to clipboard")

-- search current word (where the cursor is) and replace
Nmap("<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    "search current word (where the cursor is) and replace")

-- make file executable
Nmap("<leader>x", "<cmd>!chmod +x %<CR>", "Make file executable")

-- toggle comment
Nmap("<leader>'", "gcc", "Toggle comment", { remap = true })
Vmap("<leader>'", "gc", "Toggle comment", { remap = true })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
Nmap("A<Esc>", "<cmd>nohlsearch<CR>", "Clear highlights on search when pressing <Esc>")

-- lazy.nvim
Nmap("<leader>p", ":Lazy<CR>", "Open Lazy")

-- mason
Nmap("<leader>o", ":Mason<CR>", "Open Lazy")

-- autocmd

-- Highlight when yanking (copying) text
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
})
