"=============================================================================
"        File: html.vim
"      Author: Srinath Avadhanula
"     Created: Tue Mar 19 09:00 PM 2002 PST
"=============================================================================

let s:path = expand('<sfile>:p:h')

if glob(s:path.'/xml.vim') != ''
	exec 'so '.s:path.'/xml.vim'
endif

" HTML commands {{{
let b:tag_tab = "<table border=2 cellspacing=2 cellpadding=5>\<cr><tr>\<cr>\<tab><td><++></td>\<cr>\<bs></tr><++>\<cr></table><++>"
let b:tag_ref = "<a href=\"<++>\"></a><++>"
let b:tag_ol =  "<ol>\<cr><li><++></li>\<cr></ol><++>"
let b:tag_ul =  "<ul>\<cr><li><++></li>\<cr></ul><++>"
let b:tag_tr =  "<tr>\<cr>\<tab><td><++></td>\<cr>\<bs></tr><++>"
let b:tag_td =  "<td><++></td><++>"
let b:tag_bb =  "<b><++></b><++>"
let b:tag_it =  "<i><++></i><++>"
" }}}
"
" vim600: fdm=marker:ff=unix:noet:sw=4:ts=4
