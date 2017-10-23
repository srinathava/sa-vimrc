" -------------------------------- Settings ---------------------------
au GuiEnter * colorscheme navajo-night
nmap <M-f> :simalt~x<CR>:<BS>
nmap <F3> <Plug>StartBufExplorer
filetype plugin on
filetype indent on
" ff=unix makes sense because vim compiled for a dos machine can source unix
" style script files whereas vim compiled for *ix usually cannot source a dos
" style script file.
au BufWritePre *.vim :if &ff != 'unix' | set ff=unix | endif
syntax on
set expandtab
set hls
set ignorecase
set smartcase
set indentkeys+=!
set showmode
set showcmd
set grepprg=grep\ -nH\ $*
set ruler
set shiftwidth=4
set laststatus=2
set ww=<,>,[,],h,l
set sm
set cpt=.,w,b,t,u,k/usr/dict/words
set tags+=./tags,../tags,../../tags,../../../tags
set ai
set tw=75
set ts=4
set bs=2
if has('unix')
    set shell=bash
    set shellslash
endif
set wildmode=longest:list
set wildmenu
set autoread
set mousemodel=popup_setpos
set sessionoptions=buffers,curdir,folds,globals,resize,winpos,winsize
let mapleader='`'
" incase i have to view some file with huge long lines...
set linebreak
" preserve some info from the last vim session
if has('unix')
    set viminfo='1000,:1000,\"5000,/1000,n~/.viminfo.win32
else
    set viminfo='1000,:1000,\"5000,/1000,n~/.viminfo.unix
end
" always want to see the whole line.
set wrap
" no beeps. only flashes.
set vb
" to maintain compatibility with cygwin vim and gvim for windows while
" maintaining a commmon plugin directory.
set viewdir="e:/srinath/.vim/views/"
" manual folding
" set foldmethod=syntax
" allows for the vim yank command to be the windows clipboard.
set clipboard=unnamed
" do not display a string of '@'s instead of a long unwrapped line 
set display=lastline
" for the normal command gf
set suffixesadd=.m,.c,.tex
" preserve a minimum amount of context while scrolling off the screen
set scrolloff=2
" pressing return or o while typing comments preserves comment header.
set fo+=ro
set listchars=tab:>-,precedes:<,extends:>,trail:.,tab:>-,eol:$
" dont want :w to move cursor to beginning of line.
set nosol
set guioptions-=t
" set guioptions=-m
" set guioptions+=f
" set guifont=Andale_Mono:h9:cANSI
if has('gui_win32')
    set guifont=Consolas:h10
else
    " set guifont=Inconsolata\ 12
    set guifont=Monospace\ 10
end
set et sts=4 sw=4

" ----------------------- Some common typos i make -----------------------
iab teh the
iab hte the
iab convinient convenient
iab atleast at<space>least
iab acheive achieve
iab coifficient coefficient
iab coifficients coefficients
iab guarentee guarantee
iab infact in<space>fact

" ------------------------ General Purpose mappings -----------------------
map <F2> :browse w<CR>
imap <F2> <esc>:browse w<CR>

" toggle hls on/off
map <F7> :set hls!<cr>:echo "HLSearch: " . strpart("OffOn", 3 * &hlsearch, 3)<cr>
" echo the highlight group currently under cursor. (from vim.source...)
map  <F8>  :echo 'hi<' .synIDattr(synID(line("."),col("."),1),"name") .'>'<cr>
" source the selected text in vim (really useful)
" mnemonic: r for run
vmap <c-r> "ny:exec @n<cr>:<bs>
" make shift-down/up move only one line in visual mode.
vmap <s-down> <down>
vmap <s-up> <up>
" always want to go the character visually above the current character
" not the character in the previous _line_ (helpful when wrap on and 
" long lines exist) (taken from tips at vim.sourceforge.net)
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap $ g$
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk
inoremap <C-l> <C-o>l
" the standard windows way of selecting the whole file 
" restores the original position. ofcourse this screws the 
" normal mode mapping which icrements the number under the cursor.
nnoremap <c-a> maggVGy`a
" a natural extension of the ctrl-a function to visual-block mode.
vnoremap <c-a> <c-v>:Inc 1<cr>

" pressing / in visual mode will search for selected text.
" however this will destroy the contents of the register k.
if !has("gui")
	nnoremap # <C-^>
end

nnoremap <M-F5> :simalt ~x<cr>
nnoremap <tab> za

inoremap <C-j> <down>
inoremap <C-k> <up>
inoremap <C-l> <right>
inoremap <C-h> <left>

inoremap <C-q> <C-k>

imap <C-Space> <Plug>IMAP_JumpForward
if !has('gui_running')
    imap <C-f> <Plug>IMAP_JumpForward
end

imap <F1> <nop>
nmap <F1> <nop>
" -------------------------------------------------------------------------


" ------------- Useful constants/mappings for winmanager.vim ------------
" files to hide... and many still to come....
let g:explHideFiles='\.gz$,\.exe$,\.zip$,\.eps$,\.ps$,\.mat$,\.fig$,\.dvi$'
let g:explHideFiles=g:explHideFiles.',\.jpg$,\.tif$,\.pnm$,\.pdf$'
let g:explHideFiles=g:explHideFiles.',\.doc$,\.bmp$'
let g:persistentBehaviour=1
let g:winManagerWindowLayout = "FileExplorer,TagList|BufExplorer"
let loaded_explorer = 1
let g:defaultExplorer = 0
let g:winManagerWidth = 35     " for WindowsManager
let g:bufExplorerMaxHeight = 25  " for WindowsManager
let g:defaultExplorer = 0
map <c-w><c-f> :FirstExplorerWindow<cr>
map <c-w><c-b> :BottomExplorerWindow<cr>
map <c-w><c-t> :WMToggle<cr>
map <c-h> <c-w>h
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
" -----------------------------------------------------------------------

com! -nargs=0 CD :exec 'cd '.expand('%:p:h')
let g:Debug = 1
let g:DrChipTopLvlMenu = '&Plugin.&DrChip.'

let g:DirDiffExcludes = "CVS,swp$,exe$,obj$,*.o$"

let g:did_install_syntax_menu = 1

let s:path = fnameescape(expand('<sfile>:p:h'))
exec 'set rtp^='.s:path.'/vimfiles'
exec 'set rtp^='.s:path.'/vimfiles/vim-latex'
exec 'set rtp^='.s:path.'/pathogen'
exec 'set rtp^='.s:path.'/vimfiles/after'

let g:Imap_UsePlaceHolders = 0
call pathogen#infect()

if has('unix')
    let $PATH = $PATH . ":" . s:path
else
    let $PATH = $PATH . ";" . s:path
endif

au BufReadCmd *.slx call zip#Browse(expand("<amatch>"))

" syntastic options
:set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
