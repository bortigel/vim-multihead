"""""""""""
" Multihead
"

runtime lib/ServerList.vim
runtime lib/MultiheadServer.vim
runtime lib/MultiheadClient.vim
runtime lib/MultiheadPeer.vim

if !exists('g:Multihead')
    let g:Multihead = { 'plugins': {} }
endif

function! g:Multihead.install_plugin( plugin_name )
    exec printf( 'let g:Multihead.plugins["%s"] = g:%s', a:plugin_name, a:plugin_name )
endfunction

function! g:Multihead.create_server()
    let g:Multihead.server = g:MultiheadServer.new()
endfunction

let s:HIT_ENTER          = '<CR>'
let s:ENTER_NORMAL_MODE  = '<C-\><C-n>'
let s:ENTER_COMMAND_MODE = s:ENTER_NORMAL_MODE . ':'

function! g:Multihead.send_expr( server_name, expr )
    let keys = ''

    if len( a:expr )
        let keys = s:ENTER_COMMAND_MODE . a:expr . s:HIT_ENTER
    endif

    call remote_send( a:server_name, keys, 'remote_id' )

    return remote_id
endfunction

function! g:Multihead.ping( server_name )
    return g:Multihead.send_expr( a:server_name, '' )
endfunction

function! g:Multihead.send_output( server_name, output, callback )
    call server2client( g:Multihead.server[a:server_name].client_id, a:output )
    call g:Multihead.send_expr( a:server_name, printf('call %s()', a:callback) )
endfunction

" OLD: {{{
" com! -nargs=1 -complete=customlist,Multihead_connect_completion
"     \ Connect call <SID>connect(<q-args>)

" FIXME
nnoremap <silent> <F1> :call remote_foreground( s:multihead_support_server_name )<CR>
" }}}

" vim: set foldmethod=marker:
