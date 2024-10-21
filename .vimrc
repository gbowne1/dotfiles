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
set wrap
set backspace=indent,eol,start
set mouse=a
set showmatch
set clipboard+=unnamedplus
set laststatus=2
set nobreakindent
set smartindent
set foldmethod=syntax
set noexpandtab
set nowrap
set nosmartindent
set noautoindent
colorscheme desert
colorscheme solarized
colorscheme gruvbox

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
set expandtab
set autoindent

" Language-specific settings
autocmd FileType markdown setlocal wrap linebreak spell
autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType css setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType jsx setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType python setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType php setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType sql setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType jsonc setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType c setlocal ts=8 sts=8 sw=8 expandtab
autocmd FileType cpp setlocal ts=8 sts=8 sw=8 expandtab
autocmd FileType csharp setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType txt setlocal tw=80
autocmd FileType jquery setlocal ft=javascript
autocmd FileType ajax setlocal ft=javascript

" C# and ASP.NET settings
autocmd FileType cs setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType aspx setlocal ts=4 sts=4 sw=4 expandtab
autocmd FileType ascx setlocal ts=4 sts=4 sw=4 expandtab

" MongoDB and PostgreSQL settings
autocmd FileType javascript setlocal dictionary+=/usr/share/mongodb/mongokeyword
autocmd FileType sql setlocal dictionary+=/usr/share/postgresql/11/sqlwords

" React settings
let g:jsx_ext_required=0

" Python settings
let python_highlight_all=1

" Markdown settings
augroup MarkdownSettings
    autocmd!
    autocmd FileType markdown setlocal wrap linebreak spell
augroup END

" HTML/CSS settings
augroup HtmlCssSettings
    autocmd!
    autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType css setlocal ts=2 sts=2 sw=2 expandtab
augroup END

" JavaScript settings
augroup JavascriptSettings
    autocmd!
    autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType jsx setlocal ts=2 sts=2 sw=2 expandtab
augroup END

" PHP settings
augroup PhpSettings
    autocmd!
    autocmd FileType php setlocal ts=4 sts=4 sw=4 expandtab
augroup END

" SQL settings
augroup SqlSettings
    autocmd!
    autocmd FileType sql setlocal ts=4 sts=4 sw=4 expandtab
    autocmd FileType postgresql setlocal dictionary+=/usr/share/postgresql/11/sqlwords
augroup END

" JSON settings
augroup JsonSettings
    autocmd!
    autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType jsonc setlocal ts=2 sts=2 sw=2 expandtab
augroup END

" C/C++ settings
augroup CppSettings
    autocmd!
    autocmd FileType c setlocal ts=8 sts=8 sw=8 expandtab
    autocmd FileType cpp setlocal ts=8 sts=8 sw=8 expandtab
augroup END

" Text file settings
augroup TextFileSettings
    autocmd!
    autocmd FileType txt setlocal tw=80
augroup END