-- for python

require("lautisilber.utils")

local debugpy = FindExecutable({
    vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
    "debugpy",
})

if debugpy then
    require("dap-python").setup(debugpy)
end
