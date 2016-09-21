runtime lib/Workgroup.vim

"
" CONSTRUCTOR: {{{1
"
let g:MultiheadPeer = {}

function! g:MultiheadPeer.new()
    let peer = copy( s:MultiheadPeer )
    let peer.name = v:servername

    return peer
endfunction
" }}}

"
" METHODS: {{{1
"
let s:MultiheadPeer = {}

"
" METHOD: join_workgroup {{{2
"
function! s:MultiheadPeer.join_workgroup( workgroup_name )
    let self.workgroup = g:Workgroup.new().create_or_reuse( a:workgroup_name )
    call self.workgroup.register( self.name )
    call self.setup_events()
    call self.publish()
endfunction
" }}}

"
" METHOD: setup_events {{{2
"
function! s:MultiheadPeer.setup_events()
    execute printf('augroup Workgroup_%s', self.workgroup.name)
        let buffer_events = ['BufAdd', 'BufDelete']
        execute printf('autocmd %s * call MHPeer.publish()', join(buffer_events, ',') )
        autocmd VimLeave * call MHPeer.leave_workgroup()
    augroup END
endfunction
" }}}

"
" METHOD: clear_events {{{2
"
function! s:MultiheadPeer.clear_events()
    execute printf('augroup Workgroup_%s', self.workgroup.name)
        autocmd!
    augroup END
    execute printf('augroup! Workgroup_%s', self.workgroup.name)
endfunction
" }}}

"
" METHOD: publish {{{2
"
function! s:MultiheadPeer.publish()
    call self.workgroup.add_buffers( self.get_buffer_list() )
    call self.workgroup.sync()
    call self.notify_workgroup()
endfunction
" }}}

"
" METHOD: notify_workgroup {{{2
"
function! s:MultiheadPeer.notify_workgroup()
    for member in keys( self.workgroup.data.members )
        if member == self.name
            continue
        endif
        call g:Multihead.send_expr( member, 'call MHPeer.workgroup.refresh_data()' )
    endfor
endfunction
" }}}

"
" METHOD: leave_workgroup {{{2
"
function! s:MultiheadPeer.leave_workgroup()
    call self.clear_events()
    call self.workgroup.refresh_data()
    call self.workgroup.unregister()
    call self.workgroup.dump_swap()
    call self.notify_workgroup()
    let self.workgroup = {}
endfunction
" }}}

"
" METHOD: open_buffer {{{2
"
function! s:MultiheadPeer.open_buffer()
    let buffer_list = self.get_buffer_list_for_dialog()
    let dialog_list = []
    let i = 1

    for buffer in buffer_list
        call add( dialog_list, printf("%d. %s [%s]", i, buffer.buffer_name, buffer.peer_name) )
        let i = i + 1
    endfor

    " call inputsave()
    let chosen_number = inputlist( ['Open buffer:'] + dialog_list )
    " call inputrestore()

    if ( chosen_number > 0 && chosen_number <= len(buffer_list) )
        let selected_buffer = buffer_list[ chosen_number - 1 ]
        if ( selected_buffer.peer_name == self.name )
            call l9#moveToBufferWindowInOtherTabpage( selected_buffer.buffer_number )
        else
            call g:Multihead.send_expr( selected_buffer.peer_name, printf('call l9#moveToBufferWindowInOtherTabpage(%d)', selected_buffer.buffer_number) )
            call g:Multihead.send_expr( selected_buffer.peer_name, 'call foreground()' )
        endif
    endif
endfunction
" }}}

"
" METHOD: get_buffer_list {{{2
"
function! s:MultiheadPeer.get_buffer_list()
    return self.parse_raw_buffer_list( self.get_raw_buffer_list() )
endfunction
" }}}

"
" METHOD: get_raw_buffer_list {{{2
"
function! s:MultiheadPeer.get_raw_buffer_list()
    redir => output
    silent buffers
    redir END

    return split( output, "\n" )
endfunction
" }}}

"
" METHOD: parse_raw_buffer_list {{{2
"
function! s:MultiheadPeer.parse_raw_buffer_list( raw_list )
    let parsed_list = {}

    for entry in a:raw_list
        let id = matchstr( entry, '^\s\+\zs\d\+\ze' )
        let file_name = matchstr( entry, '"\zs.\+\ze"' )
        let parsed_list[ id ] = file_name
    endfor

    return parsed_list
endfunction
" }}}

"
" METHOD: get_buffer_list_for_dialog {{{2
"
function! s:MultiheadPeer.get_buffer_list_for_dialog()
    let buffer_list = []
    for [peer, buffers_per_member] in items( self.workgroup.data.buffers )
        for [id, file_name] in items( buffers_per_member )
            call add( buffer_list, { 'peer_name': peer, 'buffer_number': id+0, 'buffer_name': file_name } )
        endfor
    endfor

    return buffer_list
endfunction
" }}}

" }}}

" vim: set foldmethod=marker:
