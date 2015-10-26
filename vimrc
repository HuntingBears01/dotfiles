" -------------------- Vundle begin --------------------

set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Plugin list
Plugin 'chriskempson/base16-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'bling/vim-airline'
Plugin 'terryma/vim-expand-region'
Plugin 'sheerun/vim-polyglot'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'scrooloose/nerdcommenter'
Plugin 'rstacruz/sparkup'
Plugin 'mattn/emmet-vim'
Plugin 'godlygeek/tabular'

call vundle#end()            " required
filetype plugin indent on    " required

" -------------------- Vundle end --------------------

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
    syntax on
    set hlsearch
endif

" Color scheme
let base16colorspace=256
colorscheme base16-atelierdune
set background=dark
set encoding=utf-8

" Vim-airline config
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_left_sep = ''
let g:airline_right_sep = ''

" Tab config
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set shiftround

" Key mappings
" ============
" Set leader key
let mapleader = ","
" F2 - Toggle paste mode
set pastetoggle=<F2>
" F3 - Toggle line numbering
nmap <F3> :set invnumber<CR>
" F4 - Toggle NERDTree
nmap <F4> :NERDTreeToggle<CR>
" F5 - Remove trailing spaces
nmap <F5> :call Preserve("%s/\\s\\+$//e")<CR>
" F6 - Fix indentation for entire document
nmap <F6> :call Preserve("normal gg=G")<CR>
" F7 - Toggle show hidden characters
nmap <F7> :set list!<CR>
" F8 - Toggle wordwrap
nmap <F8> :set wrap! linebreak! nolist<CR>
" F9 - Toggle spellcheck
nmap <F9> :set spell!<CR>
" F10 - Clear search highlighting
nmap <F10> :nohlsearch<CR>
" v/CTRL v - Select/deselect character/word/paragraph
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
" CTRL h/j/k/l - Switch to window left/below/above/right
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
" Auto cetre on matched string
noremap n nzz
noremap N Nzz
" Navigate through wrapped lines
vmap j gj
vmap k gk
nmap j gj
nmap k gk
" Tabular shortcuts
if exists(":Tabularize")
    nmap <Leader>a= :Tabularize /=<CR>
    vmap <Leader>a= :Tabularize /=<CR>
    nmap <Leader>a: :Tabularize /:\zs<CR>
    vmap <Leader>a: :Tabularize /:\zs<CR>
endif

set backspace=2                         " Backspace deletes like most programs in insert mode
set laststatus=2                        " Always display the status line
set showcmd                             " Show (partial) command in status line
set ruler                               " show the cursor position all the time
set autoindent                          " Copy indent from previous line
set numberwidth=5                       " Column width
set showtabline=2                       " Always display the tabline
set noshowmode                          " Hide default mode text
set number                              " Show line numbers
set ignorecase                          " Do case insensitive matching
set incsearch                           " Incremental search
set smartcase                           " Do smart case matching
set timeoutlen=1000                     " Timeout for normal keys
set ttimeoutlen=50                      " Timeout for special keys (CTRL, ESC etc.)
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_    " Customise “invisible” characters
set nowrap                              " Turn off wordwrap
set spelllang=en_gb                     " Set British English as default
set hidden                              " Hide buffers instead of prompting to save
set scrolloff=8                         " Keep 8 lines above or below the cursor when scrolling
set sidescroll=1
set sidescrolloff=15                    " Keep 15 columns next to the cursor when scrolling horizontally

if has("autocmd")
    " Automatically close if NERDTree is last window
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
endif

augroup vimrcEx
    autocmd!

    " When editing a file, always jump to the last known cursor position.
    " Don't do it for commit messages, when the position is invalid, or when
    " inside an event handler (happens when dropping a file on gvim).
    autocmd BufReadPost *
                \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
                \   exe "normal g`\"" |
                \ endif

    " Automatically wrap at 72 characters and spell check git commit messages
    autocmd FileType gitcommit setlocal textwidth=72
    autocmd FileType gitcommit setlocal spell
augroup END

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

function! Preserve(command)
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    execute a:command
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction
