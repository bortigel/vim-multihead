"
" CONSTRUCTOR: {{{1
"
let MultiheadServer = {}

function! MultiheadServer.new()
    let server = copy( s:MultiheadServer )
    let server.name = v:servername

    return server
endfunction
" }}}

"
" METHODS: {{{1
"
let s:MultiheadServer = {}

"
" METHOD: attach {{{2
"
function! s:MultiheadServer.attach( client, plugin )
    call self.create_plugin( a:client, a:plugin )
    call self.connect_plugin( a:client, a:plugin )
endfunction
" }}}

"
" METHOD: create_plugin {{{2
"
function! s:MultiheadServer.create_plugin( client, plugin )
    let expression = printf('let g:Multihead.%s = g:MultiheadClient.new("%s")', a:plugin, a:plugin)
    call g:Multihead.send_expr( a:client, expression )
endfunction
" }}}

"
" METHOD: connect_plugin {{{2
"
function! s:MultiheadServer.connect_plugin( client, plugin )
    let expression = printf('call g:Multihead.%s.connect("%s")', a:plugin, self.name)
    let client_id = g:Multihead.send_expr( a:client, expression )
    let self[a:client] = { 'client_id': client_id }
endfunction
" }}}

"
" METHOD: install_autocommands {{{2
"
function! s:MultiheadServer.install_autocommands( events, plugin_name, client_name )
    execute printf('augroup multihead_%s', a:client_name)
        for event in a:events
            execute printf('autocmd %s * call %s.notify("%s", "%s")', event, a:plugin_name, a:client_name, event)
        endfor
    augroup END
endfunction
" }}}

" }}}

" vim: set foldmethod=marker:
