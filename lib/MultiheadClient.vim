"
" CONSTRUCTOR: {{{1
"
let g:MultiheadClient = { 'server_list': ServerList.new() }

function! g:MultiheadClient.new( plugin )
    let client = copy( s:MultiheadClient )
    let client.name = v:servername
    let client.plugin_name = a:plugin

    return g:Multihead.plugins[ a:plugin ].new( client )
endfunction
" }}}

"
" STATIC METHODS: {{{1
"

"
" STATIC: get_server_list {{{2
"
function! g:MultiheadClient.get_server_list( arg_lead )
    return self.server_list.refresh().filter_self().filter_arg_lead( a:arg_lead ).to_list()
endfunction
" }}}

" }}}

"
" METHODS: {{{1
"
let s:MultiheadClient = {}

"
" METHOD: connect {{{2
"
function! s:MultiheadClient.connect( server_name )
    if index( g:MultiheadClient.get_server_list(''), a:server_name ) == -1
        echoerr 'Server "' . a:server_name . '" not found'
        return
    endif

    let self.server = {}
    let self.server.name = a:server_name
    " get_server_id() needs server.name defined, so we need to split definition
    let self.server.id = self.get_server_id()

    return self
endfunction
" }}}

"
" METHOD: get_server_id {{{2
"
function! s:MultiheadClient.get_server_id()
    return g:Multihead.ping( self.server.name )
endfunction
" }}}

"
" METHOD: send_expr {{{2
"
function! s:MultiheadClient.send_expr( expression )
    call g:Multihead.send_expr( self.server.name, a:expression )
endfunction
" }}}

"
" METHOD: install_server_autocommands {{{2
"
function! s:MultiheadClient.install_server_autocommands( events )
    let quoted_event_names = map( a:events, '"''" . v:val . "''"' )
    call self.send_expr( printf("call g:Multihead.server.install_autocommands([%s], '%s', '%s')", join(quoted_event_names, ', '), self.plugin_name, self.name) )
endfunction
" }}}

"
" METHOD: call_plugin_function_on_server {{{2
"
function! s:MultiheadClient.call_plugin_function_on_server( function_string )
    call self.send_expr( printf("call %s.%s", self.plugin_name, a:function_string) )
endfunction
" }}}

" }}}

" vim: set foldmethod=marker:
