#!/usr/bin/env bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# sync nvim
NVIM_DIR="$HOME/.config/nvim"

find "$NVIM_DIR" -type f -name "*.lua" | while read -r file; do
    #local_file="${file:$NVIM_DIR_LEN}"
    local_file="$THIS_DIR/nvim/nvim${file#"$NVIM_DIR"}"
    local_dir="$(dirname "$local_file")"
    mkdir -p "$local_dir"
    cp "$file" "$local_file"
done

# sync tmux

cp "$HOME/.tmux.conf" "$THIS_DIR/tmux/tmux.conf"

