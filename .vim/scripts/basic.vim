" Disable vi compatibility
set nocompatible

" 履歴の上限を200にする
set history=200

" ヤンクでクリップボードにコピー
set clipboard=unnamed,autoselect

" ステータスラインを表示する
set laststatus=2

" Beep音を鳴らさない
set belloff=all

" swapファイルを作らない
set noswapfile

set backspace=indent,eol,start

""""""""""""""""""""""""""""""
" color schema
""""""""""""""""""""""""""""""
syntax enable
set background=dark
colorscheme solarized
