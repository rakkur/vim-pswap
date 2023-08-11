call pswap#modulelib#makeModule(s:, 'base', '')

function! s:bufferNameFor(role) abort
    if !exists('t:pswap_tabpageUniqueIdentifier')
        let t:pswap_tabpageUniqueIdentifier = reltimestr(reltime())
    endif
    return printf('Pswap:%s:%s', a:role, t:pswap_tabpageUniqueIdentifier)
endfunction

function! s:f.bufferName() dict abort
    return s:bufferNameFor(self.name)
endfunction

function! s:f.existingWindowNumber() dict abort
    return bufwinnr('Pswap:')
endfunction

function! s:f.openTuiBuffer(targetWindow) dict abort
    let self.fugitiveContext = {
                \ 'git_dir': FugitiveGitDir(),
                \ 'work_tree': FugitiveWorkTree(),
                \ }

    if -1 < a:targetWindow
        let l:tuiBufferWindow = -1
    else
        let l:tuiBufferWindow = self.existingWindowNumber()
    endif

    if -1 < l:tuiBufferWindow "Jump to the already open buffer
        execute l:tuiBufferWindow.'wincmd w'
    else "Open a new buffer
        if -1 < a:targetWindow
            enew
        else
            let l:window_width = get(g:, 'merginal_windowWidth', 40)
            let l:size = get(g:, 'merginal_windowSize', l:window_width)
            execute l:size.get(g:, 'merginal_splitType', 'v').'new'
        endif
        setlocal buftype=nofile
        setlocal bufhidden=wipe
        setlocal nomodifiable
        setlocal winfixwidth
        setlocal winfixheight
        setlocal nonumber
        setlocal norelativenumber
        setlocal filetype=pswap
        execute 'silent file '.self.bufferName()
    endif

    let b:pswap = self

    "Check and return if a new buffer was created
    return -1 == l:tuiBufferWindow
endfunction
