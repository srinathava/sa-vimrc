" ==============================================================================
" A small plugin to enable editing textarea's in Firefox in Vim.
"
" This plugin cooperates with the the mozex.xpi script (a modified version
" of the mozex plugin). The ideal usability scenario is:
"
" 1. user is editing a textarea in firefox and decides that we wants to use
"    vim to do it instead.
" 2. He double clicks on the textarea. The textarea contents become
"    read-only and a Vim instance is opened up with the contents of the
"    texarea.
" 3. The user begins editing the contents in Vim. During this time, he can
"    go back to Firefox and single-click in the textarea. The contents of
"    the textarea will be updated based on the latest contents of the Vim
"    file. However, the textarea *remains read-only*. He can keep doing
"    this as many times as he wants while Vim is still alive.
" 4. When the user is done editing vim, he quits Vim.
" 5. Goes back to Firefox and single-clicks on the textarea. This time, the
"    contents of the text-area are updated and the textarea becomes
"    writeable.
"
" The algorithm for mozex.xpi:
"
"   fname = CreateUniqueFilenameFromURL()
"
"   if singleClickInTextArea:
"       if fileExists(fname):
"           updateTextAreaWithContents(fname)
"           fnameDone = fname + '.done'
"           if fileExists(fnameDone):
"               deleteFile(fname)
"               deleteFile(fnameDone)
"
"   elif doubleClickInTextArea:
"       if not fileExists(fname):
"           createFile(fname, textAreaContents)
"           startExternalEditorWith(fname)
"       else:
"           # do not do anything.
" 
" The algorithm in this plugin is simple:
"   
"   if startedFromMozex:
"       CreateAutocommandForDoneFileToBeCreated()
"
" Basically, Vim can figure out that it was mozex which started it from the
" filename.  When it exits, it creates another dummy file which has the
" original filename appended with '.done' to signal mozex that it is done
" editing.
"
" Note that there is a potential (serious) problem here. Since Vim cannot
" "push" its data beack to Firefox when it quits (I don't know how),
" Firefox is responsible for removing the file and the .done file. If
" Firefox is killed before it can do this (for example if the user
" navigates away from the page when vim is still alive and the .done file
" is not created), then noone will remove the file and the .done file.
" Essentially they are orphaned. Next time the user navigates to the page
" (say 3 days hence) and single clicks in the textarea, the contents of the
" textarea will be suddenly filled with the contents from 3 days hence.
" ============================================================================== 

" AddToMozexFiles: create autocommand for .done file to be created {{{
function! AddToMozexFiles()
    " If we are editing a mozex textarea file and if an autocommand has not
    " already been created, create one now.
    if expand('%:p') =~ '\c^c:/tmp/mozex.textarea.*\.txt' && 
        \ !exists('b:CreateTextareaDoneFile')
        exec "au VimLeavePre * :call writefile(['done'], '".expand('%:p').".done')"
        let b:CreateTextareaDoneFile = 1
    endif
endfunction " }}}

augroup AddMozexFilesToRemoveList
    au!
    au BufEnter * :call AddToMozexFiles()
augroup END

" vim: fdm=marker
