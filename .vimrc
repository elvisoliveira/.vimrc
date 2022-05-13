" Author: Elvis Oliveira - http://github.com/elvisoliveira "
function! AirlineInit()
    let g:airline_section_a = airline#section#create([])
    let g:airline_section_x = airline#section#create(['mode'])
    let g:airline_extensions = []
endfunc

function! IsWSL()
    " Check WSL
    if has("unix")
        let lines = readfile("/proc/version")
        if lines[0] =~ "Microsoft"
            return 1
        endif
    endif
    return 0
endfunc

function! GetSelectedText()
	normal gv"xy
	let reg = getreg("x")
	let reg = substitute(reg, '\', '\\\\', 'g')
	let reg = substitute(reg, '"', '\\"', 'g')
	normal gv
	return substitute(reg, '/', '\\/', 'g')
endfunc

function! SetXselClipboard()
    let text = GetSelectedText()
    for i in ["primary", "secondary", "clipboard"]
        execute printf('call system("xsel --%s --input", "%s")', i, text)
    endfor
endfunc

function! SetPath()
    " Only works inside NERDTree
    if(bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+')
        let nerd_root = g:NERDTreeFileNode.GetSelected().path.str()
        if strlen(nerd_root)
            echo nerd_root
            exec "cd " . nerd_root
        endif
    endif
endfunc

function! ToggleMouse()
    let &mouse = (&mouse == 'a') ? '' : 'a'
    let &ttymouse = (&ttymouse == 'sgr') ? '' : 'sgr'
endfunc

function! ToggleFileformat()
    if (&fileformat == "dos")
        set fileformat=mac
    elseif (&fileformat == "mac")
        set fileformat=unix
    else
        set fileformat=dos
    endif
endfunc

function! ToggleFileEncoding()
    if (&fileencoding == "utf-8")
        set fileencoding=latin1
    elseif (&fileencoding == "latin1")
        set fileencoding=cp1252
    else
        set fileencoding=utf-8
    endif
endfunc

function! BufferActions(action)
    let functional_buf_types = ['quickfix', 'help', 'nofile', 'terminal']

    if (bufname("%") == 'vimspector.Console' || 
                \ bufname("%") == 'vimspector.Output:stderr' || 
                \ bufname("%") == 'vimspector.Output:server')
        call feedkeys(":VimspectorShowOutput \<Tab>", 'tn')
    endif

    if (bufname("%") == 'NERD_tree_1' || 
                \ bufname("%") == '__Tagbar__.1' || 
                \ bufname("%") == '__LOTR__' || 
                \ bufname("%") == '[[buffergator-buffers]]' || 
                \ bufname("%") == 'vimspector.Console' || 
                \ bufname("%") == 'vimspector.Output:stderr' || 
                \ bufname("%") == 'vimspector.Output:server' || 
                \ bufname("%") == 'vimspector.Variables' || 
                \ bufname("%") == 'vimspector.Watches' || 
                \ bufname("%") == 'vimspector.StackTrace')
        return 0
    endif

    if (&buftype ==# 'quickfix')
        return 0
    endif

    if a:action == 'next'
        execute ':bnext'
        " if (&buftype ==# 'quickfix')
        if (index(functional_buf_types, &bt) >= 0)
            execute ':bnext'
        endif
    elseif a:action == 'previous'
        execute ':bprevious'
        " if (&buftype ==# 'quickfix')
        if (index(functional_buf_types, &bt) >= 0)
            execute ':bprevious'
        endif
    elseif a:action == 'close'
        execute ':Bdelete'
    elseif a:action == 'alternate'
        execute ':b#'
        if (index(functional_buf_types, &bt) >= 0)
            execute ':b#'
        endif
    endif
endfunc

" add line on cursor
set cursorline
set cursorcolumn

" Don't touch end of file
set nofixendofline

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
" set guifont=Fira\ Mono\ Medium:h10
set guifont=Fira\ Mono\ Medium\ 10

set guioptions-=r "remove right-hand scroll bar
set guioptions-=L "remove left-hand scroll bar

" Syntax Hightlight.
syntax enable

" colorscheme desert
" cd ~/.vim/colors
" curl -o molokai.vim https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim
colorscheme molokai

let g:rehash256 = 1

" Code on 130 columns
set colorcolumn=130

" Indent Setup
set tabstop=4
set shiftwidth=4
set expandtab

" Fold Settings
set foldmethod=indent
set nofoldenable

" Normalize backspace behavior
set backspace=indent,eol,start

" Show hybrid line numbers.
set number relativenumber

" Vundle requirements:
set nocompatible

" Share yank between vim instances
set clipboard=unnamedplus

filetype off
filetype plugin on
filetype plugin indent on

" Read .vimrc files of the file directory
set exrc
set secure

" Make Vim completion popup menu work just like in an IDE
set completeopt=menu,menuone,popup

" Vundle setup:
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
    Plugin 'VundleVim/Vundle.vim'
    Plugin 'godlygeek/tabular'
    Plugin 'itchyny/vim-cursorword'
    Plugin 'roxma/vim-paste-easy'
    Plugin 'moll/vim-bbye'
    Plugin 'christoomey/vim-tmux-navigator'
    Plugin 'scrooloose/nerdtree'
    Plugin 'vim-airline/vim-airline'
    Plugin 'vim-airline/vim-airline-themes'
    Plugin 'bling/vim-bufferline'
    Plugin 'szw/vim-maximizer'
    Plugin 'bkad/CamelCaseMotion'
    Plugin 'vim-scripts/AutoComplPop'
    Plugin 'jiangmiao/auto-pairs'
    " Git
    Plugin 'tpope/vim-fugitive'
    Plugin 'cohama/agit.vim'
    " IDE like plugins
    if (len(v:argv) > 2 && (v:argv[-2] =~ ".vimrc.ide" || v:argv[-2] =~ ".vimrc.java"))
        Plugin 'elvisoliveira/vim-lotr'
        Plugin 'preservim/tagbar'
        Plugin 'jeetsukumaran/vim-buffergator'
        Plugin 'Xuyuanp/nerdtree-git-plugin'
        Plugin 'ryanoasis/vim-devicons'
        Plugin 'airblade/vim-gitgutter'
        Plugin 'breuckelen/vim-resize'
        Plugin 'mhinz/vim-grepper'
        Plugin 'junegunn/fzf'
    endif
    " Only on Java [Eclipse] projects
    if (len(v:argv) > 2 && (v:argv[-2] =~ ".vimrc.java"))
        Plugin 'puremourning/vimspector'
        Plugin 'ycm-core/YouCompleteMe'
    endif
call vundle#end()

" Always show statusline.
set laststatus=2

" Use 256 colours.
set t_Co=256

" Show all hidden characters.
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<
if has("patch-7.4.710") | set listchars+=space:· | endif
set list

" Fix unsaved buffer warning when switching between them.
set hidden

" Wrap off
set wrap!

" ctrl-c for copy
if has("gui_running")
    vmap <C-c> "+y
elseif executable("xsel")
    vmap <C-c> :call SetXselClipboard()<CR><ESC>
elseif executable("pbcopy")
    vmap <C-c> :w !pbcopy<CR><CR>
elseif has("win64") || has("win32") || has("win16") || IsWSL()
    vmap <C-c> :w !clip.exe<CR><CR>
endif

" NERDtree
let g:NERDTreeMinimalUI=1
let g:NERDTreeShowLineNumbers=1
let g:NERDTreeWinSize=60
let g:NERDTreeRespectWildIgnore=1
let g:NERDTreeShowHidden=1
let g:NERDTreeChDirMode=2
let g:NERDTreeNodeDelimiter="\u00a0"

map <C-n> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>

" Buffer Control
map <C-k> :call BufferActions('next')<CR>
map <C-j> :call BufferActions('previous')<CR>
map <C-x> :call BufferActions('close')<CR>
map <C-h> :call BufferActions('alternate')<CR>

" Vim Bufferline
let g:bufferline_echo = 0

:command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'

" Show filepath.
noremap <F1> :echo resolve(expand('%:p'))<CR>

" Toggle wrap
noremap <F2> :set wrap!<CR>

" Mouse
" set mouse=a
" set ttymouse=sgr
noremap <F3> :call ToggleMouse()<CR>

" Set path on NERDTree
noremap <F4> :call SetPath()<CR>

" Remove empty lines
noremap <F5> :g/\v(^\s\t*$)/d<CR>

" Trim line endings
noremap <F6> :%s/\v(\s+$\|\t+$)//g<CR>

" Fuzzyfinder
noremap <F7> :call FZFOpen(':FZF')<CR>

" GREP
noremap <F8> :call FZFOpen(':Grepper -query')<CR>

" Open buffer on external editor
noremap <F9> :silent exec "!(geany % &) > /dev/null"<CR>

" Toggle BOM
noremap <F10> :set bomb!<CR>

" Toggle File Fomat
noremap <F11> :call ToggleFileformat()<CR>

" Toggle File Encode
noremap <F12> :call ToggleFileEncoding()<CR>

" Airline Theme
let g:airline_theme='luna'

" Fix indenting visual block
vmap < <gv
vmap > >gv

" Resize Buffer
let g:vim_resize_disable_auto_mappings = 1

nmap <C-Up>    : CmdResizeUp<CR>
nmap <C-Left>  : CmdResizeLeft<CR>
nmap <C-Down>  : CmdResizeDown<CR>
nmap <C-Right> : CmdResizeRight<CR>

nnoremap <C-u> 10k
nnoremap <C-d> 10j

nnoremap <PageUp> 10k
nnoremap <PageDown> 10j
nnoremap <Home> ^

" Ctrl + Arrow to skip words
execute "set <xUp>=\e[1;*A"
execute "set <xDown>=\e[1;*B"
execute "set <xRight>=\e[1;*C"
execute "set <xLeft>=\e[1;*D"

" Zoom
let g:maximizer_set_default_mapping = 0

map <C-z> :MaximizerToggle<CR>

" TMUX
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <C-b>h :TmuxNavigateLeft<CR>
nnoremap <silent> <C-b>j :TmuxNavigateDown<CR>
nnoremap <silent> <C-b>k :TmuxNavigateUp<CR>
nnoremap <silent> <C-b>l :TmuxNavigateRight<CR>
nnoremap <silent> <C-b>b :TmuxNavigatePrevious<CR>

map <C-l> :tabprevious<CR>
map <C-S-l> :tabnext<CR>

" Exit Vim if Buffergator / NERDtree / quickfix is the only window remaining in the only tab.
autocmd BufEnter * if winnr("$") == 1 &&
    \ (bufname() == "[[buffergator-buffers]]" || bufname() =~ "NERD_tree_\d\+" || &buftype ==# "quickfix") | quit | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname("#") =~ "NERD_tree_\d\+" && bufname("%") !~ "NERD_tree_\d\+" && winnr("$") > 1 |
	\ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute "buffer".buf | endif

" NERDTree Relative Numbers
autocmd FileType nerdtree setlocal relativenumber

" Open QUickfix itens with 'o' key
autocmd BufReadPost quickfix noremap <silent> <buffer> o <CR>

" AirLine
autocmd User AirlineAfterInit call AirlineInit()

map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
map <silent> ge <Plug>CamelCaseMotion_ge

sunmap w
sunmap b
sunmap e
sunmap ge

"" Omni Completion
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

if has("unix")
    inoremap <C-@> <c-x><c-o>
elseif has("win32")
    inoremap <C-Space> <c-x><c-o>
endif
