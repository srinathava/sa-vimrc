let g:syntastic_cpp_compiler_options='-std=c++14'

" ConvertToCppComments:  {{{
" Description: 
function! ConvertToCppComments()
    '<,'> s:^\s*\zs/\*\s*:// :g
    '<,'> s:*/\s*$::g
endfunction " }}}

" ConvertToCamelCase: convert word under cursor to camel case {{{
" Description: 
function! ConvertToCamelCaseFcn()
    let word = expand('<cword>')
    let camelWord = substitute(word, '_\([a-z]\)', '\=toupper(submatch(1))', 'g')
    exec '% s/\<'.word.'\>/'.camelWord.'/g'
endfunction " }}}

" MoveOutOfClass: move an function defined inside a class body to outside
" the class {{{
" Description: 
function! MoveOutOfClass()
    let backupFileName = '/tmp/'.expand('%:t')
    silent exec '!cp -f '.expand('%:p').' '.backupFileName

    call Tlist_Update_File(expand('%:p'), &ft)

    let curpos = cursor('.')

    let fcnStartLine = Tlist_Get_Tag_Starting_Line()

    let fcnProto = Tlist_Get_Tagname_By_Line()

    let fcnName = matchstr(fcnProto, '\w\+$')
    let fcnNameWithClass = matchstr(fcnProto, '\w\+::\w\+$')

    call cursor(fcnStartLine, 0)

    " search for the previous blank line
    let prevBlankLine = search('^\s*$', 'bW')

    " We start copying from one line down.
    let copyStartLine = line('.') + 1

    call cursor(fcnStartLine, 0)

    let bodyStartLine = search('{', 'W')

    let fcnEndLine = searchpair('{', '', '}')

    exec copyStartLine.','.fcnEndLine.' yank a'
    let @a = substitute(@a, fcnName, fcnNameWithClass, '')
    let @a = substitute(@a, '\s*override', '', 'g')
    let @a = substitute(@a, 'virtual\s*', '', 'g')

    exec fcnStartLine.','.bodyStartLine.' yank b'
    let @b = substitute(@b, '{\_s*$', ';', '')
    let @b = substitute(@b, '\_s*;', ';', '')

    call cursor(fcnStartLine-1, 0)
    let classStartLine = searchpair('{', '', '}', 'b')
    let classEndLine = searchpair('{', '', '}', '')

    let numPastedBodyLines = fcnEndLine - copyStartLine

    put=''
    silent! put=@a
    call cursor(classEndLine+1, 0)
    silent! exec 'normal! '.(numPastedBodyLines+2).'=='

    silent! exec copyStartLine.','.fcnEndLine.' d_'
    call cursor(copyStartLine-1, 0)
    put=@b
    normal! ==

endfunction " }}}

com! -nargs=0 -range CppComments call ConvertToCppComments()
com! -nargs=0 ConvertToCamelCase call ConvertToCamelCaseFcn()
