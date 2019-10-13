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
            call s:get_source(l:startcol, l:kw)
        endif
endfunction

func! s:update_pum(start_col, words) abort
    let l:words = a:words
    if len(a:words) > 0
        call complete(a:start_col, a:words)
    endif
    return ''
endfunc

func! s:get_source(start_col, kw) abort
    let s:callbacks = {
    \ 'on_stdout': function('s:source_callback'),
    \ 'on_stderr': function('s:source_callback'),
    \ 'on_exit': function('s:source_callback'),
    \ }
    let l:jobid = jobstart(['look', a:kw], extend({'start_col': a:start_col}, s:callbacks))
    call Log('jobstart, id:' . l:jobid)
endfunc

function! s:source_callback(job_id, data, event) dict
    if a:event == 'stdout'
        call Log('callback stdout, ' . string(a:data))
        if len(a:data) > 1
            call s:update_pum(self.start_col, a:data)
        endif
    elseif a:event == 'stderr'
        call Log('callback stdout')
    else
        call Log('callback exit')
    endif
endfunction
