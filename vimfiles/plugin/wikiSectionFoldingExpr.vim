" WikiSectionFoldingExpr:  {{{
" Description: 
function! WikiSectionFoldingExpr(lnum)
    if getline(a:lnum) =~ '^// ==='
        return '>3'
    elseif getline(a:lnum) =~ '^// =='
        return '>2'
    else
        return '='
    end
endfunction " }}}
" set foldmethod=expr
" set foldexpr=WikiSectionFoldingExpr(v:lnum)
