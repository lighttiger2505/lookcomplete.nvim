function! Log(msg) abort
    let logfile = '/home/lighttiger2505/lookcomplete.log'
    call writefile([a:msg], logfile, 'a')
endfunction

setl completeopt=menuone,noinsert,noselect

augroup autocomplete
    autocmd!
    autocmd InsertEnter  * call s:on_insert_enter()
    autocmd InsertLeave  * call s:on_insert_leave()
    autocmd TextChangedI * call s:on_text_changed_i()
augroup END

function! s:on_insert_enter() abort
    let s:previous_position = getcurpos()
endfunction

function! s:on_insert_leave() abort
    unlet s:previous_position
endfunction

function! s:on_text_changed_i() abort
    let l:previous_position = s:previous_position
    let s:previous_position = getcurpos()
    if l:previous_position[1] ==# getcurpos()[1]
        let l:curpos = getcurpos()
        let l:lnum = l:curpos[1]
        let l:col = l:curpos[2]
        let l:typed = strpart(getline(l:lnum), 0, l:col-1)

        let l:kw = matchstr(l:typed, '\w\+$')
        let l:kwlen = len(l:kw)
        if l:kwlen < 1
            return
        endif
        let l:startcol = l:col - l:kwlen

        call s:update_pum(l:col, l:startcol, l:typed, l:kw)
    endif
endfunction

function! s:get_source(typed) abort
    let l:cmd = 'look ' . a:typed
    let l:res = system(cmd)
    let l:words = split(l:res, '\n')
    return l:words
endfunction

function! s:update_pum(col, startcol, typed, kw) abort
    let l:items = []

    let l:words = s:get_source(a:kw)
    for l:item in l:words
        let l:startcol = a:startcol
        let l:base = a:typed[l:startcol - 1:]
        if stridx(l:item, l:base) == 0
            call add(l:items, l:item)
        endif
    endfor

    call Log('complete, typed:' . a:typed . ' items:' . string(l:items))

    call complete(a:startcol, l:items)
    return ''
endfunc
