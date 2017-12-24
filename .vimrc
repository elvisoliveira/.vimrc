""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author: Elvis Oliveira - http://github.com/elvisoliveira "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 0ms for key sequences.
set timeoutlen=1000 ttimeoutlen=0

" Syntax Hightlight.
syntax enable
colorscheme desert

" Convert tabs to spaces.
set tabstop=4 shiftwidth=4 expandtab

" Show line numbers.
set number relativenumber

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

" CtrlP Showing hidden files.
let g:ctrlp_show_hidden = 1
