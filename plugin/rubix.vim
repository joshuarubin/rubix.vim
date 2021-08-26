command! -nargs=* Only call rubix#only()
command! Kwbd call rubix#kwbd()

" <leader>m: Toggle Maximize current window
nnoremap <leader>m :call rubix#maximize_toggle()<cr>

" formatting shortcuts
nnoremap <silent> <leader>fa :call rubix#preserve('normal gg=G')<cr>
nnoremap <silent> <leader>f$ :call rubix#trim()<cr>

" ctrl-w, ctrl-w to delete the current buffer without closing the window
nnoremap <silent> <c-w><c-w> :confirm :Kwbd<cr>
