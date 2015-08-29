" Turn on line numbering 
set nu

" Set syntax on
syntax on

" Messes up nested comments in python code
"set cindent
"set smartindent

" From here - http://stackoverflow.com/a/1523519
set tabstop=4
set shiftwidth=4
filetype indent on
filetype on
filetype plugin on

" Expand tab to spaces
set et 

" Change to directory of file
set autochdir

" Case insensitive search
set ic

" Higlhight search
set hls

" Wrap text instead of being on one line
set lbr

" Colouring
colorscheme baycomb
set background=dark

" Set backup
set backup

" Edit multiple buffers without saving 
set hidden

" Change encryption algo to blowfish
set cm=blowfish2

" Load Pathogen
" execute pathogen#infect()
