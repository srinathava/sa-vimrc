" Include this in your filetype.vim
augroup filetype
	au BufNewFile,BufRead *.otl			setf otl
	au BufNewFile,BufRead *.bbl			setf tex
	au BufNewFile,BufRead *.tst			setf test
	au BufNewFile,BufRead *.inc			setf php
augroup END

