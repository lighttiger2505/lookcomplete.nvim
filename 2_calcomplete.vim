" フィルタして指定の文字列だけを取得しよう
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
inoremap <F5> <C-R>=ListMonths()<CR>

func! s:get_source(kw)
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
    let l:words = s:get_source(l:kw)
    if len(l:words) > 0
        call complete(l:startcol, l:words)
    endif

    return ''
endfunc

