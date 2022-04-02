let s:save_cpo = &cpoptions
set cpoptions&vim

let g:file_to_file#delimiter = get(g:, 'file_to_file#delimiter', '==FILE==')
let g:file_to_file#end_keyword = get(g:, 'file_to_file#end_keyword', 'END')
let g:file_to_file#is_enabled = get(g:, 'file_to_file#is_enabled', v:true)

function! s:normalize_path(path) abort
  let path = substitute(a:path, '$HOME', $HOME, 'g')
  return fnamemodify(path, ':p')
endfunction

function! s:extract_write_filename(line) abort
  let pos = match(a:line, g:file_to_file#delimiter)
  if pos == -1
    return ''
  endif
  return trim(strpart(a:line, pos + len(g:file_to_file#delimiter)))
endfunction

function! file_to_file#on() abort
  let g:file_to_file#is_enabled = v:true
endfunction

function! file_to_file#off() abort
  let g:file_to_file#is_enabled = v:false
endfunction

function! file_to_file#run() abort
  if ! g:file_to_file#is_enabled
    return
  endif

  let view = winsaveview()
  try
    call cursor(1, 1)
    while v:true
      if search(printf('%s ', g:file_to_file#delimiter), 'W') == 0
        return
      endif

      let start_lnum = getcurpos()[1]
      let first_line = getline(start_lnum)

      let file_name = s:extract_write_filename(first_line)
      if file_name ==# '' || file_name ==# g:file_to_file#end_keyword
        return
      endif
      let file_name = s:normalize_path(file_name)

      let res = searchpos(printf('%s %s', g:file_to_file#delimiter, g:file_to_file#end_keyword), 'n')
      if res == [0, 0]
        return
      endif

      let end_lnum = res[0]
      let contents = getline(start_lnum, end_lnum)

      call writefile(contents, file_name)
      call cursor(end_lnum + 1, 1)
    endwhile
  finally
    call winrestview(view)
  endtry
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
