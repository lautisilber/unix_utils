function nmap(new_cmd, old_cmd)
    vim.keymap.set("n", new_cmd, old_cmd, { noremap = true, silent = true })
end

function vmap(new_cmd, old_cmd)
    vim.keymap.set("v", new_cmd, old_cmd, { noremap = true, silent = true })
end
