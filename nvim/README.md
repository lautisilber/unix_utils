Place the nvim directory in the ~/.config directory with

```bash
cp -r ./nvim "$HOME/.config"
```

Install neovim manually using

```bash
git clone https://github.com/neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$HOME/local/nvim"
make install
```

To install the LSPs do the following

1. ```clangd``` and optional ```clang-tidy```

Find a release of ```clangd``` in [this link](https://releases.llvm.org/download.html) and install it in your sistem, making shure that the ```clangd``` executable is in your ```PATH``` (adding the line ```PATH="$PATH:<path_to_the_clangd_directory>"``` to your bashrc). You can similarly add ```clang-tidy``` to add its functionality. (Note: the releases link will offer a link to a releases page in github)

2. ```pyright```

You can install ```pyright``` with ```pip install pyright```. You can look into ```pipx``` to install it instead of ```pip``` in case you'd rather have a universally available ```pyright``` that's not interpreter dependent.
Alternatively you could install it via npm with ```npm install -g pyright```

3. ```bashls```

For ```bashls``` you can run ```npm install -g bash-language-server```. Additionally, if you want to install ```shellckeck``` you can download the right release from [this link](https://github.com/koalaman/shellcheck/releases) like with ```clangd```
