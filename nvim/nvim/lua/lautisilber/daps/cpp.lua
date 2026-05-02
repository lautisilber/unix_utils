require("lautisilber.utils")

local codelldb = FindExecutable({
    vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
    "codelldb",
})

local smart_debug_config = {
    type = "lldb",
    request = "launch",
    name = "Debug (remember last executable)",
    program = function()
        if vim.g.dap_last_program and vim.fn.executable(vim.g.dap_last_program) == 1 then
            local reuse = vim.fn.input("Use last program [" .. vim.g.dap_last_program .. "]? ([y]/n): ")
            if reuse == "y" or reuse == "Y" or reuse == "" then
                return vim.g.dap_last_program
            end
        end
        local path = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        vim.g.dap_last_program = path
        return path
    end,
}

if codelldb then
    require("dap-lldb").setup({
        codelldb_path = codelldb,
        configurations = {
            cpp = { smart_debug_config, },
            c = { smart_debug_config, },
        },
    })
end
