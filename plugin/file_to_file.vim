if exists('g:loaded_vim_file_to_file')
  finish
endif
let g:loaded_vim_file_to_file = 1

aug VimFileToFile
  au!
  au BufWritePost * call file_to_file#run()
aug END

command! FileToFileOn call file_to_file#on()
command! FileToFileOff call file_to_file#off()
