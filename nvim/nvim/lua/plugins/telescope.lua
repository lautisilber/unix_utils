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
        { "<C-t>", ":Telescope find_files<CR>", mode = "n", noremap = true, silent = true },
        -- { "<C-tg>", ":Telescope live_grep<CR>", mode = "n", noremap = true, silent = true },
        -- { "<C-tb>", ":Telescope buffers<CR>", mode = "n", noremap = true, silent = true },
    },
}
