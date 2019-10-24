"=============================================================================
" step 7: 非同期用のチェックをしよう
"
" - コンテキストにあったものだけを補完するチェック処理を追加する
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
        let l:ctx = s:get_context()

        call s:log('get typed text', l:ctx)

        if l:ctx['kwlen'] == 0
            return
        endif

        call s:get_source(l:ctx)
    endif
endfunction

" 冗長化を防ぐためにコンテキスト取得関数を用意
function! s:get_context() abort
    let l:ret = {}
    let l:ret['curpos'] = getcurpos()
    let l:ret['lnum'] = l:ret['curpos'][1]
    let l:ret['col'] = l:ret['curpos'][2]
    let l:ret['typed'] = strpart(getline(l:ret['lnum']), 0, l:ret['col']-1)
    let l:ret['kw'] = matchstr(l:ret['typed'], '\w\+$')
    let l:ret['kwlen'] = len(l:ret['kw'])
    let l:ret['startcol'] = l:ret['col'] - l:ret['kwlen']
    return l:ret
endfunction

func! s:get_source(ctx) abort
    let s:callbacks = {
    \ 'on_stdout': function('s:source_callback'),
    \ 'on_stderr': function('s:source_callback'),
    \ 'on_exit': function('s:source_callback'),
    \ }
    let l:jobid = jobstart(['look', a:ctx['kw']], extend({'ctx': a:ctx}, s:callbacks))
    call s:log('call look', l:jobid)
endfunc

function! s:source_callback(jobid, data, event) dict
    if a:event ==# 'stdout'
        if len(a:data) > 1
            call s:update_pum(self.ctx, a:data)
        endif
    endif
endfunction

func! s:update_pum(ctx, words)
    if len(a:words) == 1
        return
    endif

    " コマンド実行と現状のコンテキストを比較
    let l:ctx = s:get_context()
    if l:ctx['lnum'] ==# a:ctx['lnum']
        \ && l:ctx['col'] ==# a:ctx['col']
        \ && l:ctx['kw'] ==# a:ctx['kw']
        call complete(l:ctx['startcol'], a:words)
    endif
endfunc
