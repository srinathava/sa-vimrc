" Vim filetype plugin file
" Language:		Mail
" Maintainer:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" License:		GNU GPL
" Version:		$Id: mail.vim,v 1.1 2003/09/04 21:21:05 srinathava Exp $

" Don't use modelines in e-mail messages, avoid trojan horses
setlocal nomodeline

" many people recommend keeping e-mail messages 72 chars wide
setlocal textwidth=72

" Set 'formatoptions' to break text lines and keep the comment leader ">".
setlocal formatoptions=crqt12n

setlocal autoindent
setlocal et
