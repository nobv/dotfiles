" enable filetype plugin
filetype plugin on

" enable filetype indent
filetype indent on

" tab to space
set expandtab

" default shiftwidth
set shiftwidth=2

" default tabstop
set tabstop=2

" default softtabstop
set softtabstop=2

" enable autoindent
set autoindent

" enable smartindent
set smartindent

" display row number
set number

" show title
set title

" show ruler
set ruler

" 不可視文字表示
set list
set listchars=tab:__,trail:_,nbsp:_,extends:>,precedes:<

" 全角スペースの表示
highlight SpecialKey   cterm=underline ctermfg=lightblue guibg=darkgray
highlight JpSpace      cterm=underline ctermfg=lightblue guibg=darkgray
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=#666666
match ZenkakuSpace /　/


" ###################
" Maps
" ##################

map <C-n> :NERDTreeToggle<CR>
