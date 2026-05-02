-- Open nvim-tree if the argument passed to nvim is a directory
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function(event)
        if vim.fn.isdirectory(event.file) == 1 then
            require("nvim-tree.api").tree.open({ path = event.file })
        end
    end,
})
