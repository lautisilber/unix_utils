Place the nvim directory in the ~/.config directory with

```bash
cp -r ./nvim "$HOME/.config"
```

Install neovim manually using

```bash
git clone https://github.com/neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=Release
make CMAKE_INSTALL_PREFIX="$HOME/local/nvim install"
```
