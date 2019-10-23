"=============================================================================
" step 1: 補完オプションを使用して、補完の挙動を変更しよう
"
" - `completeopt`による補完動作の制御
" - 入力済みの内容を考慮した補完候補の表示
"=============================================================================

nnoremap <Space>v :source ./lookcomplete.vim<CR>

function! s:log(...) abort
    let logfile = './lookcomplete.log'
    call writefile([json_encode(a:000)], logfile, 'a')
endfunction

" completeoptで補完ポップアップ表示時の動作を変更
setl completeopt=menuone,noinsert,noselect

inoremap <F5> <C-R>=ListMonths()<CR>

func! ListMonths() abort
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

    " 入力済み内容から補完開始位置を調整
    call complete(l:startcol, ['January', 'February', 'March',
    \ 'April', 'May', 'June', 'July', 'August', 'September',
    \ 'October', 'November', 'December'])
    return ''
endfunc
