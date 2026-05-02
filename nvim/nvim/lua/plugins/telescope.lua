vim.api.nvim_create_user_command("TelescopeDeleteHistory", function()
    vim.fn.delete(vim.fn.expand("~/.local/share/nvim/telescope_history"))
    vim.notify("Telescope history deleted")
end, {})

return {
    'nvim-telescope/telescope.nvim',
    version = '*',
    lazy = true,
    cmd = "Telescope",
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    keys = {
        { "<leader>tf", ":Telescope find_files<CR>", mode = "n", noremap = true,
            silent = true, desc = "Open Telescope in find files mode" },
        { "<leader>tg", ":Telescope live_grep<CR>", mode = "n", noremap = true,
            silent = true, desc = "Open Telescope in live grep mode" },
        -- { "<C-tb>", ":Telescope buffers<CR>", mode = "n", noremap = true, silent = true },
    },
}
