require("lautisilber.utils")

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

if vim.fn.executable("lua-language-server") == 1 then
    table.insert(servers, "lua_ls")
    vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".git", ".luarc.json", ".luarc.jsonc" },
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT", -- Neovim uses LuaJIT
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true), -- makes it aware of Neovim's API and plugins
                    checkThirdParty = false, -- stops it asking to configure third party libraries
                },
                diagnostics = {
                    globals = { "vim" }, -- stops it complaining about the vim global
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    })
end


vim.lsp.enable(servers)

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local open_float = function()
            vim.diagnostic.open_float(nil, { focus = false })
        end

        nmap("gd", vim.lsp.buf.definition, "Go to Definition")
        nmap("gr", vim.lsp.buf.references, "Go to References")
        nmap("K", vim.lsp.buf.hover, "Hover Docs")
        nmap("ge", open_float, "Show diagnostic information")
        nmap("<leader>rn", vim.lsp.buf.rename, "Rename")
        --nmap("<leader>ca", vim.lsp.buf.code_action, "Code Action")


        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client then
            local chars = client.server_capabilities.completionProvider.triggerCharacters or {}
            -- add all lowercase, uppercase and underscore as trigger characters
            for byte = string.byte("a"), string.byte("z") do
                table.insert(chars, string.char(byte))
            end
            for byte = string.byte("A"), string.byte("Z") do
                table.insert(chars, string.char(byte))
            end
            table.insert(chars, "_")
            client.server_capabilities.completionProvider.triggerCharacters = chars
        end

        vim.lsp.completion.enable(true, event.data.client_id, event.buf, {
            autotrigger = true, --  When true, completion triggers automatically based on the server's triggerCharacters
        })


        vim.api.nvim_create_autocmd("CursorHold", {
            callback = open_float,
        })

        imap("<Tab>", function()
            if vim.fn.pumvisible() == 1 then
                return "<C-y>"  -- confirm selected completion
            end
            return "<Tab>"      -- otherwise insert a real tab
        end, "Choose code suggestion", { expr = true, buffer = event.buf })
        imap("<Esc>", function()
            if vim.fn.pumvisible() == 1 then
                return "<C-e>"  -- dismiss completion menu
            end
            return "<Esc>"
        end, "Dismiss code suggestions", { expr = true, buffer = event.buf })
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

vim.o.completeopt = "menu,menuone,noinsert" -- noinsert prevents nvim from automatically inserting the first match
