" Matlab indent file
" Language:	Matlab
" Maintainer:	Christophe Poucet<cpoucet@esat.kuleuven.ac.be>
" Last Change:	6 January, 2001

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

" Some preliminary setting
setlocal indentkeys=!,o,O=end,=case,=else,=elseif,=otherwise,=catch

setlocal indentexpr=GetMatlabIndent(v:lnum)

" Only define the function once.
if exists("*GetMatlabIndent")
  finish
endif

" s:GetPrevBlockStart:  {{{
" Description: 
function! s:GetPrevBlockStart(lnum)
    let contPat = '^\s*[^%].*\.\.\.\s*$'

    let plnum = prevnonblank(a:lnum)
    let pplnum = prevnonblank(plnum - 1)
    if getline(pplnum) =~ contPat
        let plnum = pplnum
    end

    let plnum_bak = plnum
    while getline(plnum) =~ contPat
        let plnum_bak = plnum
        let plnum = prevnonblank(plnum - 1)
    endwhile
    let plnum = plnum_bak

    return plnum
endfunction " }}}

let g:debug_mindent = ''
function! GetMatlabIndent(lnum)
    call Debug('getting here, a:lnum = '.a:lnum, 'mindent')
    " Give up if this line is explicitly joined.
    if getline(a:lnum - 1) =~ '\\$'
        return -1
    endif

    let plnum = prevnonblank(a:lnum - 1)
    if plnum == 0
        " This is the first non-empty line, use zero indent.
        return 0
    endif

    let pBlockNum = s:GetPrevBlockStart(plnum)
    let curind = indent(pBlockNum)

    " If the current line is a stop-block statement...
    if getline(a:lnum) =~ '^\s*\(end\|else\|elseif\|case\|otherwise\|catch\)\>'
        " See if this line does not follow the line right after an openblock
        if getline(plnum) !~ '^\s*\(for\|if\|else\|elseif\|case\|while\|switch\|try\|otherwise\|catch\)\>'
            " If not, recommend one dedent
            let curind = curind - &sw
        endif

    elseif getline(plnum) =~ '^\s*\(function\|for\|if\|else\|elseif\|case\|while\|switch\|try\|otherwise\|catch\|methods\|properties\|classdef\)\>'
        " If the previous line opened a block
        let curind = curind + &sw

    elseif getline(plnum) =~ '\.\.\.\s*$'
        " If the previous line was being continued, try to indent with the
        " last open/unmatched brace/bracket.

        let match = matchstr(getline(pBlockNum), '.*[(\[{]')
        if strlen(match) > 0
            let curind = strlen(match)
            if getline(a:lnum) =~ '^\s*[)\]}]'
                let curind = curind - 1
            end
        else
            let curind = curind + 8
        end
    endif

    " If we got to here, it means that the user takes the standardversion, so we return it
    return curind
endfunction

" vim:sw=4
