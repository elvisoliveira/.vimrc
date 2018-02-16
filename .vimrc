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

" GUI Settings
set guifont=Fira\ Mono\ Medium:h10

set guioptions-=r "remove right-hand scroll bar
set guioptions-=L "remove left-hand scroll bar

" Syntax Hightlight.
syntax enable
colorscheme desert

" Indent Setup
set tabstop=4
set shiftwidth=4
set expandtab

" Fold Settings
let anyfold_activate=1
set foldlevel=0

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
Plugin 'vim-syntastic/syntastic'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'octref/RootIgnore'
Plugin 'vim-airline/vim-airline'
Plugin 'pseewald/vim-anyfold'
call vundle#end()

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

" NERDTree Settings
let g:NERDTreeShowLineNumbers=1
let g:NERDTreeWinSize=60
let g:NERDTreeRespectWildIgnore=1

" NERDTree Relative Numbers
autocmd FileType nerdtree setlocal relativenumber

" ControlP Buffer
map <C-b> :CtrlPBuffer<CR>
map <C-k> :bnext<CR>
map <C-j> :bprevious<CR>
map <C-x> :bp!\|bd #<CR>

" Syntastics Basic Settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Vim Bufferline
let g:bufferline_echo = 0
