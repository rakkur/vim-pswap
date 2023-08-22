
let s:f = {}
let s:modules = {}

function! pswap#modulelib#makeModule(namespace, name, parent)
    let s:modules[a:name] = a:namespace
    let a:namespace.f = pswap#modulelib#prototype()
    let a:namespace.moduleName = a:name
    let a:namespace.parent = a:parent
endfunction

function! pswap#modulelib#prototype()
    let l:prototype = copy(s:f)
    let l:prototype._meta = []
    return l:prototype
endfunction

function! s:populate(object, moduleName)
    if !has_key(s:modules, a:moduleName)
      execute 'runtime autoload/pswap/buffers/'.a:moduleName.'.vim'
    endif
    
    let l:module = s:modules[a:moduleName]

    if !empty(l:module.parent)
        call s:populate(a:object, l:module.parent)
    endif
    
    let l:f = l:module.f

    for l:k in keys(l:f)
        if l:k != '_meta' && !has_key(s:f, l:k)
            let a:object[l:k] = l:f[l:k]
        endif
    endfor

    call extend(a:object._meta, l:f._meta)
endfunction

function! s:f.addCommand(functionName, args, command, keymaps, doc) dict abort
    let l:meta = {}

    let l:args = []
    for l:arg in a:args
        call add(l:args, string(l:arg))
    endfor
    let l:meta.execute = 'call b:pswap.'.a:functionName.'('.join(l:args, ', ').')'

    if !empty(a:command)
        let l:meta.command = a:command
    endif

    if empty(a:keymaps)
    elseif type(a:keymaps) == type([])
        let l:meta.keymaps = a:keymaps
    else
        let l:meta.keymaps = [a:keymaps]
    endif

    if !empty(a:doc)
        let l:meta.doc = a:doc
    endif

    "let self._meta[a:functionName] = l:meta
    call add(self._meta, l:meta)
endfunction

function! pswap#modulelib#createObject(moduleName)
    let l:obj = {}
    let l:obj.name = a:moduleName
    let l:obj._meta = []
    call s:populate(l:obj, a:moduleName)
    return l:obj
endfunction


