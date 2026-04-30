function map(mode, new_cmd, old_cmd, desc, extra_opts)
    local extra = extra_opts or {}
    local opts = { noremap = true, silent = true, desc = desc }
    for k, v in pairs(extra) do opts[k] = v end
    vim.keymap.set(mode, new_cmd, old_cmd, opts)
end

function nmap(new_cmd, old_cmd, desc, extra_opts)
    map("n", new_cmd, old_cmd, desc, extra_opts)
end

function vmap(new_cmd, old_cmd, desc, extra_opts)
    map("v", new_cmd, old_cmd, desc, extra_opts)
end

function imap(new_cmd, old_cmd, desc, extra_opts)
    map("i", new_cmd, old_cmd, desc, extra_opts)
end
