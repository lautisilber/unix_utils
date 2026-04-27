vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        -- "--background-index",       -- index project in the background. Note that this can add significant overhead. The cached index is stored in ~/.cache/clangd/
        -- "--clang-tidy",             -- enable clang-tidy diagnostics. Needs clang-tidy to work
        "--header-insertion=never",    -- don't auto-insert headers
        "--completion-style=detailed", -- more verbose completion info
        "--offset-encoding=utf-16",    -- avoids a common warning with nvim
    },
})

vim.lsp.config("pyright", {
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

vim.lsp.config("bashls", {
    settings = {
        bashIde = {
            globPattern = "**/*@(.sh|.inc|.bash|.command)", -- file patterns to watch
        }
    }
})

vim.lsp.enable({"clangd", "pyright", "bashls"})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("gd",         vim.lsp.buf.definition,  "Go to Definition")
    map("gr",         vim.lsp.buf.references,   "Go to References")
    map("K",          vim.lsp.buf.hover,        "Hover Docs")
    map("<leader>rn", vim.lsp.buf.rename,       "Rename")
    map("<leader>ca", vim.lsp.buf.code_action,  "Code Action")
  end,
})
