"=============================================================================
" 	     File: d:/srinath/vimfiles/ftplugin/xml.vim
"      Author: Srinath Avadhanula
"=============================================================================

setlocal fdm=manual

let b:Imap_PlaceHolderStart = "\xab"
let b:Imap_PlaceHolderEnd = "\xbb"

inoremap <buffer> <silent> <C-f> <C-r>=CompleteTag()<CR>
vnoremap <buffer> <silent> <C-_> <C-\><C-N>:call EncloseSelection()<CR>

" CompleteTag: makes a tag from last word {{{
" Description: 

let b:unaryTags = 'br,par'

function! CompleteTag()
	let line = strpart(getline('.'), 0, col('.')-1)
	
	let word = matchstr(line, '\w\+$')
	if word != ''
        let len = strlen(word)
        let back = StrRepeat("\<left>", len) . StrRepeat("\<del>", len)
		if exists('b:tag_'.word)
			return back.IMAP_PutTextWithMovement(b:tag_{word})
		elseif b:unaryTags =~ '\<'.word.'\>'
			return back.IMAP_PutTextWithMovement("<".word."/>")
		else
			return back.IMAP_PutTextWithMovement("<".word.">\<CR><++>\<CR></".word.">")
		endif
	else
		return ''
	endif
endfunction " }}}
" EncloseSelection: enclose visual selection in tags {{{
" Description: prompts for tag name

let s:lastVal = ''
function! EncloseSelection()
	let name = input('Enter tag name:', s:lastVal)
	let s:lastVal = name
	let startTag = '<'.name.'>'
	let endTag = '</'.name.'>'
	call VEnclose(startTag, endTag, startTag, endTag)
endfunction " }}}
" RemoveUnsafeXML: removes things like < and > from a range {{{
" Description: 
function! RemoveUnsafeXML() range
	exec a:firstline.','.a:lastline.' s/&/\&amp;/g'
	exec a:firstline.','.a:lastline.' s/</\&lt;/g'
	exec a:firstline.','.a:lastline.' s/>/\&gt;/g'
endfunction " }}}

" vim:fdm=marker
