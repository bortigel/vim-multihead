"
" CONSTRUCTOR: {{{1
"
let ServerList = {}

function! ServerList.new()
    let server_list = copy( s:ServerList )
    return server_list.refresh()
endfunction
" }}}

"
" METHODS: {{{1
"
let s:ServerList = {}

"
" METHOD: refresh {{{2
"
function! s:ServerList.refresh()
    let self.servers = split( serverlist(),'\n' )

    return self
endfunction
" }}}

"
" METHOD: filter_self {{{2
"
function! s:ServerList.filter_self()
    let self_index = index( self.servers, v:servername )

    if self_index >= 0
        call remove( self.servers, self_index )
    endif

    return self
endfunction
" }}}

"
" METHOD: filter_arg_lead {{{2
"
function! s:ServerList.filter_arg_lead( arg_lead )
    if len( a:arg_lead )
        call filter( self.servers, 'v:val =~ "^' . a:arg_lead . '"' )
    endif

    return self
endfunction
" }}}

"
" METHOD: to_list {{{2
"
function! s:ServerList.to_list()
    return self.servers
endfunction
" }}}

" }}}

" vim: set foldmethod=marker:
