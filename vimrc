" Vundle begin {{{1

set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Plugin begin
Plugin 'chriskempson/base16-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'terryma/vim-expand-region'
Plugin 'sheerun/vim-polyglot'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/nerdcommenter'
Plugin 'nelstrom/vim-markdown-folding'
Plugin 'tpope/vim-repeat'

call vundle#end()            " required
filetype plugin indent on    " required

" Syntax highlighting {{{1
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
    syntax on
    set hlsearch " Highlight search pattern
endif

" Color scheme {{{1
let base16colorspace=256
colorscheme base16-atelierdune
set background=dark
set encoding=utf-8

" Vim-airline config {{{1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_theme='base16'

" Tab config {{{1
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set shiftround
set smarttab

" Key mappings {{{1
let mapleader = ","
" Toggle paste mode
set pastetoggle=<F2>
" Toggle line numbering
nnoremap <Leader>l :set invnumber<CR>
" Toggle NERDTree
nnoremap <Leader>n :NERDTreeToggle<CR>
" Remove trailing spaces
nnoremap <Leader>t :call Preserve("%s/\\s\\+$//e")<CR>
" Fix indentation for entire document
nnoremap <Leader>i :call Preserve("normal gg=G")<CR>
" Toggle show hidden characters
nnoremap <Leader>h :set list!<CR>
" Toggle wordwrap
nnoremap <Leader>w :set wrap! linebreak! nolist<CR>
" Toggle spellcheck
nnoremap <Leader>s :set spell!<CR>
" Clear search highlighting
nnoremap <Leader>c :nohlsearch<CR>
" Edit vimrc
nnoremap <leader>ev :split $MYVIMRC<cr>
" Reload vimrc
nnoremap <leader>rv :source $MYVIMRC<cr>

" Vim-expand-region config {{{1
" Select/deselect character/word/paragraph
vnoremap v <Plug>(expand_region_expand)
vnoremap <C-v> <Plug>(expand_region_shrink)

" Vim tweaks {{{1
" CTRL h/j/k/l - Switch to window left/below/above/right
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
" Auto centre on matched string
noremap n nzz
noremap N Nzz
" Navigate through wrapped lines
vnoremap j gj
vnoremap k gk
nnoremap j gj
nnoremap k gk

" General settings {{{1
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
set colorcolumn=80                      " Highlight column 80
" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Folding settings {{{1
augroup folding
    autocmd!
    " Set syntax folding as default
    autocmd FileType * setlocal foldmethod=syntax
    " Set marker folding for vim files
    autocmd FileType vim setlocal foldmethod=marker
    " Set expr folding for markdown files
    autocmd FileType markdown setlocal foldmethod=expr
augroup END
set nofoldenable
set foldnestmax=2
let sh_fold_enabled=1
let javaScript_fold=1
let php_folding=1
let xml_syntax_folding=1
noremap <Space> za
vnoremap <Space> za

" NERDTree config {{{1
augroup nerdtree
    autocmd!
    " Automatically close if NERDTree is last window
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
augroup end

" Save cursor position & Git commit config {{{1
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

" Indentation script {{{1
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
