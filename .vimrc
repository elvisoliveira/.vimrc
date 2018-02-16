""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author: Elvis Oliveira - http://github.com/elvisoliveira "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set bash as default shell.
set shell=/bin/bash

" No Swap files.
set noswapfile

" Encoding
scriptencoding utf-8
set encoding=utf-8

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
Plugin 'Chiel92/vim-autoformat'
Plugin 'mattn/emmet-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'ryanoasis/vim-devicons'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'bling/vim-bufferline'
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
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:·
set list

" Turn off word wrap
set wrap!

" Disable automatic comment insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" CtrlP Showing hidden files.
let g:ctrlp_show_hidden = 1

" Clipboard Settings
set clipboard=unnamed

vmap <C-x> :!pbcopy<CR>       " ctrl-x for cut
vmap <C-c> :w !pbcopy<CR><CR> " ctrl-c for copy

" Autoformat
noremap <F1> :g/^$/d<CR>
noremap <F2> :Autoformat html<CR>
noremap <F3> :Autoformat css<CR>
noremap <F4> :Autoformat php<CR>

" NERDtree
map <C-n> :NERDTreeToggle<CR>

" enable line numbers
let NERDTreeShowLineNumbers=1

" Set NERDTree with
let g:NERDTreeWinSize=60

" make sure relative line numbers are used
autocmd FileType nerdtree setlocal relativenumber

" ControlP Buffer
map <C-b> :CtrlPBuffer<CR>
map <C-k> :bnext<CR>
map <C-j> :bprevious<CR>
