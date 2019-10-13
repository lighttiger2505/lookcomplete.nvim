"=============================================================================
" step 4: 英単語を補完しよう
"
" - 補完候補をコマンドから取得する
"=============================================================================

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
        call s:update_pum()
    endif
endfunction

func! s:update_pum() abort
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

    let l:words = s:get_source(l:kw)
    if len(l:words) > 0
        call complete(l:startcol, l:words)
    endif
endfunc

func! s:get_source(kw) abort
    let l:cmd = 'look ' . a:kw
    let l:res = system(cmd)
    let l:words = split(l:res, '\n')
    return l:words
endfunc
