require("utils")

-- pane movement
nmap("<leader>h", "<C-w>h") -- left
nmap("<leader>j", "<C-w>j") -- down
nmap("<leader>k", "<C-w>k") -- up
nmap("<leader>l", "<C-w>l") -- right

-- window creation
nmap("<leader>-", ":split<CR>")
nmap("<leader>|", ":vsplit<CR>")

-- move selected lines
vmap("J", ":m '>+1<CR>gv=gv")
vmap("K", ":m '<-2<CR>gv=gv")
vmap("<S-Down>", ":m '>+1<CR>gv=gv")
vmap("<S-Up>", ":m '<-2<CR>gv=gv")

-- keep search in the middle
nmap("n", "nzzzv")
nmap("N", "Nzzzv")

-- yank to clipboard
nmap("<leader>y", "\"+y")
vmap("<leader>y", "\"+y")

-- search current word (where the cursor is) and replace
nmap("<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
