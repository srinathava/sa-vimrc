" RtwFoldFun:  {{{
" Description: 
function! RTWFoldFun(lnum)
    if getline(a:lnum) =~ '^\s*\w\+\s*{$'
        return 'a1'
    elseif getline(a:lnum) =~ '^\s*}$'
        return 's1'
    else
        return '='
    end
endfunction " }}}

" RTWFoldTextFunc:  {{{
" Description: 
function! RTWFoldTextFunc(lstart, lend, level)
    let nlines = a:lend - a:lstart
    let ft = substitute(getline(a:lstart), '\t', '        ', 'g') . '     ' . (nlines+1) . ' lines'
    return ft
endfunction " }}}

let foldtext=RTWFoldTextFunc(v:foldstart,v:foldend,v:foldlevel)
