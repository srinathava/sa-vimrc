"        File: vim.vim
"      Author: Srinath Avadhanula
"     Created: Thu Mar 21 06:00 PM 2002 PST
" Last Change: Mon Feb 02 03:00 PM 2004 
" Description: ftplugin for vim
" 
" Installation:
"      History: 
"         TODO:
"=============================================================================

" b:forceRedoVim allows this plugin to be forcibly re-sourced.
" if exists('b:didLocalVim') && !exists('b:forceRedoVim')
" 	finish
" end
" let b:didLocalVim = 1

au BufWritePre *.vim :set ff=unix

setlocal fdm=marker

" Vim Mappings {{{
let s:ml = exists('g:mapleader') ? g:mapleader : '\'

call IMAP ('while'.s:ml,    "let <++> = <++>\<cr>while <++> <= <++>\<cr><++>\<cr>let <++> = <++> + 1\<cr>endwhile<++>", 'vim')
call IMAP ('fdesc'.s:ml,    "\"Description: ", 'vim')
call IMAP ('sec'.s:ml,      "\" \<esc>78a=\<esc>o<++>\<cr> \<esc>78i=\<esc>", 'vim')
call IMAP ('func'.s:ml,     "\<C-r>=AskVimFunc()\<cr>", 'vim')
call IMAP ('TED', 'call Tex_Debug("<++>", "<++>")', 'vim')
" end vim mappings }}}
" AskVimFunc: asks for function name and sets up template {{{
" Description: 
function! AskVimFunc()
	let name = input('Name of the function : ')
	if name == ''
		let name = "<+Function Name+>"
	end
    let ch = confirm('What kind of a function is this?', "&Global\n&Autoload\n&ScriptLocal", '1')
    if ch == '1'
        let prefix = ''
    elseif ch == '2'
        let thispath = expand('%:p:r')
        let autopath = expand('~/vimfiles/autoload')
        if thispath =~ '^'.autopath
            let prefix = thispath[(len(autopath)+1):]
            let prefix = substitute(prefix, '/', '#', 'g').'#'
        elseif thispath =~ '.*vimfiles/autoload'
            let prefix = matchstr(thispath, '.*vimfiles/autoload/\zs.*')
            let prefix = substitute(prefix, '/', '#', 'g').'#'
        else
            let prefix = '<+where+>#'
        endif
    else
        let prefix = 's:'
    endif

	return IMAP_PutTextWithMovement( 
        \ "endfunction \" }}}\<esc>O" .
		\ "\" ".prefix.name.": <++> {{{\<cr>" .
		\ "Description: <++>\<cr>" . 
		\ "\<C-u>function! ".prefix.name."(<++>)<++>\<cr>" . 
		\       "<+function body+>"
		\ )
endfunction " }}}

" vim600:fdm=marker
