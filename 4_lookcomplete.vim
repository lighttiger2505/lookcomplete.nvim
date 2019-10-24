"=============================================================================
" step 5: 英単語を補完しよう
"
" - 補完候補をコマンドから取得する
"=============================================================================

nnoremap <Space>v :source ./lookcomplete.vim<CR>

function! s:log(...) abort
    let logfile = './lookcomplete.log'
    call writefile([json_encode(a:000)], logfile, 'a')
endfunction

setl completeopt=noinsert,menuone,noselect

augroup lookcomplete
    autocmd!
    autocmd TextChangedI * call s:text_change_i()
    autocmd InsertEnter * call s:insert_enter()
    autocmd InsertLeave * call s:insert_leave()
augroup END

function! s:insert_enter() abort
    let s:prepos = getcurpos()
endfunction

function! s:insert_leave() abort
    unlet s:prepos
endfunction

function! s:text_change_i() abort
    let l:prepos = s:prepos
    let s:prepos = getcurpos()
    if s:prepos[1] ==# l:prepos[1]
        let l:curpos = getcurpos()
        let l:lnum = l:curpos[1]
        let l:col = l:curpos[2]
        let l:typed = strpart(getline(l:lnum), 0, l:col-1)
        let l:kw = matchstr(l:typed, '\w\+$')
        let l:kwlen = len(l:kw)
        let l:startcol = l:col - l:kwlen

        call s:log('get typed text', l:typed, l:kw, l:startcol)

        if l:kwlen == 1
            return
        endif
        call s:update_pum(l:startcol, l:kw)
    endif
endfunction

func! s:update_pum(startcol, kw) abort
    let l:words = s:get_source(a:kw)

    if len(l:words) > 0
        call complete(a:startcol, l:words)
    endif
endfunc

func! s:get_source(kw) abort
    " lookコマンドで英単語を取得する
    let l:cmd = 'look ' . a:kw
    return split(system(l:cmd), '\n')
endfunc
