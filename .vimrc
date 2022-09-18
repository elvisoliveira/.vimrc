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

    if (&buftype ==# 'quickfix' || &buftype ==# 'terminal')
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

" Read .vimrc files of the file directory
set exrc
set secure

" Make Vim completion popup menu work just like in an IDE
set completeopt=menu,menuone,noselect

call plug#begin('~/.vim/plugged')
    Plug 'godlygeek/tabular'
    Plug 'itchyny/vim-cursorword'
    Plug 'roxma/vim-paste-easy'
    Plug 'moll/vim-bbye'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'scrooloose/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'bling/vim-bufferline'
    Plug 'mg979/vim-visual-multi'
    Plug 'hrsh7th/vim-vsnip'
    " Plug 'wellle/context.vim'
    Plug 'chaoren/vim-wordmotion'
    Plug 'editorconfig/editorconfig-vim'
    " Git
    Plug 'cohama/agit.vim'
    " Neovim excl. plugins
    if has('nvim')
        Plug 'neovim/nvim-lspconfig'
        Plug 'hrsh7th/nvim-compe'
        Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
        Plug 'nvim-treesitter/nvim-treesitter-context'
    endif
    " IDE like plugins
    if (len(v:argv) > 2 && (v:argv[-2] =~ ".vimrc.ide" || v:argv[-2] =~ ".vimrc.java"))
        Plug 'elvisoliveira/vim-lotr'
        Plug 'preservim/tagbar'
        Plug 'jeetsukumaran/vim-buffergator'
        Plug 'Xuyuanp/nerdtree-git-plugin'
        Plug 'ryanoasis/vim-devicons'
        Plug 'airblade/vim-gitgutter'
        Plug 'breuckelen/vim-resize'
        Plug 'mhinz/vim-grepper'
        Plug 'junegunn/fzf'
        Plug 'vim-syntastic/syntastic'
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

map <C-n> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>

" Buffer Control
nnoremap <C-k> :call BufferActions('next')<CR>
nnoremap <C-j> :call BufferActions('previous')<CR>
nnoremap <C-x> :call BufferActions('close')<CR>
nnoremap <C-h> :call BufferActions('alternate')<CR>

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
noremap <F9> :silent exec "!(scite % &) > /dev/null"<CR>

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

if !has("gui_running")
    hi Normal guibg=NONE ctermbg=NONE
endif

" supress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=c

" A smaller timeout for quicker refresh rate
set timeoutlen=100

nnoremap <Tab> :

nnoremap <A-h> <cmd>lua vim.diagnostic.goto_prev({float=false})<CR>
nnoremap <A-l> <cmd>lua vim.diagnostic.goto_next({float=false})<CR>

noremap <A-j> <C-e>
noremap <A-k> <C-y>

" errors, warnings, info
hi! Error   guibg=#ff3600 guifg=#bc6ec5 ctermbg=7 ctermfg=196 gui=bold cterm=bold
hi! Warning guibg=#ff761a guifg=#bc6ec5 ctermbg=7 ctermfg=226 gui=bold cterm=bold
hi! Info    guibg=#b4b4b9 guifg=#839496 ctermbg=7 ctermfg=202 gui=bold cterm=bold

hi! link ErrorMsg Error
hi! link WarningMsg Warning
hi! link InfoMsg Info

" LSP highlights
hi! link LspDiagnosticsDefaultError Error
hi! link LspDiagnosticsDefaultWarning Warning
hi! link LspDiagnosticsDefaultHint Info
hi! link LspDiagnosticsDefaultInformation Info
hi! link LspDiagnosticsDefaultInfo Info

hi! link LspDiagnosticsErrorSign Error
hi! link LspDiagnosticsHintSign Info
hi! link LspDiagnosticsInformationSign Info
hi! link LspDiagnosticsWarningSign Warning

hi! link LspDiagnosticsUnderlineError Error
hi! link LspDiagnosticsUnderlineWarning Warning
hi! link LspDiagnosticsUnderlineHint Info
hi! link LspDiagnosticsUnderlineInformation Info
hi! link LspDiagnosticsUnderlineInfo Info

hi! link LspDiagnosticsVirtualTextError Error
hi! link LspDiagnosticsVirtualTextWarning Warning
hi! link LspDiagnosticsVirtualTextHint Info
hi! link LspDiagnosticsVirtualTextInformation Info
hi! link LspDiagnosticsVirtualTextInfo Info

hi! link LspDiagnosticsFloatingError Error
hi! link LspDiagnosticsFloatingWarning Warning
hi! link LspDiagnosticsFloatingHint Info
hi! link LspDiagnosticsFloatingInformation Info
hi! link LspDiagnosticsFloatingInfo Info

hi! link LspDiagnosticsSignError Error
hi! link LspDiagnosticsSignWarning Warning
hi! link LspDiagnosticsSignHint Info
hi! link LspDiagnosticsSignInformation Info
hi! link LspDiagnosticsSignInfo Info

hi! link DiagnosticError Error
hi! link DiagnosticWarn Warning
hi! link DiagnosticInfo Info
hi! link DiagnosticHint Info

hi! link DiagnosticSignError Error
hi! link DiagnosticSignWarning Warning
hi! link DiagnosticSignInformation Info
hi! link DiagnosticSignInfo Info
hi! link DiagnosticSignHint Info

hi! link LspDiagnosticsError Error
hi! link LspDiagnosticsWarning Warning
hi! link LspDiagnosticsInformation Info
hi! link LspDiagnosticsInfo Info
hi! link LspDiagnosticsHint Info

" hi! link LspReferenceRead Error
" hi! link LspReferenceText Warning
" hi! link LspReferenceWrite Info

hi! link DiagnosticFloatingError Error
hi! link DiagnosticFloatingWarn Warning
hi! link DiagnosticFloatingInfo Info
hi! link DiagnosticFloatingHint Info

hi! link DiagnosticUnderlineError Error
hi! link DiagnosticUnderlineWarn Warning
hi! link DiagnosticUnderlineInfo Info
hi! link DiagnosticUnderlineHint Info

hi! link DiagnosticVirtualTextError Error
hi! link DiagnosticVirtualTextWarn Warning
hi! link DiagnosticVirtualTextInfo Info
hi! link DiagnosticVirtualTextHint Info

" hi! link Pmenu guibg=#140100 guifg=#660300 gui=none
" hi! link PmenuSbar guibg=#430300 gui=none
" hi! link PmenuThumb guibg=#720300 gui=none
" hi! link PmenuSel guibg=#F17A00 guifg=#4C0200 gui=none

"" Omni Completion
" autocmd   FileType   c            set   omnifunc=ccomplete#Complete
" autocmd   FileType   css          set   omnifunc=csscomplete#CompleteCSS
" autocmd   FileType   html         set   omnifunc=htmlcomplete#CompleteTags
" autocmd   FileType   javascript   set   omnifunc=javascriptcomplete#CompleteJS
" autocmd   FileType   php          set   omnifunc=phpcomplete#CompletePHP
" autocmd   FileType   python       set   omnifunc=pythoncomplete#Complete
" autocmd   FileType   xml          set   omnifunc=xmlcomplete#CompleteTags

if !has('nvim')
    inoremap <expr> <C-@> <c-x><c-o>
    inoremap <expr> <CR>  pumvisible() ? "\<C-y>" : "\<CR>"
    " inoremap <expr> <C-l> pumvisible() ? "\<C-y>" : "\<C-l>"
    inoremap <expr> <Esc> pumvisible() ? (complete_info().selected == -1 ? "\<Esc>" : "\<C-e>") : "<Esc>"
    inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
    inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
else
    inoremap <expr> <CR>      compe#confirm('<CR>')
    inoremap <expr> <C-Space> compe#complete()

    inoremap <expr> <Esc> pumvisible() ? (complete_info().selected == -1 ? "\<Esc>" : compe#close('<C-e>')) : "<Esc>"
    inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
    inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
endif

nnoremap <Esc> :noh<Return><Esc>

let g:VM_maps = {}
let g:VM_maps['Find Under'] = ''

lua <<EOF
if vim.fn.has('nvim') == 1 then
    require'compe'.setup{
        enabled = true;
        autocomplete = true;
        debug = false;
        min_length = 1;
        preselect = 'enable';
        throttle_time = 80;
        source_timeout = 200;
        resolve_timeout = 800;
        incomplete_delay = 400;
        max_abbr_width = 100;
        max_kind_width = 100;
        max_menu_width = 100;
        documentation = {
            border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
            winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
            max_width = 120,
            min_width = 60,
            max_height = math.floor(vim.o.lines * 0.3),
            min_height = 1,
        };
        source = {
            path = true;
            spell = true;
            tag = true;
            buffer = true;
            calc = true;
            nvim_lsp = true;
            nvim_lua = true;
            vsnip = true;
            ultisnips = true;
            luasnip = true;
            emoji = true;
        };
    }
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {
            'documentation',
            'detail',
            'additionalTextEdits'
        }
    }
    require'lspconfig'.phpactor.setup {
        capabilities = capabilities
    }
    require'lspconfig'.eslint.setup {
        capabilities = capabilities
    }
    require'lspconfig'.tsserver.setup{
        capabilities = capabilities
    }
    require'nvim-treesitter.configs'.setup {
        ensure_installed = { "vim", "python", "php", "javascript", "lua" },
        sync_install = false,
        highlight = {
            enable = true,
            disable = {},
            additional_vim_regex_highlighting = false
        }
    }
    --[[
    -- ]]
    require'treesitter-context'.setup{
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
            -- For all filetypes
            -- Note that setting an entry here replaces all other patterns for this entry.
            -- By setting the 'default' entry below, you can control which nodes you want to
            -- appear in the context window.
            default = {
                'class',
                'function',
                'foreach',
                'method',
                -- 'for', -- These won't appear in the context
                'while',
                'if',
                'switch',
                'case',
            },
            -- Example for a specific filetype.
            -- If a pattern is missing, *open a PR* so everyone can benefit.
            --   rust = {
            --       'impl_item',
            --   },
        },
        exact_patterns = {
            -- Example for a specific filetype with Lua patterns
            -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
            -- exactly match "impl_item" only)
            -- rust = true,
        },

        -- [!] The options below are exposed but shouldn't require your attention,
        --     you can safely ignore them.

        zindex = 20, -- The Z-index of the context window
    }
end
EOF
