set nocompatible
set number
set ruler
set relativenumber
set encoding=utf-8
set fileformat=unix
set nobackup
set nowritebackup
set updatetime=300
set shortmess+=c
set cursorline
set incsearch
set ignorecase
set smartcase
set hlsearch
set cursorline
set wildmenu
set showcmd
set showmode 
set hidden
set wrap
set backspace=indent,eol,start
set mouse=a
set showmatch
set clipboard+=unnamedplus
set laststatus=2
set nobreakindent
set smartindent
set foldmethod=syntax
set foldlevelstart=99
colorscheme desert

" Enable COC for autocompletion
autocmd BufEnter * silent! :CocCommand eslint.executeAutofix

" Set syntax highlighting for various file types
filetype plugin indent on
syntax on

" Enable spell checking
set spell

" Set the tabstop and softtabstop to 4 spaces
set tabstop=4
set softtabstop=4

" Set the shiftwidth to 4 spaces for consistent indentation
set shiftwidth=4

" Use spaces for indentation instead of tabs
set expandtab

" Automatically indent new lines
set autoindent

" Set the filetype plugin to automatically detect file types
filetype plugin on

" Set the syntax highlighting to on
syntax on

" Set the spell checking to on
set spell

" Set the tabstop and softtabstop to 4 spaces
set tabstop=4
set softtabstop=4

" Set the shiftwidth to 4 spaces for consistent indentation
set shiftwidth=4

" Use spaces for indentation instead of tabs
set expandtab

" Automatically indent new lines
set autoindent

" Set up syntax highlighting for Markdown
filetype indent on
syntax on
au BufNewFile,BufRead *.md set ft=markdown

" Set up syntax highlighting for HTML5
filetype indent on
syntax on
au BufNewFile,BufRead *.html set ft=html5

" Set up syntax highlighting for CSS3
filetype indent on
syntax on
au BufNewFile,BufRead *.css set ft=css3

" Set up syntax highlighting for PHP
filetype indent on
syntax on
au BufNewFile,BufRead *.php set ft=php

" Set up syntax highlighting for JavaScript (ES7/ES2016)
filetype indent on
syntax on
au BufNewFile,BufRead *.js set ft=javascript

" Set up syntax highlighting for SQL
filetype indent on
syntax on
au BufNewFile,BufRead *.sql set ft=sql

" Set up syntax highlighting for JSON
filetype indent on
syntax on
au BufNewFile,BufRead *.json set ft=json

" Set up syntax highlighting for JSONC
filetype indent on
syntax on
au BufNewFile,BufRead *.jsonc set ft=jsonc

" Markdown Settings
autocmd FileType markdown setlocal wrap
autocmd FileType markdown setlocal linebreak
autocmd FileType markdown setlocal spell

" HTML/CSS Settings
autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType css setlocal ts=2 sts=2 sw=2 expandtab

" JavaScript Settings
autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType jsx setlocal ts=2 sts=2 sw=2 expandtab

" PHP Settings
autocmd FileType php setlocal ts=4 sts=4 sw=4 expandtab

" SQL Settings
autocmd FileType sql setlocal ts=4 sts=4 sw=4 expandtab

" JSON Settings
autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType jsonc setlocal ts=2 sts=2 sw=2 expandtab

" Python Settings
autocmd FileType python setlocal ts=4 sts=4 sw=4 expandtab
let python_highlight_all=1

" React Settings
autocmd FileType jsx setlocal ts=2 sts=2 sw=2 expandtab

" PostgreSQL Settings
autocmd FileType sql setlocal dictionary+=/usr/share/postgresql/11/sqlwords

" MongoDB Settings
autocmd FileType javascript setlocal dictionary+=/usr/share/mongodb/mongokeyword