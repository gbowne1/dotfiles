set errorbells
set nocompatible
set number
set ruler
set relativenumber
set encoding=utf-8
set fileformat=unix
set nobackup
set nowritebackup
set history=1000
set display=lastline
set updatetime=300
set shortmess+=c
set cursorline
set incsearch
set ignorecase
set smartcase
set hlsearch
set wildmenu
set showcmd
set showmode
set hidden
set nowrap
set backspace=indent,eol,start
set mouse=a
set showmatch
set clipboard+=unnamedplus
set laststatus=2
set nobreakindent
set smartindent
set foldmethod=syntax
set expandtab
set autoindent

" Color scheme
colorscheme solarized

" Enable COC for autocompletion
autocmd BufEnter * silent! :CocCommand eslint.executeAutofix

" Set filetype plugin and syntax highlighting
filetype plugin indent on
syntax on

" Enable spell checking
set spell

" Tab and indentation settings
set tabstop=4
set softtabstop=4
set shiftwidth=4

" Language-specific settings
augroup LanguageSettings
    autocmd!
    autocmd FileType markdown setlocal wrap linebreak spell
    autocmd FileType html,css,xml setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType javascript,jsx setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType python,php,sql setlocal ts=4 sts=4 sw=4 expandtab
    autocmd FileType json,jsonc setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType c,cpp setlocal ts=8 sts=8 sw=8 expandtab
    autocmd FileType txt setlocal tw=80
    autocmd FileType jquery,ajax setlocal ft=javascript
    autocmd FileType cs,aspx,ascx setlocal ts=4 sts=4 sw=4 expandtab
    autocmd FileType postgresql setlocal dictionary+=/usr/share/postgresql/11/sqlwords
augroup END

" MongoDB settings
autocmd FileType javascript setlocal dictionary+=/usr/share/mongodb/mongokeyword

" React settings
let g:jsx_ext_required=0

" Python settings
let python_highlight_all=1
