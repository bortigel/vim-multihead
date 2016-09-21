# vim-multihead
Vim support for communication between multiple frames / heads.

## Installation & Setup
* Drop the files to any of your `runtimepath`s.
* Run multiple gvim instances with `--servername` param given.
* Attach plugins (in your `.vimrc` or by issuing commands manually -- see below for examples).

### Example configuration
* Create shell script:
```bash
#!/bin/bash
gvim --servername MULTIHEAD_TABLIST
gvim --servername MULTIHEAD_SERVER
```

* Add the following snippets to your `.vimrc`:
```vim
au VimEnter * call SetupMultihead()

function! SetupMultihead()
    if v:servername == 'MULTIHEAD_SERVER'
        call g:Multihead.create_server()
        call g:Multihead.server.attach('MULTIHEAD_TABLIST', 'Tablist')
    endif
endfunction
```

The method `server.attach()` accepts two parameters, gvim server name to attach to (here: `'MULTIHEAD_TABLIST'`), and plugin name which this server will act as (`'Tablist'`).

* Start gvim instances via shell script created above and you should now see a list of tabs & buffers of the main gvim window (`'MULTIHEAD_SERVER'`) in the support window (`'MULTIHEAD_TABLIST'`).


## Demo plugins description

### Tablist
**Requires**: two instances (main & support).

**Provides**: list of tabs & buffers of the main gvim window in the support window.

**Notes**: Included in this package. Beta version, pretty much usable.

### Overview
**Requires**: two instances (main & support).

**Provides**: Sublime-like overview of a file.

**Notes**: Included in this package. Alpha version, the same file has to open manually in both windows.

### Workgroup
**Requires**: at least two instances (peer to peer).

**Provides**: Sharing buffers across workgroup members. Ability to easily open buffers jumping from one gvim instance to another.

**Notes**: Included in this package. Setup is slightly different, see below.

**Setup**:
* create `~/.vim-workgroup` directory
* on each gvim call the following:
```
:let MHPeer = MultiheadPeer.new()
:call MHPeer.join_workgroup('workgroup_name')
```
* to open buffer from workgroup, call (dialogue will appear):
```
:call MHPeer.open_buffer()
```

### MarksBrowser
**Requires**: two instances (main & support).

**Provides**: Marks Browser plugin in detached window.

**Notes**: Beta version, basic usability. Available from [here](https://github.com/bortigel/Marks-Browser).

### Taglist
**Requires**: two instances (main & support).

**Provides**: Taglist plugin in detached window.

**Notes**: Beta version, basic usability. Available from [here](https://github.com/bortigel/taglist.vim).

### NERDTreeMH
**Requires**: two instances (main & support).

**Provides**: NERDTree plugin in detached window.

**Notes**: Beta version, basic usability. Available from [here](https://github.com/bortigel/Marks-Browser).
