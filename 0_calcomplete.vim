" :help complete から引っ張っただけ

inoremap <F5> <C-R>=ListMonths()<CR>
func! ListMonths()
    call complete(col('.'), ['January', 'February', 'March',
    \ 'April', 'May', 'June', 'July', 'August', 'September',
    \ 'October', 'November', 'December'])
    return ''
endfunc
