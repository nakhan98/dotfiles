" Set python interpreter (for neovim) - requires `pynvim` python package
" let g:python3_host_prog = '/usr/local/anaconda3/envs/black/bin/python'

"set custom python (requires vim with dynamic python support eg. macvim)
" set pythonthreehome =/usr/local/anaconda3/envs/black

" Turn on line numbering
set nu

" No backward conpatibility
set nocompatible

" Search into subfolders
set path+=**

" Wild Menu
set wildmenu

" Setup ctags
command! MakeTags !ctags -R --exclude=.git .

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

" Change to directory of file
" set autochdir

" Case insensitive search
set ic

" Higlhight search
set hls

" Wrap text instead of being on one line
set lbr

" Colouring
colorscheme rdark-terminal2
set background=dark

" Set backup
set backup

" Edit multiple buffers without saving 
set hidden

"Change encryption algo to blowfish
set cm=blowfish2

"Pathogen - https://github.com/tpope/vim-pathogen
execute pathogen#infect()

" Airline stuff
" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

" Force start airline
set laststatus=2

" Use powerline fonts
" See:
" https://powerline.readthedocs.io/en/master/installation.html#patched-fonts
" let g:airline_powerline_fonts=1

" Colorcolumn
set colorcolumn=80
highlight ColorColumn ctermbg=8

" Make vim transparent
" https://stackoverflow.com/a/37720708
hi Normal guibg=NONE ctermbg=NONE

" Disable jedi autocomplete (can be slow)
let g:jedi#completions_enabled = 0

" CtrlP vim
" set runtimepath^=~/.vim/bundle/ctrlp.vim

" Set mouse
set mouse=a

" Nerdtree stuff
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
" Start NERDTree
autocmd VimEnter * NERDTree
" Go to previous (last accessed) window.
autocmd VimEnter * wincmd p

" Run black on save
" If you have a custom python virtualenv with `black` installed
" let g:black_virtualenv = "/Users/nasef_khan/tmp/virtualenvs/black"
autocmd BufWritePre *.py execute ':Black'
