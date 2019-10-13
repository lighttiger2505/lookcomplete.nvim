"=============================================================================
" step 1: 補完オプションを使用して、補完の挙動を変更しよう
"
" - `completeopt`による補完動作の制御
" - 入力済みの内容を考慮した補完候補の表示
"=============================================================================

setl completeopt=menuone,noinsert,noselect
inoremap <F5> <C-R>=ListMonths()<CR>
func! ListMonths() abort
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

    call complete(l:startcol, ['January', 'February', 'March',
    \ 'April', 'May', 'June', 'July', 'August', 'September',
    \ 'October', 'November', 'December'])
    return ''
endfunc
