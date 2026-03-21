-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {}

    -- Automatically close Neovim if NvimTree is the last window
    vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
            local wins = vim.api.nvim_tabpage_list_wins(0)
            if #wins == 1 and vim.bo[vim.api.nvim_win_get_buf(wins[1])].filetype == "NvimTree" then
                vim.cmd("quit")
            end
        end,
    })
  end,
  keys = {
    { "<leader>f", ":NvimTreeToggle<CR>", mode = "n", noremap = true, silent = true }
  },
}
