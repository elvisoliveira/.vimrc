# ~/.vimrc
My Vim Setup.

```
ln -s (pwd)/.vimrc ~/.vimrc
ln -s (pwd)/.vimrc.ide ~/.vimrc.ide
ln -s (pwd)/.vimrc.java ~/.vimrc.java
```

To open an IDE styled vim:

```
vi -u ~/.vimrc.ide FILE
```

## Neovim

Neovim does not read `~/.vimrc` by default. Create `~/.config/nvim/init.vim`
with:

```vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
```
