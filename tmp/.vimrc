set nocompatible
set t_Co=256
syntax enable
set number

set ai
set tabstop=4
set shiftwidth=4
set cursorline
set cursorcolumn
color better-molokai
" colorscheme sublimemonokai

set statusline=
set statusline+=\ %F\ %M\ %Y\ %R " Status line left side.
set statusline+=%=  " Use a divider to separate the left side from the right side.
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%  " Status line right side.
set laststatus=2 " Show the status on the second to last line.
set cursorline
set cursorcolumn


" === Set HighLight for keywords
fun! SetMyTypes()
"    syn match myTypes /\%(String\)\|\%(string\)/
"    syn match myTypes /\%(String\)\|\%(string\)\|\%(vector\)\|\%(map\)\|\%(array\)/
"    hi link myTypes Type
    syn keyword myType String string
    syn keyword myObj1 map vector
    hi link myType Type
    hi link myObj1 Structure
endfu
autocmd bufenter * :call SetMyTypes()
autocmd filetype * :call SetMyTypes()
" ===

" === New command echo synIDattr(synID(line("."), col("."), 1), "name")
command! SynName  echo synIDattr(synID(line("."), col("."), 1), "name")

" let g:sublimemonokai_term_italic = 1
" let g:airline_powerline_fonts = 1 "Включить поддержку Powerline шрифтов
" let g:airline#extensions#keymap#enabled = 0 "Не показывать текущий маппинг
" let g:airline_section_z = "\ue0a1:%l/%L Col:%c" "Кастомная графа положения курсора
" let g:Powerline_symbols='unicode' "Поддержка unicode
" let g:airline#extensions#xkblayout#enabled = 0 "Про это позже расскажу

" === Plugins will be downloaded under the specified directory.
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
" Declare the list of plugins.
"Plug 'tpope/vim-sensible'
"Plug 'junegunn/seoul256.vim'
"Plug 'crusoexia/vim-monokai'
Plug 'erichdongubler/vim-sublime-monokai'
Plug 'vim-airline/vim-airline'
" List ends here. Plugins become visible to Vim after this call.
call plug#end()
" ===
