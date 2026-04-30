#!/usr/bin/env bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# sync nvim
NVIM_DIR="$HOME/.config/nvim"
THIS_NVIM_DIR="$THIS_DIR/nvim/nvim"

find "$THIS_NVIM_DIR" -type f -name "*.lua" | while read -r file; do
    machine_file="$NVIM_DIR${file#$THIS_NVIM_DIR}"
    machine_dir="$(dirname "$machine_file")"
    mkdir -p "$machine_dir"
    cp "$file" "$machine_dir"
done

# sync tmux
cp "$THIS_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

