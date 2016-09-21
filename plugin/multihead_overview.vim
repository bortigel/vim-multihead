""""""""""""""""""""
" Multihead Overview
"
"
" CONSTRUCTOR: {{{1
"
let Overview = {}

function! Overview.new( multihead_client )
    let overwiew = copy( s:Overview )
    let overwiew.multihead_client = a:multihead_client

    return overwiew
endfunction

call g:Multihead.install_plugin('Overview')
" }}}

"
" STATIC METHODS: {{{1
"

"
" STATIC: notify {{{2
"
function! Overview.notify( client_name, ... )
    call g:Multihead.send_expr( a:client_name, printf('call g:Multihead.Overview.update(%d, %d)', line('.'), winheight(0)) )
endfunction
" }}}

" end of: static methods
" }}}

"
"
" METHODS: {{{1
"
let s:Overview = {}

"
" METHOD: connect {{{2
"
function! s:Overview.connect( server_name )
    call self.multihead_client.connect( a:server_name )
    call self.init()
endfunction
" }}}

"
" METHOD: init {{{2
"
function! s:Overview.init()
    call self.init_options()
    call self.init_highlighting()
    call self.init_autocommands()
endfunction

"
" METHOD: init_options {{{3
"
function! s:Overview.init_options()
    " FIXME font from config
    setlocal guifont=Monospace\ 6
    setlocal noautoread
    setlocal noswapfile
    setlocal nohlsearch
    setlocal noruler
    setlocal noshowcmd
endfunction
" }}}

"
" METHOD: init_highlighting {{{3
"
function! s:Overview.init_highlighting()
    highlight multihead_overview_viewport guibg=#111111
endfunction
" }}}

"
" METHOD: init_autocommands {{{3
"
function! s:Overview.init_autocommands()
    call self.multihead_client.install_server_autocommands(['CursorMoved', 'CursorMovedI'])
endfunction
" }}}

" end of: init
" }}}

"
" METHOD: update {{{2
"
function! s:Overview.update( line_nr, win_height )
    call setpos('.', [0, a:line_nr, 1])
    let start = a:line_nr - a:win_height/2
    let end   = a:line_nr + a:win_height/2

    syntax clear multihead_overview_viewport
    execute printf('syntax region multihead_overview_viewport start=/\%%%dl/ end=/\%%%dl/', start, end )

    redraw
endfunction
" }}}


" end of: methods
" }}}

" vim: set foldmethod=marker:
