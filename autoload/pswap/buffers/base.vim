call pswap#modulelib#makeModule(s:, 'base', '')

function! s:f.bufferName() dict abort
    if !exists('t:pswap_tabpageUniqueIdentifier')
        let t:pswap_tabpageUniqueIdentifier = reltimestr(reltime())
    endif
    return printf('Pswap:%s:%s', self.name, t:pswap_tabpageUniqueIdentifier)
endfunction

function! s:f.existingWindowNumber() dict abort
    return bufwinnr('Pswap:')
endfunction

function! s:f.openTuiBuffer(targetWindow) dict abort
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
            let l:window_width = get(g:, 'pswap_windowWidth', 40)
            let l:size = get(g:, 'pswap_windowSize', l:window_width)
            execute l:size.get(g:, 'pswap_splitType', 'v').'new'
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
        
        for l:meta in self._meta
            for l:keymap in l:meta.keymaps
                execute 'nnoremap <buffer> <nowait> '.l:keymap.' :'.l:meta.execute.'<Cr>'
            endfor

            if has_key(l:meta, 'command')
                execute 'command! -buffer -nargs=0 '.l:meta.command.' '.l:meta.execute
            endif
        endfor

        call self.refresh()
    endif

    let b:pswap = self

    "Check and return if a new buffer was created
    return -1 == l:tuiBufferWindow
endfunction

function! s:f.refresh() dict abort
    " NOTE: need to make this global/custom later
    let pswap_paths = ['C:\']
    let l:tuiBufferWindow = self.existingWindowNumber()
    if -1 < l:tuiBufferWindow
        execute l:tuiBufferWindow.'wincmd w'
        setlocal modifiable
        "Clear the buffer:
        silent normal! gg"_dG
        "Write the buffer
        let dirs = self.getFolder(pswap_paths)
        echo dirs
        " let counter = 1
        " for dir in dirs
        "         " call setline(counter, dir)
        "         " let counter = counter + 1
        " endfor
        setlocal nomodifiable
    endif
    " call self.refreshFolder()
endfunction
call s:f.addCommand('refresh', [], 'PswapRefresh', 'r', 'Refresh the buffer')

function! s:f.getFolder(pswap_paths) dict abort
    " let dirs = glob(fnameescape(a:pswap_paths[0]).'/{,.}*/', 1, 1)
    let dirs = glob(fnameescape(a:pswap_paths[0]).'*', 1, 1)
    return dirs
    " return map(dirs, 'fnamemodify(v:val, ":h:t")')
endfunction
