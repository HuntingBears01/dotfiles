"------------------------------------------------------------------------------
"  Vundle Config
"------------------------------------------------------------------------------

" vint: -ProhibitSetNoCompatible
set nocompatible
" vint: +ProhibitSetNoCompatible
filetype off
set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" List plugins here
Plugin 'airblade/vim-gitgutter'
Plugin 'arcticicestudio/nord-vim'
Plugin 'godlygeek/tabular'
Plugin 'morhetz/gruvbox'
Plugin 'scrooloose/nerdcommenter'
Plugin 'sheerun/vim-polyglot'
Plugin 'tommcdo/vim-exchange'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'w0rp/ale'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

call vundle#end()
filetype plugin indent on


"------------------------------------------------------------------------------
"  Plugin Config
"------------------------------------------------------------------------------

" airblade/vim-gitgutter
set updatetime=250
let g:gitgutter_max_signs = 500

" Theme
if !has('mac')
  let g:gruvbox_italic=1
endif
if has('termguicolors')
  set termguicolors
endif
colorscheme gruvbox
" colorscheme nord

" scrooloose/nerdcommenter
let g:nerdspacedelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1

" w0rp/ale
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
let g:airline#extensions#ale#enabled = 1
nmap <silent> <leader>j <Plug>(ale_previous_wrap)
nmap <silent> <leader>k <Plug>(ale_next_wrap)

" vim-airline/vim-airline
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline#extensions#hunks#enabled = 0


"------------------------------------------------------------------------------
"  Vim Config
"------------------------------------------------------------------------------

set background=dark                                             " dark background
set encoding=utf-8                                              " text encoding
scriptencoding utf-8                                            " script encoding
syntax enable                                                   " enable syntax highlighting
set tabstop=2 sts=2 shiftwidth=2 expandtab                      " expand tabs to 2 spaces
set shiftround                                                  " Align indents to shiftwidth
set nowrap                                                      " no word wrap
set linebreak                                                   " Break long lines by word
set textwidth=100                                               " Wrap at 100 columns
set formatoptions=tcqnl1j                                       " See help: formatoptions
set number                                                      " Show line numbers
set numberwidth=5                                               " number column width
set hlsearch                                                    " highlight search matches
set ignorecase                                                  " case insensitive searching
set smartcase                                                   " unless query uses capital letters
set infercase                                                   " Completion recognises capitalisation
set incsearch                                                   " search characters as they're entered
set timeout timeoutlen=1000                                     " Timeout of 1s for normal keys
set ttimeoutlen=100                                             " Timeout 0f 0.1s for special keys (CTRL, ESC etc.)
set listchars=tab:▸\ ,trail:·,eol:¬,nbsp:_,extends:›,precedes:‹ " Customise “invisible” characters
set spelllang=en_gb                                             " Set British English as default
set colorcolumn=80                                              " Highlight column 80
set autoindent                                                  " Copy indent from previous line
set cindent                                                     " Automatic indenting
set copyindent                                                  " Copy indent characters from previous line
set backspace=indent,eol,start                                  " Let backspace work as expected
set laststatus=2                                                " Always display statusline
set noshowmode                                                  " Hide mode since airline shows it
set hidden                                                      " Hide buffers
set mouse=nvc                                                   " Use mouse except in insert mode
set scrolloff=5                                                 " Keep 15 lines visible above & below cursor
set sidescrolloff=10                                            " Keep 10 characters visible either side of cursor
set wildmenu                                                    " Show completions
silent! nohlsearch                                              " Clear search highlights at startup


"------------------------------------------------------------------------------
"  Filetype Config
"------------------------------------------------------------------------------

if has('autocmd')
  filetype on

  augroup vimrc
    " Remove all vimrc autocommands
    autocmd!

    " Syntax of these languages is fussy over tabs Vs spaces
    autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

    " Enable word wrap for the following filetypes
    autocmd FileType markdown setlocal wrap
    autocmd FileType html setlocal wrap
    autocmd FileType text setlocal wrap

    " j and k don't skip over wrapped lines in following filetypes, unless given a count
    autocmd FileType html,markdown,text nnoremap <expr> j v:count ? 'j' : 'gj'
    autocmd FileType html,markdown,text nnoremap <expr> k v:count ? 'k' : 'gk'
    autocmd FileType html,markdown,text vnoremap <expr> j v:count ? 'j' : 'gj'
    autocmd FileType html,markdown,text vnoremap <expr> k v:count ? 'k' : 'gk'

    " Automatically wrap at 72 characters and spell check git commit messages
    autocmd FileType gitcommit setlocal textwidth=72
    autocmd FileType gitcommit setlocal spell

    " Delete fugitive hidden buffers
    autocmd BufReadPost fugitive://* set bufhidden=delete

    " Highlight trailing whitespace
    highlight ExtraWhitespace ctermbg=DarkRed guibg=DarkRed
    match ExtraWhitespace /\s\+$/
    autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
    autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
    autocmd InsertLeave * match ExtraWhitespace /\s\+$/
    autocmd BufWinLeave * call clearmatches()

    " Example - Treat .rss files as XML
    " autocmd BufNewFile,BufRead *.rss setfiletype xml
  augroup END
endif


"------------------------------------------------------------------------------
"  Key Bindings
"------------------------------------------------------------------------------

let g:mapleader = ','

set pastetoggle=<F5>
nnoremap <F6> :set wrap! linebreak! nolist<CR>
nnoremap <Leader>h :nohlsearch<CR>
nnoremap <Leader>i :call Preserve("normal gg=G")<CR>
nnoremap <Leader>l :set list!<CR>
nnoremap <Leader>n :set invnumber<CR>
nnoremap <Leader>s :set spell!<CR>
nnoremap <leader>ve :tabedit $MYVIMRC<CR>
nnoremap <leader>vr :source $MYVIMRC<CR>
nnoremap <Leader>w :call Preserve("%s/\\s\\+$//e")<CR>

" Use CTRL h/j/k/l to switch windows
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Edit file in directory of current file in current window / split / vertical split / new tab
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" Move current line up/down (requires tpope/vim-unimpaired)
nmap <C-Up> [e
nmap <C-Down> ]e
vmap <C-Up> [egv
vmap <C-Down> ]egv


"------------------------------------------------------------------------------
"  Vim Functions
"------------------------------------------------------------------------------

function! Preserve(command)
  " Save last search, and cursor position.
  let l:_s=@/
  let l:l = line('.')
  let l:c = col('.')
  " Do the business
  execute a:command
  " Restore previous search history, and cursor position
  let @/=l:_s
  call cursor(l:l, l:c)
endfunction
