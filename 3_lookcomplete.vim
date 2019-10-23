"=============================================================================
" step 2: 補完候補を途中入力のキーワードでフィルタリングしよう
"
" - 補完候補のフィルタリング
"=============================================================================

nnoremap <Space>v :source ./lookcomplete.vim<CR>

function! s:log(...) abort
    let logfile = './lookcomplete.log'
    call writefile([json_encode(a:000)], logfile, 'a')
endfunction

setl completeopt=noinsert,menuone,noselect

inoremap <F5> <C-R>=ListMonths()<CR>

func! ListMonths()
    let l:curpos = getcurpos()
    let l:lnum = l:curpos[1]
    let l:col = l:curpos[2]
    let l:typed = strpart(getline(l:lnum), 0, l:col-1)
    let l:kw = matchstr(l:typed, '\w\+$')
    let l:kwlen = len(l:kw)
    let l:startcol = l:col - l:kwlen

    call s:log('get typed text', l:typed, l:kw, l:startcol)

    if l:kwlen < 1
        return ''
    endif

    let l:words = s:get_source(l:kw)

    " 補完候補がないならば更新は不要
    if len(l:words) > 0
        call complete(l:startcol, l:words)
    endif
    return ''
endfunc

let s:words = ['January', 'February', 'March',
    \ 'April', 'May', 'June', 'July', 'August', 'September',
    \ 'October', 'November', 'December']

func! s:get_source(kw) abort
    " 候補のフィルタリング
    let l:words = []
    for l:word in s:words
        if len(matchstr(l:word, a:kw)) > 0
            call add(l:words, l:word)
        endif
    endfor
    return l:words
endfunc
