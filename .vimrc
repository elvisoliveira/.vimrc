""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author: Elvis Oliveira - http://github.com/elvisoliveira "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Syntax Hightlight.
syntax enable
colorscheme desert

" Show line numbers.
set number

" Vundle requirements:
set nocompatible

filetype off
filetype plugin indent on

" Vundle setup:
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'kien/ctrlp.vim'
call vundle#end()

" Set PowerLine plugin:
" Don't forget to create the symbolic link inside ~/.vim
" ln -s /path/to/site-packages ~/.vim/
set rtp+=~/.vim/site-packages/powerline/bindings/vim/

" Always show statusline.
set laststatus=2

" Use 256 colours. 
set t_Co=256

" Show all hidden characters.
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣
set list
