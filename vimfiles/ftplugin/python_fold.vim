" Vim folding file
" Language: Python
" Author: Srinath Avadhanula, Max Ischenko (foldtext)

setlocal foldmethod=manual
setlocal foldtext=PythonFoldText()
nnoremap <buffer> <F4> :call FoldPython()<CR>
let g:PY_FoldDebug = ''

" FoldPython: folds up a python program {{{
" Description: 
function! FoldPython()
    let pos = getpos('.')
    normal! zE
    call s:FoldPythonRec(1, line('$'))
    call setpos('.', pos)
    normal! zv
    let b:FoldedPython = 1
endfunction " }}}
" FoldPythonRec: folds up a python program {{{
" Description:
function! s:FoldPythonRec(start, end)
    let g:PY_FoldDebug .= 'called with start ='.a:start.', end = '.a:end."\n"
    call cursor(a:start, 1) 

    let flag = 'cW'
    while search('\(^\(\s*\(def \|class \)\)\|\(if __name__\)\)\|\([^<]<<<\([^<]\|$\)\)', flag, a:end) != 0
        let flag = 'W'

        if getline('.') =~ '[^<]<<<\([^<]\|$\)'
            let thisstartline = line('.')
            " start searching from the next line.
            call cursor(line('.')+1, 0)
            let nextstart = line('.')

            " start searching for the next closing >>>
            let nextl = searchpair('<<<', '', '>>>', 'W', '', a:end)

            if nextl == 0
                call cursor(a:end)
            endif

            call s:FoldPythonRec(nextstart, line('.'))
            exec thisstartline.','.nextl.' fold'
            continue
        endif

        " we are on a class/function definition
        let ind = indent('.')
        " search for the next line with a equal or smaller indent. Strictly
        " speaking, continuation lines can have arbitrary indentation. But
        " I personally never have any line in the inner block have lesser
        " indentation than the indentation of the def line.
        let n = nextnonblank(line('.') + 1)
        while n > 0 && indent(n) > ind && n <= a:end
            let n = nextnonblank(n + 1)
        endwhile
        let n = (n == 0 ? a:end : prevnonblank(n-1))
        let first = line('.')

        " now recursively fold everything within that thing
        call s:FoldPythonRec(line('.')+1, n)

        let g:PY_FoldDebug .= first.','.n.' fold'."\n"
        exec first.','.n.' fold'
    endwhile
endfunction " }}}

" PythonFoldText {{{
function! PythonFoldText()
    let line = getline(v:foldstart)
    let nnum = nextnonblank(v:foldstart + 1)
    let nextline = getline(nnum)
    if nextline =~ '^\s\+"""\s*$'
        let line = line . substitute(getline(nnum + 1), '^\s\+', ' ', '')
    elseif nextline =~ '^\s\+"""'
        let line = line . ' ' . matchstr(nextline, '"""\zs.\{-}\ze\("""\)\?$')
    elseif nextline =~ '^\s\+"[^"]\+"$'
        let line = line . ' ' . matchstr(nextline, '"\zs.*\ze"')
    elseif nextline =~ '^\s\+pass\s*$'
        let line = line . ' pass'
    endif
    let size = 1 + v:foldend - v:foldstart
    let size = size.' lines'
    let dashes = repeat('-', winwidth(0) - strlen(line.size))
    return line.dashes.size
endfunction

" }}}

if !exists('b:FoldPythonDone')
    call FoldPython()
    let b:FoldPythonDone = 1
endif

" vim: fdm=marker
