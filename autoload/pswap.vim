function! pswap#openPswapBuffer() abort
    if exists('b:pswap')
        let l:targetWindow = winnr()
    else
        let l:targetWindow = -1
    endif
    call pswap#modulelib#createObject('projects').openTuiBuffer(l:targetWindow)
endfunction
