require("lautisilber.utils")

-- pane movement
nmap("<leader>h", "<C-w>h", "pane movement: left") -- left
nmap("<leader>j", "<C-w>j", "pane movement: down") -- down
nmap("<leader>k", "<C-w>k", "pane movement: up") -- up
nmap("<leader>l", "<C-w>l", "pane movement: right") -- right

-- window creation
nmap("<leader>-", ":split<CR>", "window creation: horizontal")
nmap("<leader>|", ":vsplit<CR>", "window creation: vertical")

-- move selected lines
vmap("J", ":m '>+1<CR>gv=gv", "move selected lines: down")
vmap("K", ":m '<-2<CR>gv=gv", "move selected lines: up")
vmap("<S-Down>", ":m '>+1<CR>gv=gv", "move selected lines: down")
vmap("<S-Up>", ":m '<-2<CR>gv=gv", "move selected lines: up")

-- keep search in the middle
nmap("n", "nzzzv", "keep search in the middle: next")
nmap("N", "Nzzzv", "keep search in the middle: previous")

-- yank to clipboard
map({"n", "v"}, "<leader>y", [["+y]], "yank to clipboard")
nmap("<leader>Y", [["+Y]], "yank to clipboard")

-- search current word (where the cursor is) and replace
nmap("<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "search current word (where the cursor is) and replace")
