"=============================================================================
" step 4: 自動で補完しよう
"
" - 各イベントをフックして自動補完の動きを作成
"   - InsertEnter: 入力開始時のカーソルポジション取得
"   - InsertLeave: 入力終了時のカーソルポジションのリセット
"   - TextChangeI: 編集中の自動補完候補の表示
"=============================================================================

nnoremap <Space>v :source ./lookcomplete.vim<CR>

function! s:log(...) abort
    let logfile = './lookcomplete.log'
    call writefile([json_encode(a:000)], logfile, 'a')
endfunction

setl completeopt=menuone,noinsert,noselect

" テキスト変更イベントをフックして補完を実行
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
    " 改行されているかチェック
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

let s:words = ['January', 'February', 'March',
    \ 'April', 'May', 'June', 'July', 'August', 'September',
    \ 'October', 'November', 'December']

func! s:get_source(kw) abort
    let l:words = []
    for l:word in s:words
        if len(matchstr(l:word, a:kw)) > 0
            call add(l:words, l:word)
        endif
    endfor
    return l:words
endfunc
