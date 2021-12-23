" Luke Smith vimrc -> https://github.com/LukeSmithxyz/voidrice/blob/archi3/.config/nvim/init.vim
" Minimal .vimrc for C/C++ Developers -> https://gist.github.com/rocarvaj/2513367

set nocompatible
set wildmenu
filetype off
set background=dark

"" Spell Checking
autocmd BufRead,BufNewFile *.md,*.tex,*.txt setlocal spell
set complete+=kspell
set clipboard=unnamedplus

call plug#begin('~/.vim/plugged')


" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Python
"Plug 'vim-scripts/indentpython.vim'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'vim-python/python-syntax'
Plug 'skywind3000/vim-rt-format'
Plug 'Chiel92/vim-autoformat'

Plug 'nathanaelkane/vim-indent-guides'

" Ease of use
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'dkarter/bullets.vim'
Plug 'tomasiser/vim-code-dark'
Plug 'chrisbra/csv.vim'
Plug 'vim-scripts/visSum.vim'

" C++

Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'rhysd/vim-clang-format'
Plug 'webastien/vim-ctags' 

" Flex and Bison
Plug 'justinmk/vim-syntax-extra'

" Rust
Plug 'rust-lang/rust.vim'
Plug 'dense-analysis/ale'
Plug 'sheerun/vim-polyglot'


" APL
Plug 'PyGamer0/vim-apl'

" LaTeX
Plug 'xuhdev/vim-latex-live-preview'
Plug 'lervag/vimtex'

" HTML

" live preview for html
Plug 'turbio/bracey.vim'
" provides support for expanding abbreviations
Plug 'mattn/emmet-vim'
Plug 'alvan/vim-closetag'
Plug 'prettier/vim-prettier'
Plug 'tpope/vim-markdown'

" JavaScript
"
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'

call plug#end()

"syntax on
syntax enable
set t_Co=256
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
let g:python_highlight_all = 1

autocmd FileType vim let b:vcm_tab_complete = 'vim'
autocmd BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc

" HTML Formatting

let g:closetag_filenames = '*.html,*.xhtml,*.phtml'
let g:prettier#config#bracket_spacing = 'true'
let g:prettier#config#jsx_bracket_same_line = 'false'

let g:prettier#autoformat = 0
au BufWrite *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.vue PrettierAsync

" Used for looking up a header for C++

function GetVisualSelection()
    " Why is this not a built-in Vim script function?!
    " Credits: https://stackoverflow.com/a/6271254
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return lines[0]
endfunction

function OpenCPPSourceFile()
    let fileName = GetVisualSelection()
    let structure = matchlist(fileName, '\w\+\:\:\(\w\+\)')[1]
    "let path = matchlist(fileName, '\w\+')
    exe 'vsplit ' . '/usr/include/c++/10.2.0/' . structure
    "if(structure)
    "endif

endfunction

function OpenCSSDocumentation()
    let FunctionName = GetVisualSelection()
    let baseUrl = "https://developer.mozilla.org/en-US/docs/Web/CSS/"
    exe "!firefox " . baseUrl . FunctionName

endfunction

"autocmd BufRead,BufNewFile * setlocal tabstop=2 shiftwidth=2
" :set tabstop=2 shiftwidth=2 expandtab | retab
set number
set encoding=utf-8
set termencoding=utf-8
"let g:F = s:get_visual_selection()

"setlocal get_visual=get_visual_selection

set showmatch
set incsearch

" Abbreviations
ab WQ wq
ab Wq wq
ab W  w
ab Q  q
ab Wqal wqal
ab WQal wqal
ab wQal wqal


" Moving through the files
inoremap <S-Tab> <C-d>
nnoremap <S-Tab> <<
inoremap <Tab> <C-t>
nnoremap <Tab> >>

" Copy/Paste Functionality

let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
    set pastetoggle=<Esc>[201~
    set paste
    return ""
endfunction

" Text Processing
"
nnoremap ` @a
vnoremap . :normal .<CR>
vnoremap ` :normal @a<CR>

" PROGRAMMING

" Make run from Vim (gcc, clang, jcomp, pdflatex)

set autowrite

autocmd FileType c,cpp nnoremap <buffer> <C-c> :!clear && c_lang_make_run % <Enter>
autocmd FileType rust nnoremap <buffer> <C-c> :!clear && cargo build && cargo run <Enter>
"autocmd FileType c,cpp nnoremap <buffer> <C-c> :!clear && bettens_build % <Enter>
autocmd FileType tex nnoremap <buffer> <C-c> :LLPStartPreview <Enter>
autocmd FileType tex nnoremap <buffer> <C-e> :!clear && make_run_latex "%" <Enter>
autocmd FileType java nnoremap <buffer> <C-c> :!clear && jcomp % <Enter>
autocmd FileType go nnoremap <buffer> <C-c> :!clear && go run % <Enter>

" C/C++ Formatting
autocmd FileType c,cpp nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp vnoremap <buffer><Leader>cf :ClangFormat<CR>
autocmd FileType c,cpp vnoremap <buffer><Leader>lf :call OpenCPPSourceFile() <CR>
autocmd FileType c,cpp vnoremap <buffer><S-l> :call OpenCPPSourceFile() <CR>
nmap <Leader>C :ClangFormatAutoToggle<CR>
au BufWrite *.rs :RustFmt
"au BufWritePost *.c,*.cpp,*.h silent! !ctags -R &

" Python

autocmd FileType python nnoremap <buffer> <C-c> :!clear && chmod +x "%" && python_run % <Enter>
autocmd FileType python nnoremap <buffer> <C-e> :!clear && python_syntax % <Enter>
autocmd FileType python map <buffer> <C-p> :call flake8#Flake8()<CR>
au BufWrite *.py :Autoformat

autocmd FileType cs nnoremap <buffer> <C-c> :!clear && c_sharp_compile % <Enter>

" Web developement
autocmd FileType html nnoremap <buffer> <C-c> :Bracey <Enter>
autocmd FileType php nnoremap <buffer> <C-c> :!clear && php -f % <Enter>
autocmd FileType javascript nnoremap <buffer> <C-c> :! clear && node % <Enter>
autocmd FileType typescript,typescriptcommon,typescriptreact nnoremap <buffer> <C-c> :! clear && ts-node % <Enter>

" Statistics
autocmd FileType r nnoremap <buffer> <C-c> :!clear && r_stat_run % <Enter>

" CSS
autocmd FileType css vnoremap <buffer><Leader>lf :call OpenCSSDocumentation() <CR>

" Text processing
autocmd FileType rmd nnoremap <buffer> <C-c> :!clear && compile_r_markdown % <Enter>
autocmd FileType rmd,markdown nnoremap <buffer> <C-c> :!clear && mdserver % <Enter>
autocmd FileType rmd,markdown nnoremap <buffer> <C-f> :!clear && formulate % <Enter>
autocmd FileType markdwon nnoremap <buffer> :w <CR> :! echo "Hello" <Enter>
autocmd FileType text nnoremap <buffer> <C-c> :! clear && compile_plain_text % <Enter>


" C++ Code formatting
autocmd FileType cpp set tabstop=2
autocmd FileType cpp set shiftwidth=2

" Python Code formatting

let g:flake8_show_in_file=1
let g:flake8_quickfix_location="vertical topleft"
let g:flake8_quickfix_height=75

" WORD PROCESSING

" LaTeX

let g:livepreview_previewer = 'xreader'

" Navigating with guides
inoremap <leader><leader> <Esc>/<++><Enter>"_c4l
vnoremap <leader><leader> <Esc>/<++><Enter>"_c4l
map <leader><leader> <Esc>/<++><Enter>"_c4l

inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

" Fix misspelled words automatically
imap <c-l> <c-g>u<Esc>[s1z=`]a<c-g>u

inoremap <silent><expr> <TAB>
\ pumvisible() ? "\<C-n>" : "\<TAB>"

filetype plugin indent on
autocmd FileType tex,rmd,markdown exec("setlocal dictionary+=".$HOME."/.vim/dictionaries/".expand('<amatch>'))
set completeopt=menuone,longest,preview
set complete+=k

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        "return "\<c-p>"
        return "\<c-n>"
    endif
endfunction

inoremap <expr> <tab> InsertTabWrapper()
"inoremap <s-tab> <c-n>


let g:bullets_enabled_file_types = [
    \ 'markdown',
    \ 'text',
    \ 'tex'
\]

" Remember last position when exiting
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

