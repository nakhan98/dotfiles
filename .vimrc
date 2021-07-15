" Neovim specific settings
if has('nvim')
    tnoremap <Esc> <C-\><C-n>
    " Set python interpreter (for neovim) - requires `pynvim` python package
    " let g:python3_host_prog = '/usr/local/anaconda3/envs/black/bin/python'

" Standard Vim settings
else
    " Note: By default vim 8+ should automatically pick up the current python
    " environment (including venvs) so the below should be unnecessary
    " set custom python (requires vim with dynamic python support eg. macvim)
    " set pythonthreedll=/usr/local/anaconda3/envs/testing_36/lib/libpython3.6m.dylib
    " set pythonthreehome=/usr/local/anaconda3/envs/testing_36

    " Change cursor shape according to mode (note: neovim has this by default)
    let &t_SI = "\<Esc>[6 q"
    let &t_SR = "\<Esc>[4 q"
    let &t_EI = "\<Esc>[2 q"
endif


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
if has("gui_vimr")
    " Here goes some VimR specific settings like
    colorscheme spacegray
else if has('nvim')
    " Iterm/neovim
    set termguicolors
    let g:gruvbox_italics = 0
    let g:gruvbox_contrast_dark = 'hard'
    colo gruvbox
    " colo spacegray
else
    colorscheme rdark-terminal3
endif
set background=dark

" Colorcolumn
set colorcolumn=80
highlight ColorColumn ctermbg=8

" Make vim transparent
" https://stackoverflow.com/a/37720708
hi Normal guibg=NONE ctermbg=NONE

" Set backup
set backup

" Edit multiple buffers without saving 
set hidden

"Change encryption algo to blowfish
set cm=blowfish2

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

" Disable jedi autocomplete (can be slow)
let g:jedi#completions_enabled = 0

" CtrlP vim
" let g:ctrlp_cmd='CtrlP :pwd'

" Use fzf.vim as replacement for CtrlP
nnoremap <silent> <C-p> :Files<CR>

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
" autocmd BufWritePre *.py execute ':Black'

" YAML indentation
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Easier vim pane navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" System clipboard integration
" (Requires xclip on GNU/Linux)
set clipboard=unnamed
if has("unnamedplus") " X11 support
    set clipboard+=unnamedplus
endif

" Default FZF stuff (fzf.vim plugin requires stuff from fzf installation)
" If installed using Homebrew
" set rtp+=/usr/local/opt/fzf

" If installed using git
set rtp+=~/.fzf

" If install via debian package manager
" source /usr/share/doc/fzf/examples/fzf.vim

" Disable modelines
set modelines=0
set nomodeline

" Vim-Go - force quickfix pane to be at the bottom
" https://github.com/fatih/vim-go/issues/108
" autocmd FileType qf if (getwininfo(win_getid())[0].loclist != 1) | wincmd J | endif

" Ripgrep goodies!
if executable('rg')
  set grepprg=rg\ --color=never\ --vimgrep
  " If using CtrlP
  " let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  " let g:ctrlp_use_caching = 0
  command -nargs=1 Rgpy cexpr system("rg --vimgrep -tpy <args>") | cw
  command -nargs=* Rgc cexpr system("rg --vimgrep <args>") | cw
endif
