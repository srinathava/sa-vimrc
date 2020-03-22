" PY_GetFunction: generates a function prototype {{{
" " Description: 
function! PY_MakeFunctionTemplate()
	let line = getline('.')
    let line = substitute(line, '^\s*', '', '')

	return IMAP_PutTextWithMovement("\<C-o>cc# ".line." {{{\<CR>\<C-u>def ".line.":\<CR><++>\<CR>\<BS># }}}")
endfunction " }}}

inoremap <buffer> <C-_> <C-r>=PY_MakeFunctionTemplate()<CR>
let b:syntastic_checkers = ["python", "flake8"]

set et sts=4 sw=4
