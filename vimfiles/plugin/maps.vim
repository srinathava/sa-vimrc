call IMAP('LTS', 'Latex-Suite', '')
call IMAP('()', '(<++>)', '')
call IMAP('{}', '{<++>}', '')
call IMAP('[]', '[<++>]', '')

imap <C-_> <C-r>=FastMapInsert()<CR>

" CompleteTag: makes a tag from last word {{{
" Description: 

function! FastMapInsert()
	let line = strpart(getline('.'), 0, col('.')-1)
	
	let word = matchstr(line, '\w\+$')
	if word != ''
		let back = substitute(word, '.', "\<BS>", 'g')
		if exists('b:tag_'.word)
			return IMAP_PutTextWithMovement(back.b:tag_{word})
		endif
	else
		return ''
	endif
endfunction " }}}
