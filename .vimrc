" Author: Elvis Oliveira - http://github.com/elvisoliveira "
let s:enabled = 0
function! RightSidebarToggle()
    let b = bufnr("%")
    if s:enabled
        let s:enabled = 0
        execute "BuffergatorClose"
    else
        let s:enabled = 1
        execute "BuffergatorOpen"
    endif
    execute (bufwinnr(b) . "wincmd w")
    wincmd =
endfunc

function! AirlineInit()
    let g:airline_section_c = airline#section#create(['%f'])
endfunc

let s:functional_buf_types = ['quickfix', 'help', 'nofile', 'terminal']

" See: https://github.com/junegunn/fzf/issues/453
function! FZFOpen(cmd)
    if winnr('$') > 1 && (index(s:functional_buf_types, &bt) >= 0)
        let norm_wins = filter(range(1, winnr('$')), 'index(s:functional_buf_types, getbufvar(winbufnr(v:val), "&bt")) == -1')
        let norm_win = !empty(norm_wins) ? norm_wins[0] : 0
        exe norm_win . 'winc w'
    endif
    exe a:cmd
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
    if (has('ttymouse'))
        let &ttymouse = (&ttymouse == 'sgr') ? '' : 'sgr'
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

    if (&buftype ==# 'nofile' || &buftype ==# 'quickfix' || &buftype ==# 'terminal')
        return 0
    endif

    if a:action == 'next'
        execute ':bnext'
        if (index(s:functional_buf_types, &bt) >= 0)
            execute ':bnext'
        endif
    elseif a:action == 'previous'
        execute ':bprevious'
        if (index(s:functional_buf_types, &bt) >= 0)
            execute ':bprevious'
        endif
    elseif a:action == 'close'
        execute ':Bdelete!'
    elseif a:action == 'alternate'
        execute ':b#'
        if (index(s:functional_buf_types, &bt) >= 0)
            execute ':b#'
        endif
    endif
endfunc

" add line on cursor
set cursorline
set cursorcolumn

set autoindent

" Don't touch EOL of end of file
set nofixeol

" Remove EOL of end of file
set noeol

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
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed "OSX
else
  set clipboard=unnamedplus "Linux
endif

filetype off
filetype plugin on
filetype plugin indent on

" Read .vimrc files of the file directory
set exrc
set secure

" Make Vim completion popup menu work just like in an IDE
set completeopt=menu,menuone,noselect

" Plugins
call plug#begin('~/.vim/plugged')
    Plug 'godlygeek/tabular'
    Plug 'itchyny/vim-cursorword'
    Plug 'roxma/vim-paste-easy'
    Plug 'moll/vim-bbye'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'mg979/vim-visual-multi'
    Plug 'chaoren/vim-wordmotion'
    Plug 'editorconfig/editorconfig-vim'
    Plug 'khaveesh/vim-fish-syntax'

    " Plug 'dense-analysis/ale'
    " Plug 'hrsh7th/vim-vsnip'

    " Git
    Plug 'tpope/vim-fugitive'
    Plug 'rhysd/git-messenger.vim'

    " Plug 'airblade/vim-gitgutter'
    Plug 'lewis6991/gitsigns.nvim'

    Plug 'dracula/vim', { 'as': 'dracula' }
    " Plug 'dylanaraps/wal.vim'

    " Sidebar
    Plug 'scrooloose/nerdtree'
    Plug 'Xuyuanp/nerdtree-git-plugin'
    Plug 'ryanoasis/vim-devicons' " Must load after Nerdtree

    " Autocomplete
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    " Neovim excl. plugins
    if has('nvim')
        Plug 'neovim/nvim-lspconfig'
        Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
        Plug 'nvim-treesitter/nvim-treesitter-context'
        Plug 'nvim-lua/plenary.nvim' " telescope requirement
        Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.x' }
        Plug 'fannheyward/telescope-coc.nvim'
    else
        Plug 'jeetsukumaran/vim-buffergator'
        Plug 'junegunn/fzf'
        Plug 'mhinz/vim-grepper'
    endif

    " IDE like plugins
    if (len(v:argv) > 2 && (v:argv[-2] =~ ".vimrc.ide" || v:argv[-2] =~ ".vimrc.java"))
        Plug 'elvisoliveira/vim-lotr'
        Plug 'preservim/tagbar'
        Plug 'breuckelen/vim-resize'
    endif

    " Only on Java [Eclipse] projects
    if (len(v:argv) > 2 && (v:argv[-2] =~ ".vimrc.java"))
        Plug 'puremourning/vimspector'
        Plug 'ycm-core/YouCompleteMe'
    endif
call plug#end()

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

" Buffergator
let g:buffergator_viewport_split_policy="R"
let g:buffergator_show_full_directory_path=0
let g:buffergator_autodismiss_on_select=0
let g:buffergator_autoupdate=1
let g:buffergator_show_full_directory_path="bufname"

map <C-n> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>

" Buffer Control
nnoremap <C-k> :call BufferActions('next')<CR>
nnoremap <C-j> :call BufferActions('previous')<CR>
nnoremap <C-x> :call BufferActions('close')<CR>
nnoremap <C-h> :call BufferActions('alternate')<CR>

" map <C-g> :ALEGoToDefinition<CR>
map <C-g> :Telescope coc definitions

" Vim Bufferline
let g:bufferline_echo = 0

:command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'

" Show filepath.
noremap <F1> :echo resolve(expand('%:p'))<CR>

" Toggle wrap
noremap <F2> :set wrap!<CR>

" Mouse
set mouse=
if (has('ttymouse'))
    set ttymouse=
endif
noremap <F3> :call ToggleMouse()<CR>

" Set path on NERDTree
noremap <F4> :call SetPath()<CR>

" Remove empty lines
noremap <F5> :g/\v(^\s\t*$)/d<CR>

" Trim line endings
noremap <F6> :%s/\v(\s+$\|\t+$)//g<CR>

" Fuzzyfinder
" GREP
if has('nvim')
    noremap <F7> <CMD>Telescope find_files<CR>
    noremap <F8> <CMD>Telescope live_grep<CR>
    if has("unix")
        nnoremap <C-Space> <CMD>Telescope buffers<CR>
    elseif has("win32")
        nnoremap <C-@> <CMD>Telescope buffers<CR>
    endif
else
    noremap <F7> :call FZFOpen(':FZF')<CR>
    noremap <F8> :call FZFOpen(':Grepper -query')<CR>
    if has("unix")
        nnoremap <C-Space> :call RightSidebarToggle()<CR>
    elseif has("win32")
        nnoremap <C-@> :call RightSidebarToggle()<CR>
    endif
endif

" Open buffer on external editor
noremap <F9> :silent exec "!(scite % &) > /dev/null"<CR>

" Toggle BOM
noremap <F10> :set bomb!<CR>

" Toggle File Fomat
noremap <F11> :call ToggleFileformat()<CR>

" Toggle File Encode
noremap <F12> :call ToggleFileEncoding()<CR>

let g:ale_linters = { 'php': ['php', 'psalm', 'cspell'], 'vue': ['vue', 'eslint', 'vls', 'jshint', 'jscs', 'cspell', 'standard'] }
let g:ale_linters_explicit = 1
let g:ale_lint_on_save = 0
let g:ale_lint_on_insert_leave = 1
let g:ale_open_list = 0
let g:ale_keep_list_window_open = 0
let g:ale_completion_enabled = 0
let g:ale_disable_lsp = 1

let g:airline_left_sep = ''
let g:airline_right_sep = ''

" Airline Theme
" let g:airline_theme='luna'
let g:airline_theme='dracula'

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#fnametruncate = 0
let g:airline#extensions#tabline#fnamecollapse = 2
let g:airline#extensions#tabline#fnamemod = ':t'

let g:airline#extensions#coc#enabled = 1

let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ' '
let g:airline#extensions#tabline#right_alt_sep = ''

let g:airline#extensions#tabline#buffer_idx_mode = 1

let g:webdevicons_enable_airline_tabline = 0

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

nnoremap <silent> <Tab> :

" TMUX
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <C-w>h :TmuxNavigateLeft<CR>
nnoremap <silent> <C-w>j :TmuxNavigateDown<CR>
nnoremap <silent> <C-w>k :TmuxNavigateUp<CR>
nnoremap <silent> <C-w>l :TmuxNavigateRight<CR>
nnoremap <silent> <C-w>b :TmuxNavigatePrevious<CR>

map <C-l> :tabprevious<CR>
map <C-S-l> :tabnext<CR>

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname("#") =~ "NERD_tree_\d\+" && bufname("%") !~ "NERD_tree_\d\+" && winnr("$") > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute "buffer".buf | endif

" NERDTree Relative Numbers
autocmd FileType nerdtree setlocal relativenumber

" Open Quickfix itens with 'o' key
autocmd BufReadPost quickfix noremap <silent> <buffer> o <CR>

" AirLine
autocmd User AirlineAfterInit call AirlineInit()

if !has("gui_running")
    hi Normal guibg=NONE ctermbg=NONE
endif

nnoremap <ESC> :nohlsearch<CR>

"" Omni Completion
" autocmd   FileType   python       set   omnifunc=pythoncomplete#Complete
" autocmd   FileType   javascript   set   omnifunc=javascriptcomplete#CompleteJS
" autocmd   FileType   html         set   omnifunc=htmlcomplete#CompleteTags
" autocmd   FileType   css          set   omnifunc=csscomplete#CompleteCSS
" autocmd   FileType   xml          set   omnifunc=xmlcomplete#CompleteTags
" autocmd   FileType   php          set   omnifunc=ale#completion#OmniFunc
" autocmd   FileType   c            set   omnifunc=ccomplete#Complete

autocmd FileType * setlocal autoindent

if exists('g:plugs["coc.nvim"]')
    inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
    inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

    inoremap <expr> <C-j> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
    inoremap <expr> <C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

    inoremap <expr> <Esc> coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"

    inoremap <expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

    hi CocSearch ctermfg=12 guifg=#18A3FF
    hi CocMenuSel ctermbg=108 guibg=#13354A 
else
    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
endif

if has("unix")
    inoremap <silent><expr> <c-Space> coc#refresh()
elseif has("win32")
    inoremap <C-@> <c-x><c-o>
endif

" vim-visual-multi
let g:VM_maps = {}
let g:VM_maps['Find Under'] = ''

" cd ~/.vim/colors
" curl -o molokai.vim https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim
" colorscheme molokai
" colorscheme desert
" colorscheme wal

highlight TelescopePromptTitle guifg=#1b1f27 guibg=#e06c75
highlight TelescopePromptPrefix guifg=#e06c75
highlight TelescopePromptNormal guibg=#252931
highlight TelescopePromptBorder guifg=#252931 guibg=#252931

highlight TelescopeResultsNormal guibg=#1b1f27
highlight TelescopeResultsBorder guifg=#1b1f27 guibg=#1b1f27

highlight TelescopePreviewTitle guifg=#1b1f27 guibg=#98c379
highlight TelescopePreviewNormal guibg=#252931
highlight TelescopePreviewBorder guifg=#252931 guibg=#252931

highlight TelescopeSelection guifg=#B0BEC5 guibg=#252931

lua <<EOF
if vim.fn.has('nvim') == 1 then
    require'nvim-treesitter.configs'.setup {
        ensure_installed = {"javascript", "html", "css", "php", "vim", "vue", "json", "python", "lua"},
        sync_install = false,
        ignore_install = {},
        highlight = {
            enable = true,
            disable = {},
            additional_vim_regex_highlighting = false
        }
    }

    require'treesitter-context'.setup{
        enable = true,
        max_lines = 0,
        patterns = {
            -- default = {'class', 'function', 'foreach', 'method', 'while', 'if', 'switch', 'case' }
        },
        zindex = 20,
        mode = 'topline'
    }

    require('gitsigns').setup {
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = true,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 0,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>'
    }

    require("telescope").setup({
        extensions = {
            coc = {
                prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
            }
        },
    })
    require('telescope').load_extension('coc')

    -- require'lspconfig'.phpactor.setup{}
    -- require'lspconfig'.psalm.setup{
    --     cmd = {"psalm", "--language-server"}
    -- }
    -- require'lspconfig'.eslint.setup {}
    -- require'lspconfig'.tsserver.setup{}
    -- require'lspconfig'.vimls.setup{}

    -- Disable LSP inline messages
    vim.diagnostic.config({
        virtual_text = false
    })
end
EOF