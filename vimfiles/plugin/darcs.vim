" ==============================================================================
"        File: darcs.vim
"      Author: Srinath Avadhanula (srinathava [AT] gmail [DOT] com)
"        Help: darcs.vim is a plugin which implements some simple mappings
"              to make it easier to use darcs, David Roundy's distributed
"              revisioning system.
"   Copyright: Srinath Avadhanula
"     License: Vim Charityware license. (:help uganda)
"
" As of right now, this script provides the following mappings:
"
" 	<Plug>DarcsVertDiffsplit
" 		This mapping vertically diffsplit's the current window with the
" 		last recorded version.
"
" 		Default map: <leader>dkv
"
" 	<Plug>DarcsIneractiveDiff
" 		This mapping displays the changes for the current file. The user
" 		can then choose two revisions from the list using the 'f' (from)
" 		and 't' (to) keys. After choosing two revisions, the user can press
" 		'g' at which point, the delta between those two revisions is
" 		displayed in two veritcally diffsplit'ted windows.
"
" 		Default map: <leader>dki
"
" 	<Plug>DarcsStartCommitSession
" 		This mapping starts an interactive commit console using which the
" 		user can choose which hunks to include in the record and then also
" 		write out a patch name and commit message.
"
" 		Default map: <leader>dkc
" ==============================================================================

" ==============================================================================
" Main functions
" ==============================================================================
" Functions related to diffsplitting current file with last recorded {{{

nmap <Plug>DarcsVertDiffsplit :call Darcs_DiffSplit()<CR>
if !hasmapto('<Plug>DarcsVertDiffsplit')
	nmap <unique> <leader>dkv <Plug>DarcsVertDiffsplit
endif

" Darcs_DiffSplit: diffsplits the current file with last recorded version {{{
function! Darcs_DiffSplit()
	" first find out the location of the repository by searching upwards
	" from the current directory for a _darcs* directory.
	if Darcs_SetDarcsDirectory() < 0
        return -1
    endif

	" Find out if the current file has any changes.
	if system('darcs whatsnew '.expand('%')) =~ '\(^\|\n\)No changes'
		echomsg "darcs says there are no changes"
		return 0
	endif

    " Find out the relative path name from the parent dir of the _darcs
    " directory to the location of the presently edited file
    let relPath = strpart(expand('%:p'), strlen(b:darcs_repoDirectory))

    " The last recorded file lies in
    "   $DIR/_darcs/current/relative/path/to/file
    " where
    "   $DIR/relative/path/to/file
    " is the actual path of the file
    let lastRecFile = b:darcs_repoDirectory . '/'
        \ . '_darcs/current' . relPath

	call Darcs_Debug(':Darcs_DiffSplit: lastRecFile = '.lastRecFile, 'darcs')

	call Darcs_NoteViewState()

	execute 'vert diffsplit '.lastRecFile
	" The file in _darcs/current should not be edited by the user.
	setlocal readonly

	nmap <buffer> q <Plug>DarcsRestoreViewAndQuit
endfunction

" }}}
" Darcs_SetDarcsDirectory: finds which _darcs directory contains this file {{{
" Description: This function searches upwards from the current directory for a
"              _darcs directory.
function! Darcs_SetDarcsDirectory()
	let filename = expand('%:p')
	let origDir = getcwd()
	let foundFile = 0

	let lastDir = origDir
    while glob('_darcs*') == ''
        lcd ..
        " If we cannot go up any further, then break
        if lastDir == getcwd()
            break
        endif
		let lastDir = getcwd()
    endwhile

    " If a _darcs directory was never found, then quit...
    if glob('_darcs*') == ''
        echohl Error
        echo "_darcs directory not found in or above current directory"
        echohl None
        return -1
    endif

	let b:darcs_repoDirectory = getcwd()
	
	call Darcs_CD(origDir)

    return 0
endfunction

" }}}

" }}}
" Functions related to interactive diff splitting {{{

nmap <Plug>DarcsIneractiveDiff :call Darcs_StartInteractiveDiffSplit()<CR>
if !hasmapto('<Plug>DarcsIneractiveDiff')
	nmap <unique> <leader>dki <Plug>DarcsIneractiveDiff
endif

" Darcs_StartInteractiveDiffSplit: initializes the interactive diffsplit session {{{
function! Darcs_StartInteractiveDiffSplit()
	let origDir = getcwd()
	call Darcs_CD(expand('%:p:h'))
	let filename  = expand('%:p:t')

	call Darcs_OpenScratchBuffer()

	" delete everything into the black hole.
	" I *love* saying that.... ;)
	% d _

	execute '0r! darcs changes -v '.filename
	set ft=changelog
	" reading in stuff creates an extra line ending
	$ d _

	call Darcs_CD(origDir)

	let header = 
		\ '====[ Darcs diff console: Mappings ]==========================' . "\n" .
		\ "\n" .
		\ 'j/k	: next/previous patch' . "\n" .
		\ 'f  	: set "from" patch' . "\n" .
		\ 't  	: set "to" patch' . "\n" .
		\ 'g	: proceed with diff (Go)' . "\n" .
		\ 'q	: quit without doing anything further'. "\n" .
		\ '=============================================================='
	0put=header
	normal! gg

	let b:darcs_FROM_regexp = ''
	let b:darcs_TO_regexp = ''
	let b:darcs_orig_file = filename
	let b:darcs_orig_ft = &l:ft

	nmap <buffer> j <Plug>DarcsGotoNextChange
	nmap <buffer> k <Plug>DarcsGotoPreviousChange
	nmap <buffer> f <Plug>DarcsSetFromRegexp
	nmap <buffer> t <Plug>DarcsSetToRegexp
	nmap <buffer> g <Plug>DarcsProceedWithDiffSplit
	nmap <buffer> q :q<CR>:<BS>

	call search('^\s*\*')
endfunction

" }}}
" Darcs_SetRegexp: remembers the user's from/to regexps for the diff {{{

nnoremap <Plug>DarcsSetToRegexp :call Darcs_SetRegexp('TO')<CR>
nnoremap <Plug>DarcsSetFromRegexp :call Darcs_SetRegexp('FROM')<CR>

function! Darcs_SetRegexp(fromto)
	normal! $
	call search('^\s*\*', 'bw')

	" First remove any previous mark set.
	execute '% s/'.a:fromto.'$//e'
	" remember the present line's regexp
	let b:darcs_{a:fromto}_regexp = matchstr(getline('.'), '^\s*\* \zs.*$')

	call setline(line('.')-1, getline(line('.')-1).'  '.a:fromto)
endfunction

" }}}
" Darcs_GotoChange: goes to the next previous change {{{

nnoremap <Plug>DarcsGotoPreviousChange :call Darcs_GotoChange('b')<CR>
nnoremap <Plug>DarcsGotoNextChange :call Darcs_GotoChange('')<CR>

function! Darcs_GotoChange(dirn)
	call search('^\s*\*', a:dirn.'w')
endfunction

" }}}
" Darcs_ProceedWithDiff: proceeds with the actual diff between requested versions {{{
" Description: 

nnoremap <Plug>DarcsProceedWithDiffSplit :call Darcs_ProceedWithDiff()<CR>

function! Darcs_ProceedWithDiff()

	if b:darcs_FROM_regexp == '' && b:darcs_TO_regexp == ''
		echohl Error
		echo "You need to set at least one of the FROM or TO regexps"
		echohl None
		return -1
	endif

	let origDir = getcwd()
	call Darcs_CD(expand('%:p:h'))

	let ft = b:darcs_orig_ft
	let filename = b:darcs_orig_file
	let fromre = b:darcs_FROM_regexp
	let tore = b:darcs_TO_regexp

	" quit the window which shows the Changelog
	q

	" First copy the present file into a temporary location
	let tmpfile = tempname().'__present'

	call system('cp '.filename.' '.tmpfile)

	if fromre != ''
		let tmpfilefrom = tempname().'__from'
		call Darcs_RevertToState(filename, fromre, tmpfilefrom)
		let file1 = tmpfilefrom
	else
		let file1 = tmpfile
	endif

	if tore != ''
		let tmpfileto = tempname().'__to'
		call Darcs_RevertToState(filename, tore, tmpfileto)
		let file2 = tmpfileto
	else
		let file2 = tmpfile
	endif

	call Darcs_Debug(':Darcs_ProceedWithDiff: file1 = '.file1.', file2 = '.file2, 'darcs')

	execute 'split '.file1
	execute "nnoremap <buffer> q :q\<CR>:e ".file2."\<CR>:q\<CR>"
	let &l:ft = ft
	execute 'vert diffsplit '.file2
	let &l:ft = ft
	execute "nnoremap <buffer> q :q\<CR>:e ".file1."\<CR>:q\<CR>"
	
	call Darcs_CD(origDir)
endfunction 

" }}}
" Darcs_RevertToState: reverts a file to a previous state {{{
function! Darcs_RevertToState(filename, patchre, tmpfile)
	let syscmd = "darcs diff --from-patch '".a:patchre."' ".a:filename.
		\ " | patch -R ".a:filename." -o ".a:tmpfile
	call system(syscmd)
	let syscmd = "darcs diff -p '".a:patchre."' ".a:filename.
		\ " | patch ".a:tmpfile
	call system(syscmd)
endfunction 

" }}}

" }}}
" Functions related to interactive comitting {{{

nmap <Plug>DarcsStartCommitSession :call Darcs_StartCommitSession()<CR>
if !hasmapto('<Plug>DarcsStartCommitSession')
	nmap <unique> <leader>dkc <Plug>DarcsStartCommitSession
endif

" Darcs_StartCommitSession: start an interactive commit "console" {{{
function! Darcs_StartCommitSession()

	let wn = system('darcs whatsnew --dont-look-for-adds')
	if wn =~ '^No changes!'
		echo "No changes seen by darcs"
		return
	endif

	" read in the contents of the `darcs whatsnew` command
	call Darcs_ToggleSilent()

	" opens a scratch buffer for the commit console
	" Unfortunately, it looks like the temporary file has to exist in the
	" present directory because at least on Windows, darcs doesn't want to
	" handle absolute path names containing ':' correctly.
	exec "split ".Darcs_GetTempName(expand('%:p:h'))
	0put=wn

	" Delete the end and beginning markers
	g/^[{}]$/d _
	" Put an additional four spaces in front of all lines and a little
	" checkbox in front of the hunk specifier lines
	% s/^/    /
	% s/^    hunk/[ ] hunk/

	let header = 
		\ '====[ Darcs commit console: Mappings ]========================' . "\n" .
		\ "\n" .
		\ 'J/K	: next/previous hunk' . "\n" .
		\ 'Y/N	: accept/reject this hunk' . "\n" .
		\ 'F/S	: accept/reject all hunks from this file' . "\n" .
		\ 'A/U	: accept/reject all (remaining) hunks' . "\n" .
		\ 'q	: quit this session without committing' . "\n" .
		\ 'L	: goto log area to record description'. "\n" .
		\ 'R	: done! finish record' . "\n" .
		\ '=============================================================='
	0put=header

	let footer = 
		\ '====[ Darcs commit console: Commit log description ]==========' . "\n" .
		\ "\n" .
		\ '***DARCS***'. "\n".
		\ 'Write the long patch description in this area.'. "\n".
		\ 'The first line in this area will be the patch name.'. "\n".
		\ 'Everything in this area from the above ***DARCS*** line on '."\n".
		\ 'will be ignored.'. "\n" .
		\ '=============================================================='
	$put=footer

	set nomodified
	call Darcs_ToggleSilent()

	" Set the fold expression so that things get folded up nicely.
	set fdm=expr
	set foldexpr=Darcs_WhatsNewFoldExpr(v:lnum)

	" Finally goto the first hunk
	normal! G
	call search('^\[ ', 'w')

	nnoremap <buffer> J :call Darcs_GotoHunk('')<CR>:<BS>
	nnoremap <buffer> K :call Darcs_GotoHunk('b')<CR>:<BS>

	nnoremap <buffer> Y :call Darcs_SetHunkVal('y')<CR>:<BS>
	nnoremap <buffer> N :call Darcs_SetHunkVal('n')<CR>:<BS>

	nnoremap <buffer> A :call Darcs_SetRemainingHunkVals('y')<CR>:<BS>
	nnoremap <buffer> U :call Darcs_SetRemainingHunkVals('n')<CR>:<BS>

	nnoremap <buffer> F :call Darcs_SetFileHunkVals('y')<CR>:<BS>
	nnoremap <buffer> S :call Darcs_SetFileHunkVals('n')<CR>:<BS>

	nnoremap <buffer> L :call Darcs_GotoLogArea()<CR>
	nnoremap <buffer> R :call Darcs_FinishCommitSession()<CR>

	nnoremap <buffer> q :q<CR>:<BS>
endfunction

" }}}
" Darcs_WhatsNewFoldExpr: foldexpr function for a commit console {{{
function! Darcs_WhatsNewFoldExpr(lnum)
	if matchstr(getline(a:lnum), '^\[[yn ]\]') != ''
		return '>1'
	elseif matchstr(getline(a:lnum+1), '^====\[ .* log description') != ''
		return '<1'
	else
		return '='
	endif
endfunction

" }}}
" Darcs_GotoHunk: goto next/previous hunk in a commit console {{{
function! Darcs_GotoHunk(dirn)
	call search('^\[[yn ]\]', a:dirn.'w')
endfunction

" }}}
" Darcs_SetHunkVal: accept/reject a hunk for committing {{{
function! Darcs_SetHunkVal(yesno)
	if matchstr(getline('.'), '\[[yn ]\]') == ''
		return
	end
	execute "s/^\\[.\\]/[".a:yesno."]"
	call Darcs_GotoHunk('')
endfunction

" }}}
" Darcs_SetRemainingHunkVals: accept/reject all remaining hunks {{{
function! Darcs_SetRemainingHunkVals(yesno)
	execute "% s/^\\[ \\]/[".a:yesno."]/e"
endfunction 

" }}}
" Darcs_SetFileHunkVals: accept/reject all hunks from this file {{{
function! Darcs_SetFileHunkVals(yesno)
	" If we are not on a hunk line for some reason, then do not do
	" anything.
	if matchstr(getline('.'), '\[[yn ]\]') == ''
		return
	end

	" extract the file name from the current line
	let filename = matchstr(getline('.'), 
		\ '^\[[yn ]\] hunk \zs\f\+\ze')
	if filename == ''
		return
	endif

	" mark all hunks belonging to the file with yes/no
	execute '% s/^\[\zs[yn ]\ze\] hunk '.escape(filename, "\\/").'/'.a:yesno.'/e'

	call Darcs_GotoHunk('')
endfunction 

" }}}
" Darcs_GotoLogArea: records the log description of the commit {{{
function! Darcs_GotoLogArea()
	if search('^\[ \]')
		echohl WarningMsg
		echo "There are still some hunks which are neither accepted or rejected"
		echo "Please set the status of all hunks before proceeding to log"
		echohl None

		return
	endif

	call search('\M^***DARCS***')
	normal! k
	startinsert
endfunction 

" }}}
" Darcs_FinishCommitSession: finishes the interactive commit session {{{
function! Darcs_FinishCommitSession()
	call Darcs_ToggleSilent()

	" First make sure that all hunks have been set as accpeted or rejected.
	if search('^\[ \]')
		echohl WarningMsg
		echo "There are still some hunks which are neither accepted or rejected"
		echo "Please set the status of all hunks before proceeding to log"
		echohl None

		return
	endif

	" Then make a list of the form "ynyy..." from the choices made by the
	" user.
	let yesnolist = ''
	g/^\[[yn]\]/let yesnolist = yesnolist.matchstr(getline('.'), '^\[\zs.\ze\]')

	" make sure that a valid log message has been written.
	call search('====\[ Darcs commit console: Commit log description \]', 'w')
	normal! j
	let _k = @k
	execute "normal! V/\\M***DARCS***/s\<CR>k\"ky"

	let logMessage = @k
	let @k = _k

	if logMessage !~ '\S'
		echohl WarningMsg
		echo "The log message is either ill formed or empty"
		echo "Please repair the mistake and retry"
		echohl None

		return
	endif

	" Remove everything from the file except the log file.
	% d _
	0put=logMessage
	$ d _
	w

	call Darcs_Debug(':Darcs_FinishCommitSession: logMessage = '.logMessage, 'darcs')
	call Darcs_Debug(':Darcs_FinishCommitSession: yesnolist = ['.yesnolist.']', 'darcs')

	let origDir = getcwd()
	call Darcs_CD(expand('%:p:h'))

	let darcsOut = system('echo '.yesnolist.' | darcs record --logfile='.expand('%:p:t'))

	call Darcs_CD(origDir)

	% d _
	0put=darcsOut

	let footer = 
		\ "=================================================================\n".
		\ "Press q to delete this temporary file and quit the commit session\n".
		\ "If you quit this using :q, then a temp file will remain in the \n".
		\ "present directory\n".
		\ "================================================================="
	$put=footer

	set nomodified
	nmap <buffer> q :call Darcs_DeleteTempFile(expand('%:p'))<CR>

	call Darcs_ToggleSilent()
endfunction 

" }}}
" Darcs_DeleteTempFile: deletes temp file created during commit session {{{
function! Darcs_DeleteTempFile(fname)
	call Darcs_Debug('+Darcs_DeleteTempFile: fname = '.a:fname.', bufnr = '.bufnr(a:fname), 'darcs')
	if bufnr(a:fname) > 0
		execute 'bdelete! '.bufnr(a:fname)
	endif
	let sysout = system('rm '.a:fname)
endfunction 

" }}}

" }}}

" ==============================================================================
" Helper functions
" ==============================================================================
" Darcs_CD: cd's to a directory {{{
function! Darcs_CD(dirname)
	execute "cd ".escape(a:dirname, ' ')
endfunction

" }}}
" Darcs_OpenScratchBuffer: opens a scratch buffer {{{
function! Darcs_OpenScratchBuffer()
	new
	set buftype=nofile
	set noswapfile
	set filetype=
endfunction

" }}}
" Darcs_NoteViewState: notes the current fold related settings of the buffer {{{
function! Darcs_NoteViewState()
	let b:darcs_old_diff         = &l:diff 
	let b:darcs_old_foldcolumn   = &l:foldcolumn
	let b:darcs_old_foldenable   = &l:foldenable
	let b:darcs_old_foldmethod   = &l:foldmethod
	let b:darcs_old_scrollbind   = &l:scrollbind
	let b:darcs_old_wrap         = &l:wrap
endfunction

" }}}
" Darcs_ResetViewState: restores the fold related settings of a buffer {{{
function! Darcs_ResetViewState()
	let &l:diff         = b:darcs_old_diff 
	let &l:foldcolumn   = b:darcs_old_foldcolumn
	let &l:foldenable   = b:darcs_old_foldenable
	let &l:foldmethod   = b:darcs_old_foldmethod
	let &l:scrollbind   = b:darcs_old_scrollbind
	let &l:wrap         = b:darcs_old_wrap
endfunction

nnoremap <Plug>DarcsRestoreViewAndQuit :q<CR>:call Darcs_ResetViewState()<CR>:<BS> 

" }}}
" Darcs_Strntok: extract the n^th token from a list {{{
" example: Darcs_Strntok('1,23,3', ',', 2) = 23
fun! Darcs_Strntok(s, tok, n)
	return matchstr( a:s.a:tok[0], '\v(\zs([^'.a:tok.']*)\ze['.a:tok.']){'.a:n.'}')
endfun

" }}}
" Darcs_GetTempName: get the name of a temporary file in specified directory {{{
" Description: Unlike vim's native tempname(), this function returns the name
"              of a temporary file in the directory specified. This enables
"              us to create temporary files in a specified directory.
function! Darcs_GetTempName(dirname)
	let prefix = 'darcsVimTemp'
	let slash = (a:dirname =~ '\\\|/$' ? '' : '/')
	let i = 0
	while filereadable(a:dirname.slash.prefix.i.'.tmp') && i < 1000
		let i = i + 1
	endwhile
	if filereadable(a:dirname.slash.prefix.i.'.tmp')
		echoerr "Temporary file could not be created in ".a:dirname
		return ''
	endif
	return expand(a:dirname.slash.prefix.i.'.tmp', ':p')
endfunction
" }}}
" Darcs_ToggleSilent: sets options to make vim "silent" {{{
let s:isSilent = 0
function! Darcs_ToggleSilent()
	let s:isSilent = 1 - s:isSilent
	if s:isSilent
		let s:_showcmd = &showcmd
		let s:_cmdheight = &cmdheight
		let s:_lz = &lz
		set noshowcmd
		set cmdheight=15
	else
		let &showcmd = s:_showcmd
		let &cmdheight = s:_cmdheight
		let &lz = s:_lz
	endif
endfunction " }}}
" Darcs_Debug: appends the argument into s:debugString {{{
" Description: 
" 
" Do not want a memory leak! Set this to zero so that latex-suite always
" starts out in a non-debugging mode.
if !exists('g:Darcs_Debug')
	let g:Darcs_Debug = 1
endif
function! Darcs_Debug(str, ...)
	if !g:Darcs_Debug
		return
	endif
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
" Darcs_PrintDebug: prings s:debugString {{{
function! Darcs_PrintDebug(...)
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = ''
	endif
	if exists('s:debugString_'.pattern)
		echo s:debugString_{pattern}
	endif
endfunction " }}}
" Darcs_ClearDebug: clears the s:debugString string {{{
function! Darcs_ClearDebug(...)
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = ''
	endif
	if exists('s:debugString_'.pattern)
		let s:debugString_{pattern} = ''
	endif
endfunction " }}}

" vim:fdm=marker
