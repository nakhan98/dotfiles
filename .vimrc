" vim-plug
call plug#begin()
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'roxma/vim-tmux-clipboard'

" Plug 'hashivim/vim-terraform'
" Plug 'github/copilot.vim'
" Plug 'morhetz/gruvbox'
" Plug 'heavenshell/vim-pydocstring'
call plug#end()

" Turn on line numbering
set nu

" Set syntax on
syntax on

" From here - http://stackoverflow.com/a/1523519
set tabstop=4
set shiftwidth=4
filetype indent on
filetype on
filetype plugin on

" Expand tab to spaces
set et

" Case insensitive search
set ic

" Highlight search
set hls

" Wrap text instead of being on one line
set lbr

" Colorscheme — set preferred colorscheme here (uses terminal default if unset)
set background=dark

" Colorcolumn
set colorcolumn=80

" Set backup
set backup

" Edit multiple buffers without saving
set hidden

" When closing quickfix window prevent splits auto-resizing
" https://www.reddit.com/r/vim/comments/e54dz0/comment/f9hpweq
set noequalalways

" Disable modelines
set modelines=0
set nomodeline

" Set mouse
set mouse=a

" System clipboard integration
" (Requires xclip on GNU/Linux)
set clipboard=unnamed
if has("unnamedplus") " X11 support
    set clipboard+=unnamedplus
endif

" Easier vim pane navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" YAML indentation
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" NERDTree
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
" Start NERDTree and move cursor to main window
autocmd VimEnter * NERDTree
autocmd VimEnter * wincmd p

" FZF
" Use fzf.vim as replacement for CtrlP
nnoremap <silent> <C-p> :Files<CR>

" FZF runtime path — adjust if installed differently
if has('mac')
    set rtp+=/opt/homebrew/opt/fzf
else
    set rtp+=~/.fzf
endif

" Ripgrep
if executable('rg')
    set grepprg=rg\ --color=never\ --vimgrep
    command -nargs=1 Rgpy cexpr system("rg --vimgrep -tpy <args>") | cw
    command -nargs=* Rgc cexpr system("rg --vimgrep <args>") | cw
endif
