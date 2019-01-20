" ------------------------------
" NERDTree
" ------------------------------
map <C-n> :NERDTreeToggle<CR>

let NERDTreeShowHidden = 1

" Open vim without arguments, start NERDTree,
" If there is an argument NERDTree will not start
autocmd vimenter * if !argc() | NERDTree | endif

" Close if NERDTree is open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" ------------------------------
" vim-devicons
" ------------------------------
let g:webdevicons_conceal_nerdtree_brackets = 1
let g:WebDevIconsNerdTreeAfterGlyphPadding = ' '
let g:webdevicons_conceal_nerdtree_brackets = 1

" dir-icons
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1
let g:WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol = ''
let g:DevIconsDefaultFolderOpenSymbol = ''
" file-icons
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {}
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['html'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['css'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['md'] = ''
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['txt'] = ''

" ------------------------------
" vim-airline
" ------------------------------
"let g:airline_theme = 'solarized'
let g:airline_theme = 'molokai'
let g:airline_solarized_bg='dark'

" ------------------------------
" vim-go
" ------------------------------
let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1

" ------------------------------
" molokai
" ------------------------------
let g:rehash256 = 1
let g:molokai_original = 1

" ------------------------------
" gocode
" ------------------------------
let g:go_gocode_unimported_packages = 1

" ------------------------------
" deoplete
" ------------------------------
let g:deoplete#enable_at_startup = 1
