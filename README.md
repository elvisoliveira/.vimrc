# ~/.vimrc
My Vim Setup.

```
ln -s (pwd)/.vimrc ~/.vimrc
```

## Neovim

Neovim does not read `~/.vimrc` by default. Create `~/.config/nvim/init.vim`
with:

```vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
```
