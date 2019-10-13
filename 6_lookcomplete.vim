"=============================================================================
" step 6: 非同期用のチェックをしよう
"
" - コンテキストにあったものだけを補完するチェック処理を追加する
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
            let l:ctx = s:create_context()
            if l:ctx['keywordlen'] < 1
                return
            endif
            call s:get_source(l:ctx)
        endif
endfunction

function! s:create_context() abort
    let l:ret = {}
    let l:ret['curpos'] = getcurpos()
    let l:ret['lnum'] = l:ret['curpos'][1]
    let l:ret['col'] = l:ret['curpos'][2]
    let l:ret['typed'] = strpart(getline(l:ret['lnum']),0,l:ret['col']-1)
    let l:ret['keyword'] = matchstr(l:ret['typed'], '\w\+$')
    let l:ret['keywordlen'] = len(l:ret['keyword'])
    let l:ret['startcol'] = l:ret['col'] - l:ret['keywordlen']
    return l:ret
endfunction


func! s:update_pum(ctx, words) abort
    let l:old_ctx = a:ctx
    let l:now_ctx = s:create_context()

    let l:words = a:words
    let l:startcol = l:now_ctx['startcol']
    let l:typed = l:now_ctx['typed']

    if l:now_ctx['lnum'] ==# l:old_ctx['lnum']
        \ && l:now_ctx['col'] ==# l:old_ctx['col']
        \ && l:now_ctx['keyword'] ==# l:old_ctx['keyword']
        let l:items = []
        for l:item in l:words
            let l:base = l:typed[l:startcol - 1:]
            if stridx(l:item, l:base) == 0
                call add(l:items, l:item)
            endif
        endfor
        call Log('update_pum, typed:' . l:typed . ' items:' . string(l:items))
        call complete(l:startcol, l:items)
    endif
endfunc

func! s:get_source(ctx) abort
    let s:callbacks = {
    \ 'on_stdout': function('s:source_callback'),
    \ 'on_stderr': function('s:source_callback'),
    \ 'on_exit': function('s:source_callback'),
    \ }
    let l:jobid = jobstart(['look', a:ctx['keyword']], extend({'ctx': a:ctx}, s:callbacks))
    call Log('jobstart, id:' . l:jobid)
endfunc

function! s:source_callback(job_id, data, event) dict
    if a:event == 'stdout'
        call Log('callback stdout, ' . string(a:data))
        if len(a:data) > 1
            call s:update_pum(self.ctx, a:data)
        endif
    elseif a:event == 'stderr'
        call Log('callback stdout')
    else
        call Log('callback exit')
    endif
endfunction
