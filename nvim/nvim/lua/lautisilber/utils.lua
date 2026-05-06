--@param mode string|string[]
--@param new_cmd string
--@param old_cmd string|func()
--@param desc string
--@param extra_opts vim.keymap.set.Opts?
function Map(mode, new_cmd, old_cmd, desc, extra_opts)
    local extra = extra_opts or {}
    local opts = { noremap = true, silent = true, desc = desc }
    for k, v in pairs(extra) do opts[k] = v end
    vim.keymap.set(mode, new_cmd, old_cmd, opts)
end

--@param new_cmd string
--@param old_cmd string|func()
--@param desc string
--@param extra_opts vim.keymap.set.Opts?
function Nmap(new_cmd, old_cmd, desc, extra_opts)
    Map("n", new_cmd, old_cmd, desc, extra_opts)
end

--@param new_cmd string
--@param old_cmd string|func()
--@param desc string
--@param extra_opts vim.keymap.set.Opts?
function Vmap(new_cmd, old_cmd, desc, extra_opts)
    Map("v", new_cmd, old_cmd, desc, extra_opts)
end

--@param new_cmd string
--@param old_cmd string|func()
--@param desc string
--@param extra_opts vim.keymap.set.Opts?
function Imap(new_cmd, old_cmd, desc, extra_opts)
    Map("i", new_cmd, old_cmd, desc, extra_opts)
end

function FindExecutable(paths)
    for _, path in ipairs(paths) do
        if vim.fn.executable(path) == 1 then
            return path
        end
    end
    return nil
end

-- Appends multiple elements to an array
--@param a any[] Array to append to
--@param b any[]? Array of elems to append to a
--@return any[]
-- function TableInsertMultiple(a, b)
--     if b == nil then
--         return a
--     end
--     for _, e in ipairs(b) do
--         table.insert(a, e)
--     end
--     return a
-- end

-- Can return macos, linux, windows
--@return str
function GetOS()
    local osname = ""

    -- ask LuaJIT first
    if jit then
        osname = jit.os
    else
        -- Unix, Linux variants
        local fh, _ = assert(io.popen("uname -o 2>/dev/null","r"))
        if fh then
            osname = fh:read()
        end
    end

    osname = string.lower(osname)
    if osname == "osx" or osname == "macos" or osname == "darwin" then
        return "macos"
    elseif string.find(osname, "linux") then
        return "linux"
    else
        return "windows"
    end
end

-- Returns true if val is contained in arr, false otherwise
--@param arr any[]
--@param val any
--@return boolean
function ArrayContains(arr, val)
    for _, v in ipairs(arr) do
        if v == val then
            return true
        end
    end
    return false
end

-- Runs a command
--@param cmd string[]
--@param on_error fun(vim.SystemCompleted)?
--@return vim.SystemCompleted
function RunCmdSync(cmd, on_error)
    local res = vim.system(cmd, { text = true }):wait()
    if on_error ~= nil and res.code ~= 0 then
        on_error(res)
    end
    return res
end

-- Gets the basename of a path
--@param path string
--@return string
function GetBasename(path)
    return path:match("^.+/(.+)$")
end

-- Get the system's c++ compiler. Returns its path
--@return string?
function GetCppCompilerPath()
    local os = GetOS()

    local function try_executables(execs)
        for _, comp in ipairs(execs) do
            if vim.fn.executable(comp) then
                return comp
            end
        end
        return nil
    end

    if os == "macos" then
        local compilers = { "clang++", "g++", "c++" }
        return try_executables(compilers)
    elseif os == "linux" then
        local compilers = { "g++", "clang++", "c++", "clang" }
        return try_executables(compilers)
    else
        vim.notify("Windows not supported", vim.log.levels.WARN)
        return nil
    end
end

-- Get the system's c++ compiler. Returns its path
--@return string?
function GetCCompilerPath()
    local os = GetOS()

    local function try_executables(execs)
        for _, comp in ipairs(execs) do
            if vim.fn.executable(comp) then
                return comp
            end
        end
        return nil
    end

    if os == "macos" then
        local compilers = { "clang", "gcc", "cc" }
        return try_executables(compilers)
    elseif os == "linux" then
        local compilers = { "gcc", "clang", "cc" }
        return try_executables(compilers)
    else
        vim.notify("Windows not supported", vim.log.levels.WARN)
        return nil
    end
end
