" Debug: appends the argument into s:debugString {{{
" Description: 
" 
" Do not want a memory leak! Set this to zero so that latex-suite always
" starts out in a non-debugging mode.
function! Debug(str, ...)
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = ''
	endif
	if !exists('s:debugString_'.pattern)
		let s:debugString_{pattern} = ''
	endif
	if !exists('s:debugString_')
		let s:debugString_ = ''
	endif
	let s:debugString_{pattern} = s:debugString_{pattern}.a:str."\n"
	let s:debugString_ = s:debugString_.pattern.' : '.a:str."\n"
endfunction " }}}
" PrintDebug: prings s:debugString {{{
" Description: 
" 
function! PrintDebug(...)
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = ''
	endif
	if exists('s:debugString_'.pattern)
		return s:debugString_{pattern}
	else
		return 'error pattern for '.pattern.' does not exist'
	endif
endfunction " }}}
" ClearDebug: clears the s:debugString string {{{
" Description: 
" 
function! ClearDebug(...)
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = ''
	endif
	if exists('s:debugString_'.pattern)
		let s:debugString_{pattern} = ''
	endif
endfunction " }}}

" vim:fdm=marker:noet:sw=4:ts=4
