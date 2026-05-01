vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.termguicolors = true
vim.cmd("syntax on") -- ensure syntax on

vim.opt.colorcolumn = "80"

vim.opt.incsearch  = true
vim.opt.scrolloff  = 8
vim.opt.updatetime = 1000 -- in ms

vim.opt.signcolumn = "no" -- off by default
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function (event)
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
