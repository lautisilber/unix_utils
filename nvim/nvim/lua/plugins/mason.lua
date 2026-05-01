return {
    "mason-org/mason.nvim",
    -- opts = {},
    config = function ()
        require("mason").setup()
        -- add lautisilber.lsp after mason has loaded the installed LSPs
        require("lautisilber.lsp")
    end
}
