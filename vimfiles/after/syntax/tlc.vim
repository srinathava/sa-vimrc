syn match TlcComment /%%.*/
syn match TlcDirective /%\w\+/
syn match TlcString /"[^"]*"/ contains=TlcExpansion
syn match TlcExpansion /%<.*>/ contains=TlcString
syn match TlcBuiltin /\<[A-Z]\+\>\ze(/

hi def link TlcComment Comment
hi def link TlcDirective Keyword
hi def link TlcString String
hi def link TlcExpansion Macro
hi def link TlcBuiltin Type
