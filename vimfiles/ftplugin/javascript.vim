set foldmethod=expr
set foldexpr=WikiSectionFoldingExpr(v:lnum)

let s:path=expand('<sfile>:p:h')

let &l:makeprg = 'cat % \| node '.s:path.'/jslint/runjslint.js \| '.s:path.'/appendfname.py %'

" RefreshJSLintMessages:  {{{
" Description: 
function! RefreshJSLintMessages()
    silent! make! %
    cwindow
    if !has('gui_running')
        redraw!
    endif
endfunction " }}}

augroup RefreshJSLint
    au!
    au BufWritePost   *.js :call RefreshJSLintMessages()
augroup END

" vim600:fdm=marker
