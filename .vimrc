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

function! SetXselClipboard()
    for i in ["primary", "secondary", "clipboard"]
        execute printf('call system("xsel --%s --input", "%s")', i, GetSelectedText())
    endfor
endfunction

function! SetPath()
    let nerd_root = g:NERDTreeFileNode.GetSelected().path.str()
	echo nerd_root
    if strlen(nerd_root)
        exec "cd ".nerd_root
    endif
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

function! ToggleFileformat()
    if (&fileformat == "dos")
        set fileformat=mac
    elseif (&fileformat == "mac")
        set fileformat=unix
    else
        set fileformat=dos
    endif
    echo "Fileformat: "
endfunction

function! ToggleFileEncoding()
    if (&fileencoding == "utf-8")
        set fileencoding=latin1
    elseif (&fileencoding == "latin1")
        set fileencoding=cp1252
    else
        set fileencoding=utf-8
    endif
endfunction

function! SidebarOpen()
	let b = bufnr("%")
	execute "BuffergatorOpen"
	wincmd l
	execute "TagbarOpen"
	execute (bufwinnr(b) . "wincmd w")
	execute ":set number!"
endfunction

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
" set guifont=Fira\ Mono\ Medium:h10
set guifont=Fira\ Mono\ Medium\ 10

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
" set expandtab

" Fold Settings
set foldmethod=indent
set nofoldenable

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
	Plugin 'scrooloose/nerdtree'
	Plugin 'bling/vim-bufferline'
	Plugin 'Xuyuanp/nerdtree-git-plugin'
	Plugin 'ryanoasis/vim-devicons'
	Plugin 'airblade/vim-gitgutter'
	" Plugin 'octref/RootIgnore'
	Plugin 'vim-airline/vim-airline'
	Plugin 'vim-airline/vim-airline-themes'
	Plugin 'godlygeek/tabular'
	Plugin 'itchyny/vim-cursorword'
	Plugin 'roxma/vim-paste-easy'
	Plugin 'jeetsukumaran/vim-buffergator'
	Plugin 'ycm-core/YouCompleteMe'
	Plugin 'preservim/tagbar'
	Plugin 't9md/vim-choosewin'
	Plugin 'breuckelen/vim-resize'
	Plugin 'tpope/vim-fugitive'
	Plugin 'mhinz/vim-startify'
	Plugin 'mhinz/vim-grepper'
	Plugin 'junegunn/fzf'
	Plugin 'christoomey/vim-tmux-navigator'
call vundle#end()

" Git Gutter
highlight GitGutterAdd    guifg=#009900 ctermfg=2
highlight GitGutterChange guifg=#bbbb00 ctermfg=3
highlight GitGutterDelete guifg=#ff2222 ctermfg=1

let g:gitgutter_enabled = 1
let g:gitgutter_map_keys = 0

" Always show statusline.
set laststatus=2

" Use 256 colours.
set t_Co=256

" Show all hidden characters.
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<
if has("patch-7.4.710") | set listchars+=space:· | endif
set list

" Disable automatic comment insertion.
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

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

" Tagbar
let g:tagbar_vertical = 25
let g:tagbar_compact = 1
let g:tagbar_autoshowtag = 1
let g:tagbar_iconchars = ['▸', '▾']
let g:tagbar_map_jump = 'o'
let g:tagbar_map_closeallfolds = ['_', 'zM',]
let g:tagbar_map_togglefold = ['<space>', 'za']

" NERDtree
let g:NERDTreeMinimalUI=1
let g:NERDTreeShowLineNumbers=1
let g:NERDTreeWinSize=60
let g:NERDTreeRespectWildIgnore=1
let g:NERDTreeShowHidden=1
let g:NERDTreeChDirMode=2

map <C-n> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>

" NERDTree Relative Numbers
autocmd FileType nerdtree setlocal relativenumber

" Buffergator
let g:buffergator_viewport_split_policy="R"
let g:buffergator_show_full_directory_path=0
let g:buffergator_autodismiss_on_select=0
let g:buffergator_autoupdate=1
let g:buffergator_show_full_directory_path="bufname"

"" Buffer Navigation
" Toggle left sidebar: NERDTree and BufferGator
au VimEnter * call SidebarOpen()

" Buffer Control
" map <C-b> :CtrlPBuffer<CR>
" map <C-o> :BuffergatorToggle<CR>

" map <C-k> :bnext<CR>
" map <C-j> :bprevious<CR>
" map <C-x> :bp!\|bd #<CR>
" map <C-h> :b#<CR>

map <C-k> :call BufferActions('next')<CR>
map <C-j> :call BufferActions('previous')<CR>
map <C-x> :call BufferActions('close')<CR>
map <C-h> :call BufferActions('alternate')<CR>

function! BufferActions(action)
	if bufname("%") =~ 'NERD_tree_'
		return 0
	endif
	if bufname("%") =~ 'Tagbar'
		return 0
	endif
	if bufname("%") =~ 'buffergator'
		return 0
	endif

	if a:action == 'next'
		execute ':bnext'
	elseif a:action == 'previous'
		execute ':bprevious'
	elseif a:action == 'close'
		execute ':bp!\|bd #'
	elseif a:action == 'alternate'
		execute ':b#'
	endif
endfunc

" Vim Bufferline
let g:bufferline_echo = 0

:command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'

" Show filepath.
noremap <F1> :echo resolve(expand('%:p'))<CR>

" Toggle wrap
noremap <F2> :set wrap!<CR>

" Toggle mouse
noremap <F3> :call ToggleMouse()<CR>

" Set path on NERDTree
noremap <F4> :call SetPath()<CR>

" Remove empty lines
noremap <F5> :g/\v(^\s\t*$)/d<CR>

" Trim line endings
noremap <F6> :%s/\v(\s+$\|\t+$)//g<CR>

" Fuzzyfinder
noremap <F7> :FZF<CR>

" GREP
noremap <F8> :Grepper -query<CR>

" Open buffer on external editor
noremap <F9> :silent exec "!(notepadpp % &) > /dev/null"<CR>

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

" Change buffer
nmap <C-Right> :CmdResizeRight<CR>
nmap <C-Left> :CmdResizeLeft<CR>
nmap <C-Up> :CmdResizeUp<CR>
nmap <C-Down> :CmdResizeDown<CR>

nnoremap <PageUp> 10k
nnoremap <PageDown> 10j
nnoremap <Home> ^

" Ctrl + Arrow to skip words
execute "set <xUp>=\e[1;*A"
execute "set <xDown>=\e[1;*B"
execute "set <xRight>=\e[1;*C"
execute "set <xLeft>=\e[1;*D"

" YCM
let g:ycm_auto_hover = -1
let g:ycm_key_list_select_completion = ['<TAB>']
let g:ycm_key_list_previous_completion = ['<Up>']
let g:ycm_key_list_next_completion = ['<Down>']

" Disable YCM at vim start
" let·g:loaded_youcompleteme·=·1

nmap <C-a>1 :YcmCompleter GoTo<CR>
nmap <C-a>2 :YcmShowDetailedDiagnostic<CR>
nmap <C-a>3 :YcmForceCompileAndDiagnostics<CR>
nmap <C-a>4 :YcmCompleter GoToReferences<CR>

" ChooseWin
set completeopt=menu,popup

let g:choosewin_label = '23456'
let g:choosewin_overlay_enable = 0
let g:choosewin_keymap   = {}
let g:choosewin_keymap.w = 'previous'

map <C-w><C-w> :ChooseWin<CR>

" When running large amounts of recorded actions, to improve performance use ":set lazyredraw"
let g:fzf_layout = { 'down': '40%' }

" Git Gutter
highlight GitGutterAdd          ctermfg=green  ctermbg=16 cterm=bold guifg=green  guibg=#000000 gui=bold
highlight GitGutterChange       ctermfg=yellow ctermbg=16 cterm=bold guifg=yellow guibg=#000000 gui=bold
highlight GitGutterDelete       ctermfg=red    ctermbg=16 cterm=bold guifg=red    guibg=#000000 gui=bold
highlight GitGutterChangeDelete ctermfg=yellow ctermbg=16 cterm=bold guifg=yellow guibg=#000000 gui=bold

let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <C-b>h :TmuxNavigateLeft<CR>
nnoremap <silent> <C-b>j :TmuxNavigateDown<CR>
nnoremap <silent> <C-b>k :TmuxNavigateUp<CR>
nnoremap <silent> <C-b>l :TmuxNavigateRight<CR>
" nnoremap <silent> <C-b>h :TmuxNavigatePrevious<CR>
