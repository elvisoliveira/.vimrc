""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author: Elvis Oliveira - http://github.com/elvisoliveira "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Add line on cursor
set cursorline

" Set bash as default shell.
if !has('win32')
    set shell=/bin/bash
endif

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

" Code on 130 columns
set colorcolumn=130

" Indent Setup
set tabstop=4
set shiftwidth=4
set expandtab

" Fold Settings
let anyfold_activate=1
set foldlevel=0

" Normalize backspace behavior
set backspace=indent,eol,start

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
Plugin 'scrooloose/nerdtree'
Plugin 'ryanoasis/vim-devicons'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'bling/vim-bufferline'
Plugin 'vim-syntastic/syntastic'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'octref/RootIgnore'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'godlygeek/tabular'
Plugin 'itchyny/vim-cursorword'
call vundle#end()

" Always show statusline.
set laststatus=2

" Use 256 colours. 
set t_Co=256

" Show all hidden characters.
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<
if has("patch-7.4.710") | set listchars+=space:· | endif
set list

" Turn off word wrap
" set wrap!

" Disable automatic comment insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" CtrlP Showing hidden files.
let g:ctrlp_show_hidden = 1

" Clipboard Settings
set clipboard=unnamed

" Fix unsaved buffer warning when switching between them.
set hidden

" ctrl-x for cut
" ctrl-c for copy
if has("win64") || has("win32") || has("win16") || IsWSL()
    vmap <C-x> :!clip.exe<CR>
    vmap <C-c> :w !clip.exe<CR><CR>
else
    vmap <C-x> :!pbcopy<CR>
    vmap <C-c> :w !pbcopy<CR><CR>
endif

" NERDtree
map <C-n> :NERDTreeToggle<CR>
map <C-r> :NERDTreeFind<CR>

" NERDTree Settings
let g:NERDTreeShowLineNumbers=1
let g:NERDTreeWinSize=60
let g:NERDTreeRespectWildIgnore=1
let g:NERDTreeShowHidden=1

" NERDTree Relative Numbers
autocmd FileType nerdtree setlocal relativenumber

" Buffer Control
map <C-b> :CtrlPBuffer<CR>
map <C-k> :bnext<CR>
map <C-j> :bprevious<CR>
map <C-x> :bp!\|bd #<CR>

" Syntastics Basic Settings
if !has('win32')
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
endif

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Vim Bufferline
let g:bufferline_echo = 0

" Show filepath.
noremap <F1> :echo resolve(expand('%:p'))<CR>

" Airline Theme
let g:airline_theme='luna'

" Check WSL
function! IsWSL()
	if has("unix")
		let lines = readfile("/proc/version")
		if lines[0] =~ "Microsoft"
			return 1
		endif
	endif
	return 0
endfunction
