vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.termguicolors = true
vim.cmd("syntax on") -- ensure syntax on

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

vim.opt.colorcolumn = "80"

vim.opt.incsearch  = true
vim.opt.scrolloff  = 8
vim.opt.updatetime = 1000 -- in ms

vim.opt.signcolumn = "no" -- off by default
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function (_)
        vim.api.nvim_set_option_value("signcolumn", "yes", { win = 0 })
    end
})
vim.api.nvim_create_autocmd("LspDetach", {
    callback = function(event)
        if #vim.lsp.get_clients({ bufnr = event.buf }) == 0 then
            vim.api.nvim_set_option_value("signcolumn", "no", { win = 0 })
        end
    end,
})

-- Set a tab to 4 spaces
vim.o.tabstop = 4      -- How many spaces a tab counts for
vim.o.softtabstop = 4  -- How many spaces a Tab key inserts in insert mode
vim.o.shiftwidth = 4   -- Number of spaces used for auto-indent
vim.o.expandtab = true -- Use spaces instead of actual tab characters

-- Enable break indent
vim.o.breakindent = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Show which line your cursor is on
vim.o.cursorline = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- fold code
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false      -- don't fold on file open
vim.opt.foldlevel = 99          -- start with everything unfolded
-- vim.opt.fillchars = { fold = " ", foldopen = "▾", foldclose = "▸" }
-- vim.opt.foldtext = ""
