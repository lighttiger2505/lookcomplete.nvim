"=============================================================================
" step 5: 非同期で補完候補を取得しよう
"
" - jobを用いてコマンドを実行する
"=============================================================================

nnoremap <Space>v :source ./lookcomplete.vim<CR>

function! s:log(...) abort
    let logfile = './lookcomplete.log'
    call writefile([json_encode(a:000)], logfile, 'a')
endfunction

setl completeopt=noinsert,menuone,noselect

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
    if s:prepos[1] ==# l:prepos[1]
        let l:curpos = getcurpos()
        let l:lnum = l:curpos[1]
        let l:col = l:curpos[2]
        let l:typed = strpart(getline(l:lnum), 0, l:col-1)
        let l:kw = matchstr(l:typed, '\w\+$')
        let l:kwlen = len(l:kw)
        let l:startcol = l:col - l:kwlen

        call s:log('get typed text', l:typed, l:kw, l:startcol)

        if l:kwlen == 0
            return
        endif

        call s:get_source(l:startcol, l:kw)
    endif
endfunction

func! s:get_source(startcol, kw) abort
    let s:callbacks = {
    \ 'on_stdout': function('s:source_callback'),
    \ 'on_stderr': function('s:source_callback'),
    \ 'on_exit': function('s:source_callback'),
    \ }
    " ジョブで非同期にlookコマンドを実行
    let l:jobid = jobstart(['look', a:kw], extend({'start_col': a:startcol}, s:callbacks))
    call s:log('call look', l:jobid)
endfunc

" startcolをコールバックに渡すためにdictで定義している
function! s:source_callback(jobid, data, event) dict
    if a:event ==# 'stdout'
        " lookは末尾改行が入るので、ブランク文字のみの配列が返ってくるパターンがある
        if len(a:data) > 1
            call s:update_pum(self.start_col, a:data)
        endif
    endif
endfunction

func! s:update_pum(startcol, words)
    if len(a:words) == 1
        return
    endif

    call complete(a:startcol, a:words)
endfunc
