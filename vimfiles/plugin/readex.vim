function! ReadExFunc(excom)
	let temp = @a
	silent redir @a | exec a:excom | redir END
	let @a = substitute(@a,"^\n", "", "g")
	put =@a
	let @a = temp
endfunction

com! -nargs=1 -complete=command ReadEx silent call ReadExFunc(<q-args>)

