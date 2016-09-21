"
" CONSTRUCTOR: {{{1
"
let Workgroup = {}

function! Workgroup.new()
    let workgroup = copy( s:Workgroup )
    return workgroup
endfunction
" }}}

"
" METHODS: {{{1
"
let s:Workgroup = {}
let s:skel = {
    \ 'members': {},
    \ 'buffers': {},
    \ 'registers': {}
\ }

"
" METHOD: create_or_reuse {{{2
"
function! s:Workgroup.create_or_reuse( workgroup_name )
    let self.name = a:workgroup_name

    if ( filereadable(self.get_swap_file_name()) )
        let self.data = self.read_swap()
    else
        let self.data = copy( s:skel )
        call self.dump_swap()
    endif

    return self
endfunction
" }}}

"
" METHOD: parse_swap_data {{{2
"
function! s:Workgroup.parse_swap_data( swap_data )
    let data = {}

    if ( !empty(a:swap_data) )
        let data = eval( a:swap_data[0] )
    endif

    return data
endfunction
" }}}

"
" METHOD: sync {{{2
"
function! s:Workgroup.sync()
    call self.refresh_data()
    call self.dump_swap()
endfunction
" }}}

"
" METHOD: refresh_data {{{2
"
function! s:Workgroup.refresh_data()
    call self.extend_data( self.read_swap() )
endfunction
" }}}

"
" METHOD: read_swap {{{2
"
function! s:Workgroup.read_swap()
    let swap_data = readfile( self.get_swap_file_name() )

    return self.parse_swap_data( swap_data )
endfunction
" }}}

"
" METHOD: dump_swap {{{2
"
function! s:Workgroup.dump_swap()
    call writefile( [string(self.data)], self.get_swap_file_name() )
endfunction
" }}}

"
" METHOD: get_swap_file_name {{{2
"
function! s:Workgroup.get_swap_file_name()
    return printf('%s/.vim-workgroup/%s.swp', $HOME, self.name)
endfunction
" }}}

"
" METHOD: extend_data {{{2
"
function! s:Workgroup.extend_data( swap_data )
    let orig_data = deepcopy( self.data )

    for key in keys( a:swap_data )
        let self.data[key] = a:swap_data[key]

        if has_key( orig_data[key], self.peer )
            " data about ourselves in current object is more valid than in swap file
            let self.data[key][self.peer] = orig_data[key][self.peer]
        endif
    endfor
endfunction
" }}}

"
" METHOD: register {{{2
"
function! s:Workgroup.register( name )
    let self.data.members[ a:name ] = 1
    let self.peer = a:name
endfunction
" }}}

"
" METHOD: unregister {{{2
"
function! s:Workgroup.unregister()
    unlet self.data.members[ self.peer ]
    unlet self.data.buffers[ self.peer ]
endfunction
" }}}

"
" METHOD: add_buffers {{{2
"
function! s:Workgroup.add_buffers( buffer_list )
    let self.data.buffers[ self.peer ] = a:buffer_list
endfunction
" }}}

" }}}

" vim: set foldmethod=marker:
