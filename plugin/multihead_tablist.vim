"""""""""""""""""""
" Multihead Tablist
"
"
" CONSTRUCTOR: {{{1
"
let Tablist = {}

function! Tablist.new( multihead_client )
    let tablist = copy( s:Tablist )
    let tablist.multihead_client = a:multihead_client

    return tablist
endfunction

call g:Multihead.install_plugin('Tablist')
" }}}

"
" STATIC METHODS: {{{1
"

"
" STATIC: get_tabs {{{2
"
function! Tablist.get_tabs()
    redir => output
    silent tabs
    silent echo "\n"
    silent ls
    redir END

    return output
endfunction
" }}}

"
" STATIC: init_server_options {{{2
"
function! Tablist.init_server_options()
    set showtabline=0
    redraw
endfunction
" }}}

"
" STATIC: notify {{{2
"
function! Tablist.notify( client_name, ... )
    call g:Multihead.send_output( a:client_name, g:Tablist.get_tabs(), 'g:Multihead.Tablist.update' )
endfunction
" }}}

" end of: static methods
" }}}

"
" METHODS: {{{1
"
let s:Tablist = {}

"
" METHOD: connect {{{2
"
function! s:Tablist.connect( server_name )
    call self.multihead_client.connect( a:server_name )
    call self.init()
    call self.ask_for_update()
endfunction
" }}}

"
" METHOD: init {{{2
"
function! s:Tablist.init()
    call self.init_options()
    call self.init_highlighting()
    call self.init_mappings()
    call self.init_autocommands()
endfunction

"
" METHOD: init_options {{{3
"
function! s:Tablist.init_options()
    setlocal showtabline=0
    setlocal noautoread
    setlocal noswapfile
    setlocal nohlsearch
    setlocal noruler
    setlocal noshowcmd

    call self.init_server_options()
endfunction
" }}}

"
" METHOD: init_server_options {{{3
"
function! s:Tablist.init_server_options()
    call self.multihead_client.call_plugin_function_on_server('init_server_options()')
endfunction
" }}}

"
" METHOD: init_highlighting {{{3
"
function! s:Tablist.init_highlighting()
    syntax clear
    syntax match multihead_tabs_tab_header /^[A-Z]\w\+ \d\+/
    syntax match multihead_tabs_tab_current /^> .*/
    syntax match multihead_tabs_buf_current /^\s\+\d\+[ u]%.*/
    syntax match multihead_tabs_buf_previous /^\s\+\d\+[ u]#.*/

    highlight default link multihead_tabs_tab_header Title
    highlight default link multihead_tabs_tab_current Tag
    highlight default link multihead_tabs_buf_current Tag
    highlight default link multihead_tabs_buf_previous Directory
endfunction
" }}}

"
" METHOD: init_mappings {{{3
"
function! s:Tablist.init_mappings()
    nnoremap <buffer> <silent> <CR> :call g:Multihead.Tablist.switch_tab_on_server()<CR>
endfunction
" }}}

"
" METHOD: init_autocommands {{{3
"
function! s:Tablist.init_autocommands()
    call self.multihead_client.install_server_autocommands(['BufEnter', 'BufDelete'])
endfunction
" }}}

" end of: init
" }}}

"
" METHOD: update {{{2
"
function! s:Tablist.update()
    let tablist = remote_read( self.multihead_client.server.id )
    call self.replace_buffer_contents( tablist )
endfunction
" }}}


"
" METHOD: ask_for_update {{{2
"
function! s:Tablist.ask_for_update()
    call self.multihead_client.call_plugin_function_on_server( printf('notify("%s")', self.multihead_client.name) )
endfunction
" }}}
"
" METHOD: replace_buffer_contents {{{2
"
function! s:Tablist.replace_buffer_contents( new_content )
    silent % delete _
    silent put =a:new_content
    silent 1,3 delete _
    execute "silent normal! />\<CR>"
    redraw
endfunction
" }}}

function! s:Tablist.switch_tab_on_server()
    let bufnr = matchstr( getline('.'), '^\s\+\zs\d\+\ze' )
    let server_name = self.multihead_client.server.name
    if len( bufnr )
        call remote_send(server_name, ':silent b ' . bufnr . '<CR>')
    else
        call search('\d\+', 'b')
        let tabnr = expand("<cword>")
        call remote_send(server_name, ':silent tabn' . tabnr . '<CR>')
    endif

    call remote_foreground(server_name)
endfunction

" vim: set foldmethod=marker:
