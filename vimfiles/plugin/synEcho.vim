function! SynItemEcho()
	let attr = synIDattr(synID(line("."),col("."),1),"name")
	let transattr = synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
	let guifg = synIDattr(synIDtrans(synID(line("."),col("."),1)),"fg")
	let guibg = synIDattr(synIDtrans(synID(line("."),col("."),1)),"bg")
	let guifgn = synIDattr(synIDtrans(synID(line("."),col("."),1)),"fg#")
	let guibgn = synIDattr(synIDtrans(synID(line("."),col("."),1)),"bg#")
	echo 'Higlight Info: <'.attr.'><'.transattr.'><'.guifg.':'.guifgn.'><'.guibg.':'.guibgn.'>'
endfunction

" echo the highlight group currently under cursor. (from vim.source...)
map  <F8>  :call SynItemEcho()<cr>
