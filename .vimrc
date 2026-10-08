" Author: Elvis Oliveira - http://github.com/elvisoliveira "
let g:elvis_vimrc_loaded = 1
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
    " Check WSL. /proc/version exists on Linux (including WSL) but not on
    " macOS, so guard the read or readfile() errors on Darwin.
    if has("unix") && filereadable("/proc/version")
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
    normal gv
    return reg
endfunc

function! CopyToClipboard(text)
    call setreg('+', a:text)
    call setreg('*', a:text)

    " On TTY there is no system clipboard; route to tmux's paste buffer instead.
    if empty($DISPLAY) && empty($WAYLAND_DISPLAY) && !empty($TMUX) && executable('tmux')
        call system('tmux load-buffer -', a:text)
        return
    endif

    if has('clipboard')
        return
    endif

    let is_wayland = !empty($WAYLAND_DISPLAY) || !empty($XDG_SESSION_TYPE) && $XDG_SESSION_TYPE ==# 'wayland'

    if is_wayland && executable('wl-copy')
        " Wayland exposes clipboard and primary selection, but not secondary.
        call system('wl-copy', a:text)
        call system('wl-copy --primary', a:text)
        return
    endif

    if executable('pbcopy')
        call system('pbcopy', a:text)
        return
    endif

    if IsWSL() && executable('clip.exe')
        call system('clip.exe', a:text)
        return
    endif

    if executable('xsel')
        for selection in ['primary', 'secondary', 'clipboard']
            call system('xsel --' . selection . ' --input', a:text)
        endfor
        return
    endif

    if executable('xclip')
        for selection in ['primary', 'secondary', 'clipboard']
            call system('xclip -in -selection ' . selection, a:text)
        endfor
        return
    endif

    echoerr 'No clipboard tool found. Install wl-clipboard, xsel, xclip, pbcopy or clip.exe.'
endfunc

function! SetXselClipboard()
    call CopyToClipboard(GetSelectedText())
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

function! CopyCurrentBufferPath(use_visual)
    let path = fnamemodify(expand('%:p'), ':.')

    if empty(path)
        echoerr 'Current buffer has no file path.'
        return
    endif

    if a:use_visual
        let start = line("'<")
        let end = line("'>")
        if start > end
            let [start, end] = [end, start]
        endif
    else
        let start = line('.')
        let end = start
    endif

    let reference = path . ':' . start
    if end != start
        let reference .= '-' . end
    endif

    call CopyToClipboard(reference)
    echo reference
endfunc

function! CopyCurrentProjectPath()
    let path = fnamemodify(getcwd(), ':p')
    call CopyToClipboard(path)
    echo path
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

function! s:IsPluginBuffer()
    let l:name = bufname('%')
    return l:name =~# '^NERD_tree_'
        \ || l:name =~# '^NvimTree_'
        \ || l:name =~# '^__Tagbar__'
        \ || l:name ==# '__LOTR__'
        \ || l:name ==# '[[buffergator-buffers]]'
        \ || l:name =~# '^vimspector\.'
endfunc

function! s:IsFunctionalBuffer()
    return index(s:functional_buf_types, &buftype) >= 0 || s:IsPluginBuffer()
endfunc

function! s:SkipFunctional(cmd)
    " Step past consecutive functional buffers, capped to avoid infinite loops
    " when every listed buffer is functional.
    let l:start = bufnr('%')
    let l:tries = 0
    while s:IsFunctionalBuffer() && l:tries < 20
        execute a:cmd
        if bufnr('%') == l:start
            break
        endif
        let l:tries += 1
    endwhile
endfunc

function! BufferActions(action)
    if bufname('%') =~# '^vimspector\.\(Console\|Output:\)'
        call feedkeys(":VimspectorShowOutput \<Tab>", 'tn')
        return 0
    endif

    if s:IsFunctionalBuffer()
        return 0
    endif

    if a:action == 'next'
        execute ':bnext'
        call s:SkipFunctional(':bnext')
    elseif a:action == 'previous'
        execute ':bprevious'
        call s:SkipFunctional(':bprevious')
    elseif a:action == 'close'
        execute ':Bdelete!'
        call s:SkipFunctional(':bnext')
    elseif a:action == 'alternate'
        execute ':b#'
        call s:SkipFunctional(':bnext')
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

filetype plugin indent on

" Read .vimrc files of the file directory
set exrc
set secure

" Make Vim completion popup menu work just like in an IDE
set completeopt=menu,menuone,noselect

" Load gitignored local secrets (API keys, etc.) if present.
" resolve() dereferences the symlink (~/.vimrc -> ~/.env/.vimrc/.vimrc) so the
" lookup happens next to the real file, not next to the symlink.
let s:secrets_file = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/.vimrc.secrets'
if filereadable(s:secrets_file)
    execute 'source ' . fnameescape(s:secrets_file)
endif

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
    Plug 'tpope/vim-sleuth'
    Plug 'khaveesh/vim-fish-syntax'
    Plug 'stevearc/stickybuf.nvim'
    Plug 'digitaltoad/vim-pug'

    " Plug 'dense-analysis/ale'
    " Plug 'hrsh7th/vim-vsnip'

    " Git
    Plug 'tpope/vim-fugitive'
    Plug 'rhysd/git-messenger.vim'

    " Plug 'airblade/vim-gitgutter'
    Plug 'lewis6991/gitsigns.nvim'

    if has('nvim')
        Plug 'EdenEast/nightfox.nvim'
    else
        Plug 'dracula/vim', { 'as': 'dracula' }
    endif
    " Plug 'dylanaraps/wal.vim'

    " Sidebar: nvim-tree on Neovim, NERDTree on plain Vim
    if !has('nvim')
        Plug 'scrooloose/nerdtree'
        Plug 'Xuyuanp/nerdtree-git-plugin'
        Plug 'ryanoasis/vim-devicons' " Must load after Nerdtree
    endif

    " Neovim excl. plugins
    if has('nvim')
        Plug 'neovim/nvim-lspconfig'
        Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
        " Plug 'nvim-treesitter/nvim-treesitter-context'
        Plug 'nvim-lua/plenary.nvim' " telescope requirement
        Plug 'nvim-telescope/telescope.nvim', { 'tag': 'v0.1.9' }
        Plug 'echasnovski/mini.completion'
        Plug 'akinsho/toggleterm.nvim', { 'tag': 'v2.13.1' }
        Plug 'folke/which-key.nvim'
        Plug 'nvim-tree/nvim-web-devicons'
        Plug 'nvim-tree/nvim-tree.lua'
    else
        Plug 'jeetsukumaran/vim-buffergator'
        Plug 'junegunn/fzf'
        Plug 'mhinz/vim-grepper'
    endif

    " Optional IDE profile plugins. The extra mappings/config live in ~/.vimrc.ide.
    Plug 'elvisoliveira/vim-lotr'
    Plug 'preservim/tagbar'
    Plug 'breuckelen/vim-resize'

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

if has('nvim') && has('termguicolors')
    set termguicolors
endif

" Show all hidden characters.
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<
if has("patch-7.4.710") | set listchars+=space:· | endif
set list

" Fix unsaved buffer warning when switching between them.
set hidden

" Wrap off
set nowrap

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

nnoremap <silent> <C-c> :call CopyToClipboard(expand('<cword>'))<CR>

" NERDtree
let g:NERDTreeMinimalUI=1
let g:NERDTreeShowLineNumbers=1
let g:NERDTreeWinSize=60
let g:NERDTreeRespectWildIgnore=1
let g:NERDTreeShowHidden=1
let g:NERDTreeChDirMode=2
let g:NERDTreeNodeDelimiter="\u00a0"
let g:NERDTreeIgnore = ['\.profraw$']

" Buffergator
let g:buffergator_viewport_split_policy="R"
let g:buffergator_show_full_directory_path=0
let g:buffergator_autodismiss_on_select=0
let g:buffergator_autoupdate=1
let g:buffergator_show_full_directory_path="bufname"

if has('nvim')
    map <C-n> <CMD>NvimTreeToggle<CR>
    map <C-f> <CMD>NvimTreeFindFile<CR>
else
    map <C-n> :NERDTreeToggle<CR>
    map <C-f> :NERDTreeFind<CR>
endif

" <C-p> (mnemonic: Preview) opens the current file in Firefox. Defined
" globally rather than via a FileType autocmd: at startup the command-line
" file's FileType event is swallowed by another eager plugin, so a buffer-local
" map would be missing for `nvim file.md`.
nnoremap <silent> <C-p> :silent exec '!firefox ' . shellescape(expand('%:p')) . ' &' \| redraw!<CR>

" Buffer Control
nnoremap <C-k> :call BufferActions('next')<CR>
nnoremap <C-j> :call BufferActions('previous')<CR>
nnoremap <C-x> :call BufferActions('close')<CR>
nnoremap <C-h> :call BufferActions('alternate')<CR>

nnoremap <silent> <C-*> <cmd>lua require('telescope.builtin').grep_string({ word_match = '-w' })<CR>

" Vim Bufferline
let g:bufferline_echo = 0

:command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'

" Show filepath.
nnoremap <F1> :call CopyCurrentBufferPath(0)<CR>
xnoremap <F1> :<C-u>call CopyCurrentBufferPath(1)<CR>
nnoremap <S-F1> :call CopyCurrentProjectPath()<CR>

" Toggle wrap
noremap <F2> :set wrap!<CR>

" Mouse
set mouse=
if (has('ttymouse'))
    set ttymouse=
endif
noremap <F3> :call ToggleMouse()<CR>

" Set path on NERDTree
" noremap <F4> :call SetPath()<CR>

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

" Open buffer on external editor. wine is Linux-only; no-op elsewhere
" so the binding is safe to load on macOS / WSL.
if executable('wine')
    noremap <F9> :silent exec "!(wine \"$HOME/.wine/dosdevices/c:/Program Files/Notepad++/notepad++.exe\" % &) > /dev/null"<CR>
endif

" Toggle BOM
noremap <F4> :set bomb!<CR>

" Toggle File Fomat
noremap <F5> :call ToggleFileformat()<CR>

" Toggle File Encode
noremap <F6> :call ToggleFileEncoding()<CR>

let g:airline_left_sep = ''
let g:airline_right_sep = ''

" Airline Theme
" let g:airline_theme='luna'
if has('nvim')
    " let g:airline_theme='molokai'
else
    let g:airline_theme='dracula'
endif

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#fnametruncate = 0
let g:airline#extensions#tabline#fnamecollapse = 2
let g:airline#extensions#tabline#fnamemod = ':t'

" let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
" let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

" let g:airline#extensions#coc#stl_format_err = '%E{[%e(#%fe)]}'
" let g:airline#extensions#coc#stl_format_warn = '%W{[%w(#%fw)]}'

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

" nmap <C-Up>    : CmdResizeUp<CR>
" nmap <C-Left>  : CmdResizeLeft<CR>
" nmap <C-Down>  : CmdResizeDown<CR>
" nmap <C-Right> : CmdResizeRight<CR>

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

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<S-Tab>"

inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"

if has("unix")
    inoremap <C-Space> <C-x><C-o>
elseif has("win32")
    inoremap <C-@> <C-x><C-o>
endif

" vim-visual-multi
let g:VM_maps = {}
let g:VM_maps['Find Under'] = ''

" Mirror VM extend-mode yanks to the system clipboard.
" VM writes yanks with setreg() directly (autoload/vm/ecmds1.vim :: fill_register),
" which bypasses the yank operator and therefore the clipboard=unnamedplus
" plumbing — so under Wayland, SSH, or a Vim without +clipboard the content
" never reaches the OS clipboard. VM fires `User visual_multi_mappings`
" every time it installs its buffer-local maps, so we piggyback on that
" to wrap `y` with a post-yank call to CopyToClipboard (which already
" dispatches to wl-copy / xsel / xclip).
augroup VMYankClipboard
    autocmd!
    autocmd User visual_multi_mappings
        \ nmap <silent><nowait><buffer> y <Plug>(VM-Yank):call CopyToClipboard(getreg('"'))<CR>
augroup END

" cd ~/.vim/colors
" curl -o molokai.vim https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim
" colorscheme molokai
" colorscheme desert
" colorscheme wal
" Re-apply transparency whenever the colorscheme is (re)loaded so the
" terminal's background opacity (e.g. wezterm) shows through.
augroup TransparentBackground
    autocmd!
    autocmd ColorScheme * highlight Normal      guibg=NONE ctermbg=NONE
    autocmd ColorScheme * highlight NormalNC    guibg=NONE ctermbg=NONE
    autocmd ColorScheme * highlight NormalFloat guibg=NONE ctermbg=NONE
    autocmd ColorScheme * highlight SignColumn  guibg=NONE ctermbg=NONE
    autocmd ColorScheme * highlight LineNr      guibg=NONE ctermbg=NONE
    autocmd ColorScheme * highlight EndOfBuffer guibg=NONE ctermbg=NONE
augroup END

if has('nvim')
    lua require('nightfox').setup({ options = { transparent = true } })
    " silent! colorscheme carbonfox
    silent! colorscheme dracula
else
    silent! colorscheme dracula
endif

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

" Highlight the matched substring in result rows. Bright + bold so it stays
" visible on both the normal (#1b1f27) and selected (#252931) row backgrounds.
highlight TelescopeMatching guifg=#ffaa00 gui=bold

" Match highlight inside the PREVIEW pane. Uses a background color so it
" stays visible even when treesitter has painted the foreground.
highlight TelescopePreviewMatch guifg=#1b1f27 guibg=#ffaa00 gui=bold
highlight TelescopePreviewLine guibg=#3a4060

lua <<EOF
if vim.fn.has('nvim') == 1 then
    local ok_ts, ts = pcall(require, 'nvim-treesitter.configs')
    if ok_ts then
        ts.setup({
            ensure_installed = { 'typescript', 'tsx', 'javascript', 'jsdoc', 'html', 'css', 'json' },
            highlight = { enable = true, additional_vim_regex_highlighting = false },
            indent = { enable = true },
        })
    end

    local ok_completion, completion = pcall(require, 'mini.completion')
    if ok_completion then
        completion.setup()
    end

    local ok_gitsigns, gitsigns = pcall(require, 'gitsigns')
    if ok_gitsigns then
        gitsigns.setup {
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
    end

    local ok_telescope, telescope = pcall(require, 'telescope')
    if ok_telescope then
        telescope.setup({
            defaults = {
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden",
                    "--glob=!**/.git/*",
                },
                file_ignore_patterns = {
                    "^./.git/",
                    "^node_modules/",
                    "^vendor/",
                    "%tests/"
                }
            },
            pickers = {
                find_files = {
                    hidden = true,
                },
            },
        })
    end

    local ok_stickybuf, stickybuf = pcall(require, 'stickybuf')
    if ok_stickybuf then
        stickybuf.setup()
    end

    -- which-key: popup reminding of keybindings. Auto-discovers mappings, so
    -- pressing a prefix (<leader>, g, z, <C-w>, ...) and waiting shows the
    -- available continuations. <leader>? lists every mapping for the buffer.
    local ok_whichkey, whichkey = pcall(require, 'which-key')
    if ok_whichkey then
        whichkey.setup({})
        -- Annotate existing direct mappings so they read nicely in the popup.
        whichkey.add({
            { '<C-p>', desc = 'Open current file in Firefox' },
        })
        -- <leader>? opens the full keymap list for the current buffer. Set as a
        -- real keymap (not via which-key.add) so it works regardless of how
        -- which-key installs its own triggers.
        vim.keymap.set('n', '<leader>?', function()
            whichkey.show({ global = false })
        end, { desc = 'Buffer keymaps' })
    end

    -- nvim-tree: NERDTree replacement, set up to match the old NERDTree options.
    -- Keys: a create (end with / for a dir), r rename, d delete, f live filter,
    -- s/i/t open in vsplit/split/tab (NERDTree's), g? help.
    local ok_nvimtree, nvimtree = pcall(require, 'nvim-tree')
    if ok_nvimtree then
        nvimtree.setup({
            view = { width = 60, number = true },          -- NERDTreeWinSize, ShowLineNumbers
            filters = {
                dotfiles = false,                          -- NERDTreeShowHidden
                custom = { '\\.profraw$' },                -- NERDTreeIgnore
            },
            sync_root_with_cwd = true,                     -- NERDTreeChDirMode=2
            on_attach = function(bufnr)
                local api = require('nvim-tree.api')
                api.config.mappings.default_on_attach(bufnr)
                local function map(key, fn, desc)
                    vim.keymap.set('n', key, fn, { buffer = bufnr, nowait = true, desc = 'nvim-tree: ' .. desc })
                end
                map('s', api.node.open.vertical, 'Open: vertical split')
                map('i', api.node.open.horizontal, 'Open: horizontal split')
                map('t', api.node.open.tab, 'Open: new tab')
            end,
        })
    end

    local ok_toggleterm, toggleterm = pcall(require, 'toggleterm')
    if ok_toggleterm then
        toggleterm.setup({
            open_mapping      = [[<F12>]],
            shell             = vim.fn.executable('fish') == 1 and 'fish' or vim.o.shell,
            direction         = 'float',
            start_in_insert   = true,
            insert_mappings   = true,
            terminal_mappings = true,
            persist_mode      = true,
            float_opts = {
                border   = 'curved',
                winblend = 0,
            },
            highlights = {
                NormalFloat = { guibg = 'NONE' },
                FloatBorder = { guibg = 'NONE' },
            },
        })

        vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { silent = true })
    end

    if vim.fn.executable('biome') == 1 then
        vim.lsp.enable('biome')
    end

    vim.diagnostic.config({
        virtual_text = true
    })
end
EOF