"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible
syntax on "turn on syntax highlighting
set encoding=utf-8

"activate pathogen keep these before configuring plugins
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
"call pathogen#infect()

"load ftplugins and indent files
filetype plugin on
filetype indent on

set background=dark
color molokai              " color scheme

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom
set ruler       "show the cursor position all the time
set number      "show line numbers

"hide buffers when not displayed
set hidden

"display tabs and trailing spaces
set nowrap      "dont wrap lines
"set linebreak   "wrap lines at convenient points
set list        "show invisible characters
set shiftwidth=2 "an autoindent (with <<) is two spaces
set softtabstop=2
set expandtab   "use spaces, not tabs
set autoindent
set backspace=indent,eol,start "allow backspacing over everything in insert mode

"List chars
set listchars=tab:\ \
set listchars+=trail:.
"set listchars+=nbsp:.
set listchars+=extends:> "The character to show in the last column when wrap is off
            "and the line continues beyond the right of the screen
set listchars+=precedes:< "The character to show in the last column when wrap
                            "is off and the lne continues beyond the right of the screen

set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default
set ignorecase  "searches are case insensitive
set smartcase   " ... unless they contain at least one capital letter

function! s:setupWrapping()
  set wrap
  set wrapmargin=2
  set textwidth=72
endfunction

if has("autocmd")
  " In Makefiles, use real tabs, not tabs expanded to spaces
  au FileType make set noexpandtab

  " Make sure all mardown files have the correct filetype set and setup wrapping
  au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn,txt} setf markdown | call s:setupWrapping()

  " Treat JSON files like JavaScript
  au BufNewFile,BufRead *.json set ft=javascript

  " make Python follow PEP8 ( http://www.python.org/dev/peps/pep-0008/ )
  au FileType python set softtabstop=4 tabstop=4 shiftwidth=4 textwidth=79

  " Remember last location in file, but not for commit messages.
  " see :help last-position-jump
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
              \| exe "normal! g`\"" | endif
endif

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

" don't use Ex mode, use Q for formatting
map Q gq

"make <cr> clear the highlight as well as redraw
nnoremap <CR> :nohls<CR><C-L>

let mapleader=','

" Fuzzy file finder
nnoremap <Leader>fc :FufCoverageFile<CR>

"ragtag Ghetto XML/HTML mappings (formerly allml.vim)
let g:ragtag_global_maps = 1

" ack
let g:ackprg="ack-grep -H --nocolor --nogroup --column"

" find merge conflict markers
nmap <silent> <leader>cf <ESC>/\v^[<=>]{7}( .*\|$)<CR>

command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>

" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

set backupdir=~/.vim/_backup " where to put backup files.
set directory=~/.vim/_temp " where to put swap files."

"stora lots of :cmdline history
set history=1000

if v:version >= 703
    "undo settings
    set undodir=~/.vim/undofiles
    set undofile

    set colorcolumn=+1 "mark the ideal max text width
endif

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

set wildmode=list:longest   "make cmdline tab completion similar to bash
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing

set formatoptions-=o "dont continue comments when pushing o/O


"set guifont=DejaVu:Sans:Mono "":h10:cANSI " font

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

"tell the term has 256 colors
set t_Co=256

"statusline setup
set statusline=%f       "tail of the filename

"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

set statusline+=%h      "help file flag
set statusline+=%y      "filetype
set statusline+=%r      "read only flag
set statusline+=%m      "modified flag

"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*

set statusline+=%{StatuslineTrailingSpaceWarning()}

"set statusline+=%{StatuslineLongLineWarning()}

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*
set statusline+=%{fugitive#statusline()}

set statusline+=%=      "left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%v,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
set statusline+=Buf:#%n
set statusline+=[%b][0x%B]
set laststatus=2

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")

        if !&modifiable
            let b:statusline_trailing_space_warning = ''
            return b:statusline_trailing_space_warning
        endif

        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction


"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let b:statusline_tab_warning = ''

        if !&modifiable
            return b:statusline_tab_warning
        endif

        let tabs = search('^\t', 'nw') != 0

        "find spaces that arent used as alignment in the first indent column
        let spaces = search('^ \{' . &ts . ',}[^\t]', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        endif
    endif
    return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
"autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")

        if !&modifiable
            let b:statusline_long_line_warning = ''
            return b:statusline_long_line_warning
        endif

        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction

"syntastic settings
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2

"snipmate settings
let g:snips_author = "Jukka Kaartinen"


"taglist settings
let Tlist_Compact_Format = 1
let Tlist_Enable_Fold_Column = 0
let Tlist_Exit_OnlyWindow = 0
let Tlist_WinWidth = 35
let tlist_php_settings = 'php;c:class;f:Functions'
let Tlist_Use_Right_Window=1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Display_Tag_Scope = 1
let Tlist_Process_File_Always = 1
let Tlist_Show_One_File = 1

"nerdtree settings
let g:NERDTreeMouseMode = 2
let g:NERDTreeWinSize = 40

"explorer mappings
nnoremap <f1> :NERDTreeToggle<cr>
nnoremap <f2> :BufExplorer<cr>
nnoremap <f3> :TlistToggle<cr>

"source project specific config files
runtime! projects/**/*.vim

"dont load csapprox if we no gui support - silences an annoying warning
if !has("gui")
    let g:CSApprox_loaded = 1
endif

"make Y consistent with C and D
nnoremap Y y$

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

" Bubble single lines
nmap <C-Up> [e
nmap <C-Down> ]e

" Bubble multiple lines
vmap <C-Up> [egv
vmap <C-Down> ]egv

if exists(":Tabularize")
  nmap <Leader>t= :Tabularize /=<CR>
  vmap <Leader>t= :Tabularize /=<CR>
  nmap <Leader>t: :Tabularize /:\zs<CR>
  vmap <Leader>t: :Tabularize /:\zs<CR>
endif

inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction

"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'svn\|commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

"spell check when writing commit logs
autocmd filetype svn,*commit* set spell

" for creating c++ tags
nmap <Leader>tc :! ctags --recurse --extra=+fq --c++-kinds=+p --fields=+iaS -h hpp -I --langmap=c++:.h.H..hpp.HPP.inl.INL.cpp.CPP<CR>
nmap <Leader>tr :! ctags --recurse<CR>

"let s:cscope_files = find . -regex ".*\.\(c\|h\|hpp\|cc\|cpp\)" -print
"map <F8> :!ctags -R --totals --c++-kinds=+p --fields=+iaS --extra=+qf .<CR>
map <F8> :!ctags -R --totals --c++-kinds=+px --c-kinds=+px --fields=+iaSn -I --extra=+qf --langmap=c++:.h.H.hpp.inl.INL.cpp.CPP,c:.h.H.c.C<CR>

nmap <F9> :!find . -regex ".*\\.\\(c\\|h\\|hpp\\|cc\\|cpp\\)" > cscope.files<CR>
  \:!cscope -b -i cscope.files -f cscope.out<CR>
  \:cs reset<CR>


"find . -regex ".*\.\(c\|h\|hpp\|cc\|cpp\)" -print | ctags --totals --recurse --extra="+qf" --fields="+i" -L -
"select_files > cscope.files
"ctags -L s:cscope_files
"ctags -e -L cscope_files
"cscope -ub -i cscope_files

set tags=tags;/                                 " recursively serach for tags
set tags+=~/.vim/tags/usr_include_tags
"set tags+=C:\Qt\4.7.1-symbian\src\tags      " Qt (symbian) tags
"set tags+=c:\Qt\Symbian\4.6.3\src\tags      " Qt (symbian) tags
"set tags+=C:\Code\Stadi.tv\Platform\Client\LibProject\tags    " Lame tags
"set tags+=M:\\epoc32\\include\\MCL_tags

" cscope is in autoload/cscope_maps.vim


" When vimrc is edited, reload it
autocmd! bufwritepost vimrc source ~\.vimrc

" a plugin to change between foo.c and foo.h files
if exists(':A')
    nmap <C-a> :A<CR>
endif

" function to strip trailing spaces
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
nmap rs :call <SID>StripTrailingWhitespaces()

fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

let g:gundo_disable=1

" auto remove trailing spaces from these files
autocmd BufWritePre *.h :call <SID>StripTrailingWhitespaces()
autocmd BufWritePre *.cpp :call <SID>StripTrailingWhitespaces()
autocmd BufWritePre *.c :call <SID>StripTrailingWhitespaces()
autocmd BufWritePre *.rb :call <SID>StripTrailingWhitespaces()
autocmd BufWritePre *.haml :call <SID>StripTrailingWhitespaces()

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
"if has("autocmd")
"autocmd BufReadPost *
"            \ if line("'\"") > 1 && line("'\"") <= line("$") |
"            \   exe "normal! g`\"" |
"            \ endif
"else
"  set autoindent		" always set autoindenting on
"endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
"if !exists(":DiffOrig")
"  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
"		  \ | wincmd p | diffthis
"endif

" from mswin.vim
" cut, copy, paste
"vnoremap <C-X> "+x
"vnoremap <C-C> "+y
"map <C-V> "+gP


" tell vim where to put its backup files
"set backupdir=C:\\Temp

" tell vim where to put swap files
"set dir=C:\\Temp

" Pasting blockwise and linewise selections is not possible in Insert and
" Visual mode without the +virtualedit feature.  They are pasted as if they
" were characterwise instead.
" Uses the paste.vim autoload script.
"exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
"exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']
"imap <S-Insert>		<C-V>
"vmap <S-Insert>		<C-V>

" Use CTRL-Q to do what CTRL-V used to do
"noremap <C-Q>		<C-V>

" For CTRL-V to work autoselect must be off.
" On Unix we have two selections, autoselect can be used.
"if !has("unix")
"  set guioptions-=a
"endif

" Own settings

"set langmenu=none

"set background=dark
"set sw=4                    " tab settings
"set ts=4                    " tab settings
"set sts=4                   " tab settings
"set laststatus=2            " status line at bottom
"set statusline+=%{GitBranch()}
":set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]\ [GIT=%{GitBranch()}]


"set showcmd            " Show (partial) command in status line.
"set ignorecase smartcase  " Do case insensitive matching
"set incsearch           " search while typing
"set showmatch          " Show matching brackets.
"set matchtime=3	       " Show match for .3 s
"set number             " show line numbers
"set expandtab          " tabs as spaces
"set cino={1s,f1s,^-s,g0,=0,(s,u0    " S60
"set cino={0s,g0,=0,(s,u0    " S60 Qt
"set cino=g0,=0,(s,u0    " S60 Qt
                        " indent style
                        " {1s indent { one stop
                        " f1s indent function brackets one stop
                        " ^-s indent function content -1 stop
                        " g0 indent scope declr at brace level (public: etc)
                        " =0 { after case not indented
                        " (s first level unclosed parenthesis indented 1 stop
                        " or
                        " (0 first level unclosed parenthesis indented at prev
                        "   line level when continuing on next line
                        " u0 deeper level unclosed parenthesis indented 0
                        "   when continuing on next line
" Symbian indention
" set cinoptions=>s,e0,n0,f0,{1s,}0,^0,:s,=s,l0,b0,gs,hs,ps,ts,is,+s,c3,C0,/0,(2s,us,U0,w0,W0,m0,j0,)20,*30,#0

"set foldmethod=syntax   " fold by syntax
"set foldlevel=20        " folds open by default
"set foldcolumn=2        " margin width for fold markers
"if has('mouse')
"    set mouse=a         " mouse in terminal
"endif
"set wildmenu            " mini menu when tab completing
"set mousefocus          " focus follows mouse, linux style
"set noequalalways       " ~only active split area resizes

"set filetype=on         " required by Taglist plug-in
"filetype plugin on

"set iskeyword-=.
"autocmd FileType python set omnifunc=pythoncomplete#Complete " omni complete for python

"set ofu=syntaxcomplete#Complete

"taglist plug-in
"let Tlist_Show_One_File = 1   " tags for active buffer only
"let Tlist_Sort_Type = "name"  " sort by name

" omni cpp completion plug-in
"let OmniCpp_MayCompleteDot = 0      " no automatic completion for '.'
"let OmniCpp_MayCompleteArrow = 0    " no automatic completion for '->'
"autocmd InsertLeave * if pumvisible() == 0|pclose|endif  " autoclose omni completion preview window

" show filetypes menu
" then can :cal SetSyn("cpp") as done below
"if has("gui_running")
 "   let do_syntax_sel_menu = 1|runtime! synmenu.vim|aunmenu &Syntax.&Show\ filetypes\ in\ menu
"endif



" key mappings
"nmap <M-n> :bn<CR>
"nmap <M-p> :bp<CR>
"nmap <F2> :cp<CR>
"nmap <F3> :cn<CR>
"nmap <F4> :nohls<CR>
"nmap <F5> :cal SetSyn("java")<CR>
"map   <silent> <F5> mmgg=G'm
"imap  <silent> <F5> <Esc> mmgg=G'm
"nmap <F6> :cal SetSyn("cpp")<CR>
"Eclim commands
"noremap <F9> :CSearchleft_arroy
"noremap <F10> :CCallHierarchy

"nmap <leader>v :tabedit $MYVIMRC<CR>
" Source the vimrc file after saving it
"if has("autocmd")
"  autocmd bufwritepost _vimrc source $MYVIMRC
"endif

" NERD tree
"map <F11> :NERDTreeToggle<CR>

"nmap <F12> :TlistToggle<CR>

"nmap ,t <Esc>:tabnew<CR>
"nmap <M-r> :call <SID>StripTrailingWhitespaces()

" Fuzzy file finder
"map <M-f> :FufCoverageFile<CR>

" NERD commenter
"map <M-c> <plug>NERDCommenterTogglej
"map <M-x> <plug>NERDCommenterYankp
"map <M-v> <plug>NERDCommenterMinimal

" helpful macros
" brackets after this line
"inoremap <C-F> o{<CR>}<C-O>O
