"=============================================================================
" step 0: 最小の補完サンプル
"
" - `:help complete`より引用したcomplete()のサンプル
"=============================================================================

inoremap <F5> <C-R>=ListMonths()<CR>
func! ListMonths()
    call complete(col('.'), ['January', 'February', 'March',
    \ 'April', 'May', 'June', 'July', 'August', 'September',
    \ 'October', 'November', 'December'])
    return ''
endfunc
