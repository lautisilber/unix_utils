require("lautisilber.utils")

-- grammars that don't follow the standard single-grammar layout
local special_grammars = {
    typescript = {
        url = "https://github.com/tree-sitter/tree-sitter-typescript",
        grammars = {
            {
                subpath = "typescript",
                name = "typescript",
            },
            {
                subpath = "tsx",
                name = "tsx",
            }
        },
    },
    markdown = {
        url = "https://github.com/tree-sitter-grammars/tree-sitter-markdown",
        grammars = {
            {
                subpath = "tree-sitter-markdown-inline",
                name = "markdown_inline",
            },
            {
                subpath = "tree-sitter-markdown",
                name = "markdown",
            }
        },
    },
}

-- grammars that have special urls but don't need a full 'special_grammars' entry
local special_urls = {
}

-- grammars that are already preinstalled in nvim's bundled tree-sitter
local bundled_parsers = {
    "c",
    "lua",
    "markdown",
    "vimscript",
    "vimdoc",
    "query", -- tree-sitter query files
}

local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
-- Gets the path to where the grammar.so should be for a given language
--@param lang string
--@return string
local function get_lang_grammar_so(lang)
    return parser_dir .. "/" .. lang .. ".so"
end

-- Clones a git repo to a temporary file
--@param url string
--@param temp string
--@return boolean
local function clone_git_repo(url, tmp)
    vim.notify("TSInstall: cloning " .. url, vim.log.levels.INFO)

    local res = RunCmdSync({ "git", "clone", "--depth=1", url, tmp })
    if res.code ~= 0 then
        vim.notify("TSInstall: couldn't clone git repository \"" .. url .. "\" with error: " .. res.stderr)
        return false
    end
    return true
end

-- Gets a list of .so file paths corresponding to a language
--@param lang string
--@return string[]
local function get_so_files_for_lang(lang)
    local paths = {}

    local function name2path(name)
        return parser_dir .. "/" .. get_lang_grammar_so(name) .. ".so"
    end

    if special_grammars[lang] ~= nil then
        for _, grammar in ipairs(special_grammars[lang]["grammars"]) do
            table.insert(paths, name2path(grammar["name"]))
        end
    else
        table.insert(paths, name2path(lang))
    end

    return paths
end

-- Check if file exists
--@param path string
--@return boolean
local function file_exists(path)
    -- vim.fn.findfile returns a string (or a string array) if files are found
    -- otherwise it returns an empty string
    local ret = vim.fn.findfile(path)
    return ret ~= ""
end

-- Make sure path exists
--@param path string
local function ensure_directory(path)
    local ret = vim.fn.finddir(path)
    if ret == path then
        return
    end
    vim.fn.mkdir(path, "-p")
end

-- Checks if language is installed (if strict is true, all associated files
-- need to be present for the program to be considered installed
--@param lang string
--@param strict boolean
--@param err_prefix string?
--@return bool
local function ts_is_installed(lang, strict)
    local paths = get_so_files_for_lang(lang)
    print(paths[1])

    local count = 0
    for _, path in ipairs(paths) do
        if file_exists(path) then
            count = count + 1;
            if strict then
                return true
            end
        end
    end

    if strict and count == #paths then
        return true
    end

    return false
end

-- Builds the grammar
--@param repo_path string
--@param lang string
--@param subpath string?
--@param name string?
--@return boolean
local function _ts_install(repo_path, lang, subpath, name)
    if subpath == nil then
        vim.notify("TSInstall: installing " .. lang .. " (" .. repo_path .. ")", vim.log.levels.INFO)
    else
        vim.notify("TSInstall: installing " .. lang .. " - " .. subpath .. " (" .. repo_path .. ")", vim.log.levels.INFO)
    end

    local src = repo_path .. (subpath and ("/" .. subpath) or "") .. "/src"
    local out = get_lang_grammar_so(name and name or lang)

    -- collect all .c files
    local sources = {}
    local c_scanner = vim.uv.fs_stat(src .. "/scanner.c")
    local cc_scanner = vim.uv.fs_stat(src .. "/scanner.cc")
    table.insert(sources, src .. "/parser.c")
    if c_scanner then table.insert(sources, src .. "/scanner.c") end

    local c_comp = GetCCompilerPath()
    if c_comp == nil then
        vim.notify("Couldn't find a c compiler", vim.log.levels.ERROR)
        return false
    end

    local function on_compile_error(vim_system_completed)
        local code = vim_system_completed.code
        local stderr = vim_system_completed.stderr
        vim.notify("TSInstall: couldn't finish compile step with code " .. code .. " and error: " .. stderr, vim.log.levels.ERROR)
    end

    local parser_o = repo_path .. "/parser.o"
    local scanner_o = repo_path .. "/scanner.o"

    if cc_scanner then
        -- C++ scanner: compile parser.c and scanner.cc separately, then link


        local cpp_comp = GetCppCompilerPath()
        if cpp_comp == nil then
            vim.notify("Couldn't find a c++ compiler", vim.log.levels.ERROR)
            return false
        end

        if RunCmdSync({ c_comp, "-fPIC", "-O3", "-c", src .. "/parser.c", "-I" .. src, "-o", parser_o }, on_compile_error).code ~= 0 then
            print({ c_comp, "-fPIC", "-O3", "-c", src .. "/parser.c", "-I" .. src, "-o", parser_o })
            return false
        end
        if RunCmdSync({ cpp_comp, "-fPIC", "-O3", "-c", src .. "/scanner.cc", "-I" .. src, "-o", scanner_o }, on_compile_error).code ~= 0 then
            print({ cpp_comp, "-fPIC", "-O3", "-c", src .. "/scanner.cc", "-I" .. src, "-o", scanner_o })
            return false
        end
        if RunCmdSync({ cpp_comp, "-shared", "-fPIC", "-O3", "-o", out, parser_o, scanner_o, "-lstdc++" }, on_compile_error).code ~= 0 then
            print({ cpp_comp, "-shared", "-fPIC", "-O3", "-o", out, parser_o, scanner_o, "-lstdc++" })
            return false
        end

    else
        -- pure C grammar
        if RunCmdSync({ c_comp, "-shared", "-fPIC", "-O3", "-o", out, "-I" .. src, src .. "/parser.c", src .. "/scanner.c" }, on_compile_error).code ~= 0 then
            local cmd = { c_comp, "-shared", "-fPIC", "-O3", "-o", out, "-I" .. src, src .. "/parser.c", src .. "/scanner.c" }
            for _, v in ipairs(cmd) do
                print(v)
            end
            return false
        end
    end

    vim.notify("TSInstall: installed " .. lang, vim.log.levels.INFO)
    return true

end


local function ts_install(lang)
    ensure_directory(parser_dir)

    -- from here on, we can't crash, since we need to remove the tmp file
    local tmp = vim.fn.tempname()
    local ok, err = pcall(function ()
        local special = special_grammars[lang]
        if special == nil then
            local url
            if special_urls[lang] ~= nil then
                url = special_urls[lang]
            else
                url = "https://github.com/tree-sitter/tree-sitter-" .. lang
            end
            if clone_git_repo(url, tmp) then
                _ts_install(tmp, lang, nil)
            end
        else
            local url = special["url"]
            local grammars = special["grammars"]
            if clone_git_repo(url, tmp) then
                for _, grammar in ipairs(grammars) do
                    local subpath = grammar["subpath"]
                    local name = grammar["name"]
                    _ts_install(tmp, lang .. "-" .. subpath:gsub("/", ""), subpath, name)
                end
            end
        end
    end)

    vim.fn.delete(tmp, "rf")

    if not ok then
        vim.notify("TSInstall: Unexpected error: " .. err, vim.log.levels.ERROR)
    end
end

local function ts_uninstall(lang)
    local paths = {}

    if special_grammars[lang] ~= nil then
        for _, grammar in ipairs(special_grammars[lang]["grammars"]) do
            table.insert(paths, get_lang_grammar_so(grammar["name"]))
        end
    else
        table.insert(paths, get_lang_grammar_so(lang))
    end

    for _, path in ipairs(paths) do
        local _lang = GetBasename(path):match("(.+)%.")
        local stat = vim.uv.fs_stat(path)
        if stat == nil then
            vim.notify("TSUninstall: grammar '" .. _lang .. "' is not installed", vim.log.levels.WARN)
            return
        end
        local ok, err = vim.uv.fs_unlink(path)
        if not ok then
            vim.notify("TSUninstall: couldn't uninstall '" .. _lang .. "' with error: " .. (err or "unknown"), vim.log.levels.ERROR)
            return
        end
        vim.notify("TSUninstall: uninstalled " .. _lang, vim.log.levels.INFO)
    end
end

local function ts_update_single(lang)
    if not ts_is_installed(lang, false) then
        vim.notify("TSUpdate: '" .. lang .. "' isn't installed", vim.log.levels.WARN)
        return
    end

    ts_uninstall(lang)
    ts_install(lang)
end

local function ts_update_all()
    local special_names = {}
    for lang, special_grammar in pairs(special_grammars) do
        for _, grammar in ipairs(special_grammar["grammars"]) do
            local name = grammar["name"]
            special_names[name] = lang
        end
    end

    local so_files = vim.fn.glob(parser_dir .. "/*.so", false, true)
    if #so_files == 0 then
        vim.notify("TSUpdate: no languages installed", vim.log.levels.WARN)
        return
    end
    for _, so_file in ipairs(so_files) do
        print(so_file)
        local name = GetBasename(so_file):match("(.+)%.")
        print(name)
        local lang = (special_names[name] ~= nil and special_names[name] or name)

        ts_update_single(lang)
    end
end

vim.api.nvim_create_user_command("TSInstall", function(opts)
    local lang = opts.args:lower()
    ts_install(lang)
end, { nargs = 1 })

vim.api.nvim_create_user_command("TSUninstall", function(opts)
    local lang = opts.args:lower()
    ts_uninstall(lang)
end, { nargs = 1 })

vim.api.nvim_create_user_command("TSUpdate", function(opts)
    if opts.count == 0 then
        ts_update_all()
    elseif opts.count == 1 then
        local lang = opts.args:lower()
        ts_update_single(lang)
    else
        vim.notify("TSUpdate: Argument count needs to  be 0 or 1", vim.log.levels.ERROR)
    end
end, { nargs = "?" })
