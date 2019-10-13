"=============================================================================
" step 2: 補完候補を途中入力のキーワードでフィルタリングしよう
"
" - 補完候補のフィルタリング
"=============================================================================

function! Log(msg) abort
    let logfile = '/home/lighttiger2505/lookcomplete.log'
    call writefile([a:msg], logfile, 'a')
endfunction

let s:words = ['January', 'February', 'March',
    \ 'April', 'May', 'June', 'July', 'August', 'September',
    \ 'October', 'November', 'December']

setl completeopt=menuone,noinsert,noselect
inoremap <F5> <C-R>=ListMonths()<CR>

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

    let l:words = s:get_source(l:kw)
    if len(l:words) > 0
        call complete(l:startcol, l:words)
    endif

    return ''
endfunc
