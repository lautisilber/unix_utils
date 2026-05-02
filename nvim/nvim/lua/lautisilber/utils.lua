function Map(mode, new_cmd, old_cmd, desc, extra_opts)
    local extra = extra_opts or {}
    local opts = { noremap = true, silent = true, desc = desc }
    for k, v in pairs(extra) do opts[k] = v end
    vim.keymap.set(mode, new_cmd, old_cmd, opts)
end

function Nmap(new_cmd, old_cmd, desc, extra_opts)
    Map("n", new_cmd, old_cmd, desc, extra_opts)
end

function Vmap(new_cmd, old_cmd, desc, extra_opts)
    Map("v", new_cmd, old_cmd, desc, extra_opts)
end

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
--@param b any[]|nil Array of elems to append to a
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

-- Can return GNU/Linux, OSX or Windows
--@return str
function GetOS()
    -- ask LuaJIT first
    if jit then
        return jit.os
    end

    -- Unix, Linux variants
    local osname
    local fh, _ = assert(io.popen("uname -o 2>/dev/null","r"))
    if fh then
        osname = fh:read()
    end

    return osname or "Windows"
end
