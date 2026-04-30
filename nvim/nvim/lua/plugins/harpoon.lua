vim.api.nvim_create_user_command("HarpoonDeleteCache", function()
    local path = vim.fn.expand("~/.local/share/nvim/harpoon/")
    local files = vim.fn.glob(path .. "*.json", false, true)
    for _, file in ipairs(files) do
        vim.fn.delete(file)
    end
    vim.notify("Harpoon cache cleared")
end, {})

return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()
    end,
    keys = {
        { "<leader>bh", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon: Toggle menu", mode = "n", noremap = true, silent = true },
        { "<leader>ba", function() require("harpoon"):list():add() end, desc = "Harpoon: Add file", mode = "n", noremap = true, silent = true },
        { "<leader>b1", function() require("harpoon"):list():select(1) end, desc = "Harpoon: File 1", mode = "n", noremap = true, silent = true },
        { "<leader>b2", function() require("harpoon"):list():select(2) end, desc = "Harpoon: File 2", mode = "n", noremap = true, silent = true },
        { "<leader>b3", function() require("harpoon"):list():select(3) end, desc = "Harpoon: File 3", mode = "n", noremap = true, silent = true },
        { "<leader>b4", function() require("harpoon"):list():select(4) end, desc = "Harpoon: File 4", mode = "n", noremap = true, silent = true },
        { "<leader>b5", function() require("harpoon"):list():select(5) end, desc = "Harpoon: File 5", mode = "n", noremap = true, silent = true },
        { "<leader>b6", function() require("harpoon"):list():select(6) end, desc = "Harpoon: File 6", mode = "n", noremap = true, silent = true },
        { "<leader>b7", function() require("harpoon"):list():select(7) end, desc = "Harpoon: File 7", mode = "n", noremap = true, silent = true },
        { "<leader>b8", function() require("harpoon"):list():select(8) end, desc = "Harpoon: File 8", mode = "n", noremap = true, silent = true },
        { "<leader>b9", function() require("harpoon"):list():select(9) end, desc = "Harpoon: File 9", mode = "n", noremap = true, silent = true },
        { "<leader>b0", function() require("harpoon"):list():select(0) end, desc = "Harpoon: File 0", mode = "n", noremap = true, silent = true },
    },
}
