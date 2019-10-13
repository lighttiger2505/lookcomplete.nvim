"=============================================================================
" step 3: 自動で補完しよう
"
" - 各イベントをフックして自動補完の動きを作成
"   - InsertEnter: 入力開始時のカーソルポジション取得
"   - InsertLeave: 入力終了時のカーソルポジションのリセット
"   - TextChangeI: 編集中の自動補完候補の表示
"=============================================================================

function! Log(msg) abort
    let logfile = '/home/lighttiger2505/lookcomplete.log'
    call writefile([a:msg], logfile, 'a')
endfunction

let s:words = [
            \ 'January',
            \ 'February',
            \ 'March',
            \ 'April',
            \ 'May',
            \ 'June',
            \ 'July',
            \ 'August',
            \ 'September',
            \ 'October',
            \ 'November',
            \ 'December',
            \]
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

    " Update pum
    let l:words = s:get_source(l:kw)
    if len(l:words) > 0
        call complete(l:startcol, l:words)
    endif

    return ''
endfunc

func! s:get_source(kw) abort
    if len(a:kw) == 0
        return s:words
    endif

    let l:words = []
    for l:word in s:words
        call Log(l:word)
        if len(matchstr(l:word, a:kw)) > 0
            call Log(l:word . ' is complete target')
            call add(l:words, l:word)
        endif
    endfor
    return l:words
endfunc
