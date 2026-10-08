" Author: Elvis Oliveira - http://github.com/elvisoliveira "
let g:elvis_vimrc_loaded = 1

function! AirlineInit()
    let g:airline_section_c = airline#section#create(['%f'])
endfunc

let s:functional_buf_types = ['quickfix', 'help', 'nofile', 'terminal']

" Neovim's clipboard provider picks wl-copy, xclip or tmux (bare TTY) itself.
function! CopyToClipboard(text)
    call setreg('+', a:text)
    call setreg('*', a:text)
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
    return l:name =~# '^NvimTree_'
        \ || l:name =~# '^__Tagbar__'
        \ || l:name ==# '__LOTR__'
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

" Don't touch EOL of end of file
set nofixeol

" Remove EOL of end of file
set noeol

" Set bash as default shell.
set shell=/bin/bash

" No Swap files.
set noswapfile

" Code on 130 columns
set colorcolumn=130

" Indent Setup
set tabstop=4
set shiftwidth=4
set expandtab

" Fold Settings
set foldmethod=indent
set nofoldenable

" Show hybrid line numbers.
set number relativenumber

" Share yank with the system clipboard
set clipboard=unnamedplus

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

    " Git
    Plug 'tpope/vim-fugitive'
    Plug 'rhysd/git-messenger.vim'
    Plug 'lewis6991/gitsigns.nvim'

    Plug 'EdenEast/nightfox.nvim'

    " File tree
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'nvim-tree/nvim-tree.lua'

    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-lua/plenary.nvim' " telescope requirement
    Plug 'nvim-telescope/telescope.nvim', { 'tag': 'v0.1.9' }
    Plug 'echasnovski/mini.completion'
    Plug 'akinsho/toggleterm.nvim', { 'tag': 'v2.13.1' }
    Plug 'folke/which-key.nvim'

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

set termguicolors

" Show all hidden characters.
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:·
set list

" Wrap off
set nowrap

" ctrl-c for copy
vnoremap <C-c> "+y

nnoremap <silent> <C-c> :call CopyToClipboard(expand('<cword>'))<CR>

" File tree
map <C-n> <CMD>NvimTreeToggle<CR>
map <C-f> <CMD>NvimTreeFindFile<CR>

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

:command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'

" Show filepath.
nnoremap <F1> :call CopyCurrentBufferPath(0)<CR>
xnoremap <F1> :<C-u>call CopyCurrentBufferPath(1)<CR>
nnoremap <S-F1> :call CopyCurrentProjectPath()<CR>

" Toggle wrap
noremap <F2> :set wrap!<CR>

" Mouse
set mouse=
noremap <F3> :call ToggleMouse()<CR>

" Fuzzyfinder
" GREP
noremap <F7> <CMD>Telescope find_files<CR>
noremap <F8> <CMD>Telescope live_grep<CR>
nnoremap <C-Space> <CMD>Telescope buffers<CR>

" Open buffer on external editor (Notepad++ under wine).
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

" Blank airline bar in the file tree window (override renders an empty left
" side and no right side; keeps airline in charge, so it doesn't come back).
let g:airline_filetype_overrides = {'NvimTree': ['', '']}

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#fnametruncate = 0
let g:airline#extensions#tabline#fnamecollapse = 2
let g:airline#extensions#tabline#fnamemod = ':t'

let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ' '
let g:airline#extensions#tabline#right_alt_sep = ''

let g:airline#extensions#tabline#buffer_idx_mode = 1

" Fix indenting visual block
vmap < <gv
vmap > >gv

" Resize Buffer
let g:vim_resize_disable_auto_mappings = 1

nnoremap <C-u> 10k
nnoremap <C-d> 10j

nnoremap <PageUp> 10k
nnoremap <PageDown> 10j
nnoremap <Home> ^

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

" Open Quickfix itens with 'o' key
autocmd BufReadPost quickfix noremap <silent> <buffer> o <CR>

" AirLine
autocmd User AirlineAfterInit call AirlineInit()

hi Normal guibg=NONE ctermbg=NONE

nnoremap <ESC> :nohlsearch<CR>

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<S-Tab>"

inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"

inoremap <C-Space> <C-x><C-o>

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

lua require('nightfox').setup({ options = { transparent = true } })
silent! colorscheme dracula

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
-- " / % open in horizontal / vertical split (as tmux), t in a tab, g? help.
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
            -- tmux-style: " stacks (horizontal split), % side by side (vertical)
            map('"', api.node.open.horizontal, 'Open: horizontal split')
            map('%', api.node.open.vertical, 'Open: vertical split')
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
EOF
