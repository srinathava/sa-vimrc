let g:foo = ''
" FoldUpto: folds only upto given level level {{{
function! FoldUpto(first, last, level)
    if a:level > 3
        return
    endif

    call cursor(a:first,0)

    while 1
        let bracepos = search('{', 'W', a:last)
        let prevb = search('^\s*', 'b')
        let highestnb = prevb+1

        let endbracepos = searchpair('{', '', '}', 'W', '', a:last)
        let endpos = search('\S')

        if (startline == 0 || bracepos == 0 || endpos <= 0)
            break
        endif
        call FoldUpto(bracepos+1, a:last-1, a:level+1)
        if startline < endpos
            let g:foo .= startline.','.endpos.' fold'."\n"
            exec startline.','.endpos.' fold'
        endif
    endwhile
endfunction " }}}
