"=============================================================================
"        File: html.vim
"      Author: Srinath Avadhanula
"     Created: Tue Mar 19 09:00 PM 2002 PST
"=============================================================================

let s:path = expand('<sfile>:p:h')

if glob(s:path.'/xml.vim') != ''
	exec 'so '.s:path.'/xml.vim'
endif

setlocal sw=2 sts=2

" HTML commands {{{
let b:tag_tab = "<table border=2 cellspacing=2 cellpadding=5>\<cr><tr>\<cr>\<tab><td><++></td>\<cr>\<bs></tr><++>\<cr></table><++>"
let b:tag_ref = "<a href=\"<++>\"><++></a><++>"
let b:tag_ol =  "<ol>\<cr><li><++></li>\<cr></ol><++>"
let b:tag_ul =  "<ul>\<cr><li><++></li>\<cr></ul><++>"
let b:tag_tr =  "<tr>\<cr><td><++></td><++>\<cr></tr><++>"
let b:tag_td =  "<td><++></td><++>"
let b:tag_th =  "<th><++></th><++>"
let b:tag_bb =  "<b><++></b><++>"
let b:tag_it =  "<i><++></i><++>"
let b:tag_input = '<input type="<++>" name="<++>"><++>'
let b:tag_svg = '<object type="image/svg+xml" data="<++>" height="<++>" width=<++>></object>'
let b:tag_css = '<link rel="stylesheet" type="text/css" href="<++>" />'
let b:tag_js = '<script type="text/javascript" src="<++>"></script>'
let b:tag_jquery = '<link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.7.1/themes/base/jquery-ui.css"/>'."\<CR>"
    \ .'<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>'."\<CR>"
    \ .'<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.10/jquery-ui.min.js"></script>'
" }}}
"
" vim600: fdm=marker:ff=unix:noet:sw=4:ts=4
