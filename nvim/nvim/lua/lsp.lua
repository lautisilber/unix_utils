local servers = {}

if vim.fn.executable("clangd") == 1 then
    table.insert(servers, "clangd")
    vim.lsp.config("clangd", {
        filetypes = { "c", "cpp", "objc", "objcpp" },
        cmd = {
            "clangd",
            -- "--background-index",       -- index project in the background. Note that this can add significant overhead. The cached index is stored in ~/.cache/clangd/
            -- "--clang-tidy",             -- enable clang-tidy diagnostics. Needs clang-tidy to work
            "--header-insertion=never",    -- don't auto-insert headers
            "--completion-style=detailed", -- more verbose completion info
            "--offset-encoding=utf-16",    -- avoids a common warning with nvim
        },
    })
end

if vim.fn.executable("pyright-langserver") == 1 then
    table.insert(servers, "pyright")
    vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = "strict",   -- "off", "basic", or "strict"
                    autoSearchPaths = true,        -- search for packages in the workspace. Could add noticeable overhead
                    useLibraryCodeForTypes = true, -- infer types from library code
                    autoImportCompletions = true,  -- suggest auto imports
                },
            },
        },
    })
end

if vim.fn.executable("bash-language-server") == 1 then
    table.insert(servers, "bashls")
    vim.lsp.config("bashls", {
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh", "bash" },
        settings = {
            bashIde = {
                globPattern = "**/*@(.sh|.inc|.bash|.command)", -- file patterns to watch
            }
        }
    })
end

vim.lsp.enable(servers)

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        local open_float = function()
            vim.diagnostic.open_float(nil, { focus = false })
        end

        map("gd",         vim.lsp.buf.definition,  "Go to Definition")
        map("gr",         vim.lsp.buf.references,  "Go to References")
        map("K",          vim.lsp.buf.hover,       "Hover Docs")
        map("ge",         open_float,              "Show diagnostic information")
        map("<leader>rn", vim.lsp.buf.rename,      "Rename")
        --map("<leader>ca", vim.lsp.buf.code_action, "Code Action")

        vim.lsp.completion.enable(true, event.data.client_id, event.buf, {
            autotrigger = true, --  When true, completion triggers automatically based on the server's triggerCharacters
        })


        vim.api.nvim_create_autocmd("CursorHold", {
            callback = open_float,
        })
    end,
})

vim.diagnostic.config({
    virtual_text = true,       -- shows error inline at end of line
    signs = true,              -- keeps the E on the gutter
    underline = true,          -- underlines the problematic code
    update_in_insert = true,   -- don't show errors while typing
    float = {
        border = "rounded",
        source = true,         -- shows the language server that caused the error
    },
})


