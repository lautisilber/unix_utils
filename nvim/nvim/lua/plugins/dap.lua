return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        ft = { "python", "cpp", "c", "rust" },
        config = function()
            require("lautisilber.dap")
        end,
    },
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",  -- lazy load for python files only
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("lautisilber.daps.debugpy")
        end,
    },
    {
        "julianolf/nvim-dap-lldb",
        ft = { "c", "cpp", "rust" }, -- lazy load for c and cpp files only
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("lautisilber.daps.lldb")
        end,
    },
}
