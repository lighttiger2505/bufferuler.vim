let s:save_cpo = &cpoptions
set cpoptions&vim

let s:buffer_seqno = 0

function! bufferuler#toggle() abort
    if s:BufferulerOpened()
        call s:CloseWindow()
    else
        call s:OpenWindow()
    endif
endfunction

function! bufferuler#open() abort
    call s:OpenWindow()
endfunction

function! bufferuler#close() abort
    call s:CloseWindow()
endfunction

function! s:OpenWindow() abort
    " Checking bufferuler window status
    if s:BufferulerOpened()
        echomsg 'OpenWindow finished, bufferuler already open'
        return
    endif
    echomsg 'Lets create bufferuler buffer'

    " Exec bufferuler window create new command
    let mode = 'vertical '
    let openpos = 'topleft '
    let width = 30
    exe 'silent keepalt ' . openpos . mode . width . 'split ' . s:BufferulerBufName()
    exe 'silent ' . mode . 'resize ' . width

    " Initialize window
    call s:InitWindow()

    " Add contents to bufferuler window
    call s:DrawWindow()

endfunction

function! s:CloseWindow() abort
    " Checking bufferuler window status
    if !s:BufferulerOpened()
        echomsg 'CloseWindow finished, bufferuler already close'
        return
    endif

    " Closing bufferuler window
    if s:BufferulerFocused()
        close
    else
        call s:GotoWindow(s:BufferulerWinnr())
        close
    endif
endfunction

function! s:BufferulerBufName() abort
    if !exists('t:bufferuler_buf_name')
        let s:buffer_seqno += 1
        let t:bufferuler_buf_name = '__Bufferuler__.' . s:buffer_seqno
    endif
    return t:bufferuler_buf_name
endfunction

function! s:BufferulerWinnr() abort
    return bufwinnr(s:BufferulerBufName())
endfunction

function! s:BufferulerOpened() abort
    if s:BufferulerWinnr() == -1
        return 0
    endif
    return 1
endfunction

function! s:BufferulerFocused() abort
    if winnr() != s:BufferulerWinnr()
        return 0
    else
    return 1
endfunction

function! s:BufferulerContents() abort
    " Collect all tab buffer window
    let bufnrlist = []
    for i in range(tabpagenr('$'))
        call extend(bufnrlist, tabpagebuflist(i + 1))
    endfor

    " Make deisplay buffer list
    let disp_buflist = []
    for i in bufnrlist
        let disp_buf = i . ' ' . bufname(i)
        call add(disp_buflist, disp_buf)
    endfor

    return disp_buflist
endfunction

function! s:InitWindow() abort
    " Set buffer local options
    setlocal filetype=bufferuler
    setlocal noreadonly
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal textwidth=0

    " Set window local options
    setlocal nolist
    setlocal nowrap
    setlocal winfixwidth
    setlocal nospell
    setlocal nonumber
    setlocal nofoldenable
    setlocal foldcolumn=0

    " from tagbar
    " Reset fold settings in case a plugin set them globally to something
    " expensive. Apparently 'foldexpr' gets executed even if 'foldenable' is
    " off, and then for every appended line (like with :put).
    setlocal foldmethod&
    setlocal foldexpr&

    " let cpoptions_save = &cpoptions
    " set cpoptions&vim
    " let &cpoptions = cpoptions_save
endfunction

function! s:GotoWindow(winnr, ...) abort
    let cmd = type(a:winnr) == type(0) ? a:winnr . 'wincmd w' : 'wincmd ' . a:winnr
    let noauto = a:0 > 0 ? a:1 : 0

    if noauto
        noautocmd execute cmd
    else
        execute cmd
    endif
endfunction

function! s:DrawWindow() abort
    let bufferuler_winnr = s:BufferulerWinnr()
    let contents = s:BufferulerContents()

    setlocal modifiable

    " Clear buffer
    exe '0,' . line('$') . 'delete'

    " Draw buffer
    let draw_line = 0
    for content in contents
        call append(draw_line, content)
        let draw_line += 1
    endfor

    setlocal nomodifiable
endfunction
