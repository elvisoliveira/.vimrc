# .vimrc
My (neo)vim setup.

Neovim loads it through `~/.config/nvim/init.vim`:

```vim
source ~/.config/nvim/vimrc
```

with `~/.config/nvim/vimrc` a symlink to this repo's `.vimrc`. Plugins are
managed by vim-plug and install into `~/.local/share/nvim/plugged`; there is no
`~/.vimrc` or `~/.vim`.
