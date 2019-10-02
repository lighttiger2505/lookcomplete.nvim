" ポジション取得を追加して、それに応じて表示するようにした

" いきなり内容が挿入されたらいやじゃないですか？
setl completeopt=menuone,noinsert,noselect
inoremap <F5> <C-R>=ListMonths()<CR>
func! ListMonths()
    " 途中入力している続きから入力されていしまいますね
    " Get start position
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
    call complete(l:startcol, ['January', 'February', 'March',
    \ 'April', 'May', 'June', 'July', 'August', 'September',
    \ 'October', 'November', 'December'])
    return ''
endfunc
