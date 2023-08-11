
let s:f = {}
let s:modules = {}

function! pswap#modulelib#makeModule(namespace, name, parent)
    let s:modules[a:name] = a:namespace
    let a:namespace.f = merginal#modulelib#prototype()
    let a:namespace.moduleName = a:name
    let a:namespace.parent = a:parent
    
    echo a:namespace
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

function! pswap#modulelib#createObject(moduleName)
    let l:obj = {}
    let l:obj.name = a:moduleName
    let l:obj._meta = []
    call s:populate(l:obj, a:moduleName)
    return l:obj
endfunction


