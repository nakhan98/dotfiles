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
colorscheme spacegray
set background=dark

" Set backup
set backup

" Edit multiple buffers without saving 
set hidden

"Change encryption algo to blowfish
"set cm=blowfish2

"Pathogen - https://github.com/tpope/vim-pathogen
execute pathogen#infect()

" Airline stuff
" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

" Change to vtfspirent dir
" http://inlehmansterms.net/2014/09/04/sane-vim-working-directories/
" cd ~/cachelogic/development/vtfspirent/vxtest

" Colorcolumn
set colorcolumn=80
" highlight ColorColumn ctermbg=8
" highlight ColorColumn guibg=#424242

" Remove menu, toolbars and scrollbar
set guioptions -=m 
set guioptions -=T
set guioptions -=r

