return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        ft = { "python", "cpp", "c" },
        config = function()
            require("lautisilber.dap")
        end,
    },
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",  -- lazy load for python files only
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("lautisilber.daps.python")
        end,
    },
    {
        "julianolf/nvim-dap-lldb",
        ft = { "c", "cpp" }, -- lazy load for c and cpp files only
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("lautisilber.daps.cpp")
        end,
    },
}
