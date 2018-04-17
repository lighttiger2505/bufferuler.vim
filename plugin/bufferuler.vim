if exists('g:loaded_bufferuler')
  finish
endif
let g:loaded_bufferuler = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

command! -bar BufferulerToggle call bufferuler#toggle()

let &cpoptions = s:save_cpo
unlet s:save_cpo
