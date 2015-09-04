set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Keep Plugin commands between vundle#begin/end.
Plugin 'chriskempson/base16-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'bling/vim-airline'
Plugin 'terryma/vim-expand-region'
Plugin 'sheerun/vim-polyglot'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
    syntax on
endif

" Color scheme
let base16colorspace=256
colorscheme base16-atelierdune
set background=dark
set encoding=utf-8

set autowrite       " Automatically save before commands like :next and :make
set backspace=2     " Backspace deletes like most programs in insert mode
set laststatus=2    " Always display the status line
set showcmd         " Show (partial) command in status line
set ruler           " show the cursor position all the time
set autoindent      " Copy indent from previous line
set numberwidth=5   " Column width
set showtabline=2   " Always display the tabline
set noshowmode      " Hide default mode text
set invnumber       " Show line numbers
set ignorecase      " Do case insensitive matching
set incsearch       " Incremental search
set smartcase       " Do smart case matching
set timeoutlen=50   " Fix pause leaving insert mode for vim-airline

" Key Bindings
vmap v <Plug>(expand_region_expand)     " Select character/word/paragraph
vmap <C-v> <Plug>(expand_region_shrink) " Go back to previous selection

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

" Softtabs, 4 spaces
set tabstop=4
set shiftwidth=4
set shiftround
set expandtab

" Toggle paste mode with F2
set pastetoggle=<F2>

" Toggle line numbering
nmap <F3> :set invnumber<CR>

" Toggle NERDTree
map <F4> :NERDTreeToggle<CR>

" Automatically close if NERDTree is last window
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Vim-airline config
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

let g:airline_left_sep = ''
let g:airline_right_sep = ''

" Highlight extra whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
