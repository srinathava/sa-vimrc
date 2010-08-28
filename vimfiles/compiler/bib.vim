" ============================================================================
" 	     File: bib.vim
"      Author: Srinath Avadhanula
"     Created: Sat Jul 05 03:00 PM 2003 
" Description: errorformat and makeprg settings for bibtex
"     License: Vim Charityware License
"              Part of vim-latexSuite: http://vim-latex.sourceforge.net
"         CVS: $Id$
" ============================================================================

setlocal efm=

setlocal efm+=%E%m---line\ %l\ of\ file\ %f
setlocal efm+=%+C\ :\ %m
setlocal efm+=%+WWarning--%m
setlocal efm+=%-G%.%#

if exists('g:Tex_BibtexProgram')
	let &makeprg = g:Tex_BibtexProgram
else
	setlocal makeprg=bibltex\ $*
endif
