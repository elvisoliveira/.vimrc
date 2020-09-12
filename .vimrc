""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author: Elvis Oliveira - http://github.com/elvisoliveira "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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

function! GetSelectedText()
    normal gv"xy
    let result = substitute(getreg("x"), '"', '\\"', 'g')
    normal gv
    return substitute(result, '/', '\\/', 'g')
endfunc

function! VimGrep()
    let search = input('Search: ', expand(GetSelectedText()))
    "    % Current document
    "  ./* Current dir files
    " ./** Current and child dir files
    let path = input('Path: ', '%')
    execute printf(':noautocmd vimgrep /%s/j %s', search, path)
    copen
endfunction

function! SetClipboard()
    for i in ["primary", "secondary", "clipboard"]
        execute printf('call system("xsel --%s --input", "%s")', i, GetSelectedText())
    endfor
endfunction

function! ToggleMouse()
    " check if mouse is enabled
    if &mouse == 'a'
        " disable mouse
        set mouse=
    else
        " enable mouse everywhere
        set mouse=a
    endif
endfunc

" Add line on cursor
set cursorline

noremap <C-g> :call VimGrep()<CR>

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
Plugin 'Xuyuanp/nerdtree-git-plugin'
" Plugin 'octref/RootIgnore'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'godlygeek/tabular'
Plugin 'itchyny/vim-cursorword'
Plugin 'prettier/vim-prettier'
Plugin 'roxma/vim-paste-easy'
Plugin 'mg979/vim-visual-multi'
" Vim Obsesion comes with windows-style line breaks
" it must be converted on ~/.vim/bundle/vim-obsession/plugin/obsession.vim
Plugin 'tpope/vim-obsession'
call vundle#end()

" Always show statusline.
set laststatus=2

" Use 256 colours. 
set t_Co=256

" Show all hidden characters.
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<
if has("patch-7.4.710") | set listchars+=space:· | endif
set list

" Disable automatic comment insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" CtrlP Showing hidden files.
let g:ctrlp_show_hidden = 1

" Fix unsaved buffer warning when switching between them.
set hidden

" ctrl-c for copy
if has("win64") || has("win32") || has("win16") || IsWSL()
    vmap <C-c> :w !clip.exe<CR><CR>
elseif executable("xsel")
    vmap <C-c> :call SetClipboard()<CR><ESC>
elseif executable("pbcopy")
    vmap <C-c> :w !pbcopy<CR><CR>
endif

" NERDtree
map <C-n> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>

" NERDTree Settings
let g:NERDTreeShowLineNumbers=1
let g:NERDTreeWinSize=60
let g:NERDTreeRespectWildIgnore=1
let g:NERDTreeShowHidden=1

" NERDTree Relative Numbers
autocmd FileType nerdtree setlocal relativenumber

" Buffer Control
" map <C-b> :CtrlPBuffer<CR>
map <C-k> :bnext<CR>
map <C-j> :bprevious<CR>
map <C-x> :bp!\|bd #<CR>

" Vim Bufferline
let g:bufferline_echo = 0

:command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'

" Show filepath.
noremap <F1> :echo resolve(expand('%:p'))<CR>

" Open buffer on external editor
noremap <F2> :silent exec "!(notepadpp % &) > /dev/null"<CR>

" Toggle wrap
noremap <F3> :set wrap!<CR>

" Toggle mouse
noremap <F4> :call ToggleMouse()<CR>

" Airline Theme
let g:airline_theme='luna'

" Fix indenting visual block
vmap < <gv
vmap > >gv

" Change buffer
" nmap <C-h> <C-w>h
" nmap <C-j> <C-w>j
" nmap <C-k> <C-w>k
" nmap <C-l> <C-w>l

" nmap <s-h> :vertical resize +1<CR>
" nmap <s-l> :vertical resize -1<CR>
" nmap <s-j> :resize +1<CR>
" nmap <s-k> :resize -1<CR>

nnoremap <PageUp> 10k
nnoremap <PageDown> 10j
nnoremap <Home> ^

let g:prettier#config#print_width = 9999

" Ctrl + Arrow to skip words
execute "set <xUp>=\e[1;*A"
execute "set <xDown>=\e[1;*B"
execute "set <xRight>=\e[1;*C"
execute "set <xLeft>=\e[1;*D"

let g:VM_maps = {}
let g:VM_maps["Select Cursor Down"] = '<S-A-Down>'      " start selecting down
let g:VM_maps["Select Cursor Up"]   = '<S-A-Up>'        " start selecting up
let g:VM_maps['Find Under']                  = ''
let g:VM_maps['Find Subword Under']          = ''
