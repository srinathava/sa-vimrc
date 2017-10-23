set foldmethod=expr
set foldexpr=WikiSectionFoldingExpr(v:lnum)

let s:path=expand('<sfile>:p:h')

let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exec = 'eslint_d'

" vim600:fdm=marker
