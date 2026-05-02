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

## Telescope

To be able to use the live grep functionality of ```Telescope``` install ```ripgrep``` on your system. Installation instructions can be found [here](https://github.com/BurntSushi/ripgrep#installation)

## LSPs

### Install using Mason

You can use ```Mason``` to install any LSP you want. If you have any LSP already installed, ```clangd``` for example, you can use that instead of installing it via ```Mason```. Here's a list of all the currently supported LSPs

- ```clangd``` for ```c```, ```cpp```, ```Objective-C``` and ```Objective-C++```
- ```pyright``` for ```python```
- ```bash-language-server``` for ```sh``` and ```bash``` (Recommended to also install ```shellcheck```)
- ```lua-language-server``` for ```lua```
- ```gopls``` for ```go```
- ```texlab``` for ```tex``` and ```latex```

### Install manually

To install the LSPs manually do the following

1. ```clangd``` and optional ```clang-tidy```

You can install these packages with ```sudo apt install clangd clang-tidy``` or the alternative for ```apt``` in your system.

If you can't install packages with a package manager then find a release of ```clangd``` in [this link](https://releases.llvm.org/download.html) and install it in your sistem, making shure that the ```clangd``` executable is in your ```PATH``` (adding the line ```PATH="$PATH:<path_to_the_clangd_directory>"``` to your bashrc). You can similarly add ```clang-tidy``` to add its functionality. (Note: the releases link will offer a link to a releases page in github).

If clangd can't find headers, a possible solution is the following. Read the output of the command ```gcc --print-file-name=include``` and create the file ```~/.config/clangd/config.yaml```

```yaml
CompileFlags:
  Add:
    - -isystem<result of the command gcc --print-file-name=include>
```

This will let ```clangd``` know that that that path can be used to look for system headers

2. ```pyright```

You can install ```pyright``` with ```pip install pyright```. You can look into ```pipx``` to install it instead of ```pip``` in case you'd rather have a universally available ```pyright``` that's not interpreter dependent.
Alternatively you could install it via npm with ```npm install -g pyright```

3. ```bashls```

For ```bashls``` you can run ```npm install -g bash-language-server```. Additionally, if you want to install ```shellckeck``` you can download the right release from [this link](https://github.com/koalaman/shellcheck/releases) like with ```clangd```

## DAP

DAPs allow us to use debuggers. The following are supported (and can be installed via ```Mason```)

- ```codelldb``` for ```c``` and ```cpp```
- ```debugpy``` for ```python```
