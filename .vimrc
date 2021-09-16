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
endfunction

function! SetPath()
    let nerd_root = g:NERDTreeFileNode.GetSelected().path.str()
	echo nerd_root
    if strlen(nerd_root)
        exec "cd ".nerd_root
    endif
endfunction

function! ToggleMouse()
    if &mouse == 'a'
        set mouse=
    else
        set mouse=a
    endif
    if &ttymouse == 'sgr'
        set ttymouse=
    else
        set ttymouse=sgr
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

function! RemoveDuplicateLines()
    let lines={}
    let result=[]
    for lineno in range(line('$'))
        let line=getline(lineno+1)
        if (!has_key(lines, line))
            let lines[line] = 1
            let result += [ line ]
        endif
    endfor
    %d
    call append(0, result)
    d
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

" Show hybrid line numbers.
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
	Plugin 'dansomething/vim-eclim'
	Plugin 'moll/vim-bbye'
	Plugin 'puremourning/vimspector'
	Plugin 'szw/vim-maximizer'
call vundle#end()

" Git Gutter
highlight GitGutterAdd          ctermfg=green  ctermbg=16 cterm=bold guifg=green  gui=bold
highlight GitGutterChange       ctermfg=yellow ctermbg=16 cterm=bold guifg=yellow gui=bold
highlight GitGutterDelete       ctermfg=red    ctermbg=16 cterm=bold guifg=red    gui=bold
highlight GitGutterChangeDelete ctermfg=yellow ctermbg=16 cterm=bold guifg=yellow gui=bold

let g:gitgutter_enabled = 1
let g:gitgutter_map_keys = 0
let g:gitgutter_grep_command = executable('rg') ? 'rg' : 'grep'

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
	if (bufname("%") == 'NERD_tree_1' || 
				\ bufname("%") == '__Tagbar__.1' || 
				\ bufname("%") == '[[buffergator-buffers]]' || 
				\ bufname("%") == 'vimspector.Console' || 
				\ bufname("%") == 'vimspector.Output:stderr' || 
				\ bufname("%") == 'vimspector.Variables' || 
				\ bufname("%") == 'vimspector.Watches' || 
				\ bufname("%") == 'vimspector.Variables' || 
				\ bufname("%") == 'vimspector.StackTrace')
		return 0
	endif

	if a:action == 'next'
		execute ':bnext'
	elseif a:action == 'previous'
		execute ':bprevious'
	elseif a:action == 'close'
		execute ':Bdelete'
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
noremap <F7> :FZF<CR>

" GREP
noremap <F8> :Grepper -query<CR>

" Open buffer on external editor
" noremap <F9> :silent exec "!(notepadpp % &) > /dev/null"<CR>
noremap <F9> :call RemoveDuplicateLines()<CR>

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

" YCM
let g:ycm_auto_hover = -1
let g:ycm_key_list_select_completion = ['<TAB>']
let g:ycm_key_list_previous_completion = ['<Up>']
let g:ycm_key_list_next_completion = ['<Down>']
let g:ycm_java_jdtls_extension_path = ['/home/elvisoliveira/.vim/bundle/vimspector/gadgets/linux']
let g:ycm_filetype_whitelist = { 'java': 1 }
let g:ycm_filetype_blacklist = { '*': 1 }

" Disable YCM at vim start
" let·g:loaded_youcompleteme·=·1

" YCM + Vimspector
" To check the state of the debugger, use :YcmDebugInfo

nmap <C-a>1 :YcmCompleter GoTo<CR>
nmap <C-a>2 :YcmShowDetailedDiagnostic<CR>
nmap <C-a>3 :YcmForceCompileAndDiagnostics<CR>
nmap <C-a>4 :YcmCompleter GoToReferences<CR>

" Zoom
let g:maximizer_set_default_mapping = 0

map <C-z> :MaximizerToggle<CR>

" ChooseWin
set completeopt=menu,popup

let g:choosewin_label = '23456'
let g:choosewin_overlay_enable = 0
let g:choosewin_keymap = {}
let g:choosewin_keymap.w = 'previous'

map <C-w><C-w> :ChooseWin<CR>

" When running large amounts of recorded actions, to improve performance use ":set lazyredraw"
let g:fzf_layout = { 'down': '40%' }

" TMUX
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <C-b>h :TmuxNavigateLeft<CR>
nnoremap <silent> <C-b>j :TmuxNavigateDown<CR>
nnoremap <silent> <C-b>k :TmuxNavigateUp<CR>
nnoremap <silent> <C-b>l :TmuxNavigateRight<CR>
nnoremap <silent> <C-b>b :TmuxNavigatePrevious<CR>

let s:jdt_ls_debugger_port = 0
function! s:StartJavaDebugging()
	if s:jdt_ls_debugger_port <= 0
		" Get the DAP port
		let s:jdt_ls_debugger_port = youcompleteme#GetCommandResponse('ExecuteCommand', 'vscode.java.startDebugSession')
		if s:jdt_ls_debugger_port == ''
			echom "Unable to get DAP port - is JDT.LS initialized?"
			let s:jdt_ls_debugger_port = 0
			return
		else
			echom "Assigned port is: " . s:jdt_ls_debugger_port
			let $DEBUGGER = s:jdt_ls_debugger_port
		endif
	endif
	" Start debugging with the DAP port
	call vimspector#LaunchWithSettings({'DAPPort': s:jdt_ls_debugger_port})
endfunction

function! ToggleBreakpoint()
	let alreadyHasBreakpoint1 = len(sign_getplaced(bufnr(), #{group:'VimspectorBP', lnum: line(".")})[0].signs) > 0
	let alreadyHasBreakpoint2 = len(sign_getplaced(bufnr(), #{group:'VimspectorCode', lnum: line(".")})[0].signs) > 0
	if alreadyHasBreakpoint1 || alreadyHasBreakpoint2
		call vimspector#ToggleBreakpoint()
	else
		let condition = input('condition:')
		if condition == ''
			call vimspector#ToggleBreakpoint()
		else
			call vimspector#ToggleBreakpoint({'condition': condition})
		endif
		redraw
	endif
endfunction

" Leader + S = Vim[S]pector
nmap <C-s>j :call <SID>StartJavaDebugging()<CR>
nmap <C-s>c :call vimspector#Continue()<CR>
nmap <C-s>s :call vimspector#Stop()<CR>
" VimpectorRestart
" VimspectorPause
nmap <C-s>b :call ToggleBreakpoint()<CR>
nmap <C-s>r :call vimspector#Reset()<CR>
" VimspectorToggleConditionalBreakpoint
" VimspectorAddFunctionBreakpoint
" VimspectorRunToCursor
nmap <C-s> <Right> :call vimspector#StepOver()<CR>
nmap <C-s> <Down> :call vimspector#StepInto()<CR>
nmap <C-s> <Up> :call vimspector#StepOut()<CR>
" VimspectorUpFrame
" VimspectorDownFrame
xmap <C-s>i <Plug>VimspectorBalloonEval

let g:vimspector_sign_priority = {
\    'vimspectorBP':         999,
\    'vimspectorPC':         999,
\    'vimspectorBPCond':     999,
\    'vimspectorBPDisabled': 999,
\ }

let $FZF_DEFAULT_COMMAND = 'rg --files --hidden'

map <C-l> :tabprevious<CR>
map <C-S-l> :tabnext<CR>

" Resize panes on Vim window resize
augroup equalalways_resized
  autocmd!
  autocmd VimResized *
        \ if &equalalways | wincmd = | endif
augroup END

" Share yank between vim instances
set clipboard=unnamedplus

" Exit Vim if Buffergator is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && bufname() == "[[buffergator-buffers]]" | quit | endif
