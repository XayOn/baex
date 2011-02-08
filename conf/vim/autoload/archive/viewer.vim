" Author:  Eric Van Dewoestine
"
" License: {{{
"   Copyright (c) 2005 - 2010, Eric Van Dewoestine
"   All rights reserved.
"
"   Redistribution and use of this software in source and binary forms, with
"   or without modification, are permitted provided that the following
"   conditions are met:
"
"   * Redistributions of source code must retain the above
"     copyright notice, this list of conditions and the
"     following disclaimer.
"
"   * Redistributions in binary form must reproduce the above
"     copyright notice, this list of conditions and the
"     following disclaimer in the documentation and/or other
"     materials provided with the distribution.
"
"   * Neither the name of Eric Van Dewoestine nor the names of its
"     contributors may be used to endorse or promote products derived from
"     this software without specific prior written permission of
"     Eric Van Dewoestine.
"
"   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
"   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
"   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
"   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
"   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
"   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
"   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
"   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
"   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
"   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
"   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
" }}}

" Global Variables {{{
  if !exists('g:ArchiveActions')
    let g:ArchiveActions = [
        \ {'pattern': '.*', 'name': 'Split', 'action': 'split'},
        \ {'pattern': '.*', 'name': 'Tab', 'action': 'tablast | tabnew'},
        \ {'pattern': '.*', 'name': 'Edit', 'action': 'edit'},
      \ ]
  endif
" }}}

" Script Variables {{{
let s:archive_path = substitute(expand("<sfile>:h:h"), '\', '/', 'g')

let s:command_list = 'archive.ArchiveListCommand "<file>"'
let s:command_list_all = 'archive.ArchiveListAllCommand "<file>"'
let s:command_read = 'archive.ArchiveReadCommand "<file>"'

let s:urls = {
    \ 'jar:': ['.jar', '.ear', '.war'],
    \ 'tar:': ['.tar'],
    \ 'tgz:': ['.tgz', '.tar.gz'],
    \ 'tbz2:': ['.tbz2', '.tar.bz2'],
    \ 'zip:': ['.zip', '.egg'],
  \ }

let s:file_regex =
  \ '\(.\{-}\)\s*[0-9]\+\s\+[0-9]\{4}-[0-9]\{2}-[0-9]\{2} [0-9]\{2}:[0-9]\{2}:[0-9]\{2}$'
" }}}

" List() {{{
" Lists the contents of the archive.
function! archive#viewer#List()
  if !filereadable(expand('%'))
    echohl WarningMsg
    echo 'Unable to read the file: ' . expand('%')
    echohl Normal
    return
  endif

  if !exists('b:archive_loaded')
    for action in g:ArchiveActions
      call archive#tree#RegisterFileAction(action.pattern, action.name, action.action)
    endfor

    let b:archive_loaded = 1
  endif

  let b:file_info = {}
  let file = substitute(expand('%:p'), '\', '/', 'g')
  if has('win32unix')
    let file = s:Cygpath(file, 'windows')
  endif
  let root = fnamemodify(file, ':t') . '/'
  let b:file_info[root] = {'url': s:FileUrl(file)}

  if exists('g:ArchiveLayout') && g:ArchiveLayout == 'list'
    setlocal modifiable
    call archive#viewer#ListAll()
    let g:ArchiveLayout = 'list'
    call append(0, '" use ? to view help')
    setlocal nomodifiable
  else
    setlocal modifiable
    call setline(1, root)
    call archive#viewer#ExpandDir()
    let g:ArchiveLayout = 'tree'
    setlocal modifiable
    call append(line('$'), ['', '" use ? to view help'])
    setlocal nomodifiable
  endif

  setlocal ft=archive
  setlocal nowrap
  setlocal noswapfile
  setlocal nobuflisted
  setlocal buftype=nofile
  setlocal bufhidden=delete
  setlocal foldtext=getline(v:foldstart)

  call s:Mappings()
  call archive#tree#Syntax()
endfunction " }}}

" ReadFile() {{{
" Reads the contents of an archived file.
function! archive#viewer#ReadFile()
  let file = substitute(expand('%'), '\', '/', 'g')
  let command = substitute(s:command_read, '<file>', file, '')

  let file = s:Execute(command)

  if string(file) != '0'
    let bufnum = bufnr('%')
    silent exec 'keepjumps edit! ' . escape(file, ' ')
    exec 'bdelete ' . bufnum

    " alternate solution, that keeps the archive url as the buffer's filename,
    " but prevents taglist from being able to parse tags.
    "setlocal noreadonly
    "setlocal modifiable
    "silent! exec "read " . file
    "1,1delete _

    silent exec "doautocmd BufReadPre " . file
    silent exec "doautocmd BufReadPost " . file

    setlocal readonly
    setlocal nomodifiable
    setlocal noswapfile
    " causes taglist.vim errors (fold then delete fails)
    "setlocal bufhidden=delete

    " delete temp files on vim exit
    if !exists('b:archive_cleanup')
      let tempdir = substitute(file, '\(^.\{-}\<vim-archive\>\).*', '\1', '')
      if has('unix') || has('macunix') || has('win32unix')
        let rm = 'rm -r "' . tempdir . '"'
      elseif has('win32') || has('win64')
        let rm = 'rmdir "' . tempdir . '" /s /q'
      endif
      augroup archive_cleanup
        autocmd!
        exec "autocmd VimLeave * call <SID>System('" . rm . "')"
      augroup END

      let b:archive_cleanup = 1
    endif
  endif
endfunction " }}}

" Execute(alt) {{{
function! archive#viewer#Execute(alt)
  if getline('.') =~ '^"\|^\s*$'
    return
  endif

  let path = archive#tree#GetPath()

  " execute action on dir
  if path =~ '/$'
    if a:alt || foldclosed(line('.')) != -1
      call archive#tree#ToggleFoldedDir(function('archive#viewer#ExpandDir'))
    else
      call archive#tree#ToggleCollapsedDir(function('archive#viewer#ExpandDir'))
    endif

  " execute action on file
  else
    let url = s:GetFilePath()
    let actions = archive#tree#GetFileActions(path)
    if a:alt
      call archive#tree#DisplayActionChooser(
        \ url, actions, 'archive#viewer#ExecuteAction')
    else
      call archive#viewer#ExecuteAction(url, actions[0].action)
    endif
  endif
endfunction " }}}

" ExecuteAction(file, command) {{{
function! archive#viewer#ExecuteAction(file, command)
  let command = a:command
  if command == 'edit'
    if !exists('b:archive_edit_window') ||
     \ getwinvar(b:archive_edit_window, 'archive_edit_window') == ''
      let bufnr = bufnr('%')
      new
      let w:archive_edit_window = 1
      call setbufvar(bufnr, 'archive_edit_window', winnr())
    else
      exec b:archive_edit_window . 'winc w'
    endif
  endif

  if exists('b:archive_edit_window') &&
   \ getwinvar(b:archive_edit_window, 'archive_edit_window') == 1
    exec b:archive_edit_window . 'winc w'
  endif

  " windows may throw a Permission Denied error attempting to split using the
  " archive file name, but opening the window and then editing the file works
  if (has('win32') || has('win64')) && command =~ 'split'
    exec substitute(command, 'split', 'new', 'g')
    let command = 'silent edit'
  endif

  try
    noautocmd exec command . ' ' . escape(a:file, ' ')
  catch /E303/
    " ignore error to create swap file (seems to only be an issue on windows)
  endtry
  call archive#viewer#ReadFile()
endfunction " }}}

" ExpandDir() {{{
function! archive#viewer#ExpandDir()
  let path = substitute(expand('%:p'), '\', '/', 'g')
  if has('win32unix')
    let path = s:Cygpath(path, 'windows')
  endif
  let dir = b:file_info[getline('.')].url
  if dir !~ path . '$' && s:IsArchive(dir)
    let dir = s:FileUrl(dir) . '!/'
  endif
  let command = s:command_list
  let command = substitute(command, '<file>', dir, '')
  let results = split(s:Execute(command), '\n')
  if len(results) == 1 && results[0] == '0'
    return
  endif

  let dirs = []
  let files = []
  let temp_info = {}
  for entry in results
    let parsed = s:ParseEntry(entry)
    let temp_info[parsed.name] = parsed
    if parsed.type == 'folder' || s:IsArchive(parsed.name)
      call add(dirs, parsed.name . '/')
    else
      call add(files, parsed.name)
    endif
  endfor

  let content = archive#tree#WriteContents('^', dirs, files)
  " hacky, but works
  for key in sort(keys(temp_info))
    let index = 0
    for line in content
      if line =~ '^\s*+\?\s*' . escape(key, '.') . '/\?$'
        let b:file_info[line] = temp_info[key]
        call remove(content, index)
        continue
      endif
      let index += 1
    endfor
  endfor
endfunction " }}}

" ListAll() {{{
" Function for listing all the archive files (for 'list' layout).
function! archive#viewer#ListAll()
  let path = substitute(expand('%:p'), '\', '/', 'g')
  if has('win32unix')
    let path = s:Cygpath(path, 'windows')
  endif
  let command = s:command_list_all
  let command = substitute(command, '<file>', path, '')
  let results = split(s:Execute(command), '\n')
  if len(results) == 1 && results[0] == '0'
    return
  endif

  let temp = substitute(results[0], '\', '/', 'g')
  exec 'read ' . escape(temp, ' ')
  call delete(temp)
endfunction " }}}

" s:GetFilePath() {{{
function! s:GetFilePath()
  if g:ArchiveLayout == 'list'
    let file = substitute(getline('.'), s:file_regex, '\1', '')
    let archive = substitute(expand('%:p'), '\', '/', 'g')
    if has('win32unix')
      let archive = s:Cygpath(archive, 'windows')
    endif
    let url = s:FileUrl(archive) . '!/' . file
  else
    let url = b:file_info[getline('.')].url
  endif
  return url
endfunction " }}}

" s:ParseEntry(entry) {{{
function! s:ParseEntry(entry)
  let info = split(a:entry, '|')
  let parsed = {}
  let parsed.path = info[0]
  let parsed.name = info[1]
  let parsed.url = info[2]
  let parsed.type = info[3]
  let parsed.size = info[4]
  let parsed.date = len(info) > 5 ? info[5] : ''
  return parsed
endfunction " }}}

" s:FileUrl(file) {{{
function! s:FileUrl(file)
  let url = a:file
  if url =~ '^[a-zA-Z]:'
    let url = '/' . url
  endif
  for key in keys(s:urls)
    for ext in s:urls[key]
      if url =~ escape(ext, '.') . '$'
        let url = key . url
        break
      endif
    endfor
  endfor
  return url
endfunction " }}}

" s:IsArchive(file) {{{
function! s:IsArchive(file)
  let url = a:file
  for key in keys(s:urls)
    for ext in s:urls[key]
      if url =~ escape(ext, '.') . '$'
        return 1
      endif
    endfor
  endfor
  return 0
endfunction " }}}

" s:ChangeLayout(layout) {{{
function! s:ChangeLayout(layout)
  if g:ArchiveLayout != a:layout
    let g:ArchiveLayout = a:layout
    setlocal modifiable
    edit
  endif
endfunction " }}}

" s:OpenFile(action) " {{{
function! s:OpenFile(action)
  let path = s:GetFilePath()
  call archive#viewer#ExecuteAction(path, a:action)
endfunction " }}}

" s:FileInfo() {{{
function! s:FileInfo()
  let info = b:file_info[substitute(getline('.'), '^\(\s*\)-\(.*/$\)', '\1+\2', '')]
  if has_key(info, 'type') && info.type == 'file'
    echo printf('size: %-15s', info.size) . ' date: ' . info.date
  endif
endfunction " }}}

" s:Mappings() {{{
function! s:Mappings()
  nmap <buffer> <silent> <cr> :call archive#viewer#Execute(0)<cr>
  nmap <buffer> <silent> E :call <SID>OpenFile('edit')<cr>
  nmap <buffer> <silent> S :call <SID>OpenFile('split')<cr>
  nmap <buffer> <silent> T :call <SID>OpenFile('tablast \| tabnew')<cr>

  if g:ArchiveLayout == 'tree'
    let b:tree_mappings_active = 1
    let b:hierarchy_help = [
        \ '<cr> - open/close dir, open file',
        \ 'o - toggle dir fold, choose file open action',
        \ 'E - open with :edit',
        \ 'S - open in a new split window',
        \ 'T - open in a new tab',
        \ 'p - move cursor to parent dir',
        \ 'P - move cursor to last child of dir',
        \ 'i - view file info',
        \ ':AsList - switch to list view',
      \ ]
    nmap <buffer> <silent> j    :TreeNextPrevLine j<cr>
    nmap <buffer> <silent> k    :TreeNextPrevLine k<cr>
    nmap <buffer> <silent> o    :call archive#viewer#Execute(1)<cr>
    nmap <buffer> <silent> p    :call archive#tree#MoveToParent()<cr>
    nmap <buffer> <silent> P    :call archive#tree#MoveToLastChild()<cr>
    nmap <buffer> <silent> i    :call <SID>FileInfo()<cr>
    nmap <buffer> <silent> I    :call <SID>FileInfo()<cr>

    silent! delcommand AsTree
    command! -nargs=0 AsList :call <SID>ChangeLayout('list')

    " only needed as a command to support counts on the j/k mappings
    command! -nargs=? -count=1 -buffer TreeNextPrevLine
      \ let c = <count> |
      \ let c = c > 1 ? c - line('.') + 1 : c |
      \ let prev = line('.') |
      \ exec 'normal! ' . c . '<args>' |
      \ call archive#tree#Cursor(line('.'), prev)
  else
    if exists('b:tree_mappings_active')
      unlet b:tree_mappings_active
      unmap <buffer> j
      unmap <buffer> k
      unmap <buffer> p
      unmap <buffer> P
      unmap <buffer> i
      unmap <buffer> I
    endif

    let b:hierarchy_help = [
        \ '<cr> - open/close dir, open file',
        \ 'o - choose file open action',
        \ 'E - open with :edit',
        \ 'S - open in a new split window',
        \ 'T - open in a new tab',
        \ ':AsTree - switch to tree view',
      \ ]

    silent! delcommand AsList
    command! -nargs=0 AsTree :call <SID>ChangeLayout('tree')
  endif

  nnoremap <buffer> <silent> ?
    \ :call <SID>BufferHelp(b:hierarchy_help, 'horizontal', 10)<cr>

endfunction " }}}

" s:Execute(command) {{{
function! s:Execute(command)
  if !exists('s:classpath')
    let separator = has('win32') || has('win64') || has('win32unix') ? ';' : ':'
    let jars = split(glob(s:archive_path . '/archive/*.jar'), "\n")
    let jars = map(jars, 'substitute(v:val, "\\", "/", "g")')
    if has('win32unix')
      let jars = map(jars, 's:Cygpath(v:val, "windows")')
    end
    let archive_path = s:archive_path
    if has('win32unix')
      let archive_path = s:Cygpath(s:archive_path, 'windows')
    endif
    let s:classpath = join(jars, separator) . separator . archive_path
  endif

  if !exists('s:sources') || !exists('s:built')
    let build = 0
    let s:sources = split(glob(s:archive_path . '/archive/*.java'), "\n")
    let s:sources = map(s:sources, 'substitute(v:val, "\\", "/", "g")')
    if has('win32unix')
      let s:sources = map(s:sources, 's:Cygpath(v:val, "windows")')
    endif
    for src in s:sources
      let class = fnamemodify(src, ':r') . '.class'
      if !filereadable(class) || getftime(src) > getftime(class)
        let build = 1
        break
      endif
    endfor
    if !build
      let s:built = 1
    else
      let build_command =
        \ 'javac -cp "' . s:classpath . '" "' . join(s:sources, '" "') . '"'
      echo 'Compiling Archive Source...'
      let output = s:System(build_command)
      redraw | echo ''
      if v:shell_error
        echohl Error
        echom 'Failed to compile source (' . build_command . '): ' . output
        echohl Normal
        return
      endif
    endif
  endif

  let command = 'java -client -cp "' . s:classpath . '" ' . a:command
  let result = s:System(command)
  if v:shell_error
    echohl Error
    echom 'Failed to execute command (' . command . '): ' . result
    echohl Normal
    return
  endif
  return result
endfunction " }}}

" s:System(cmd) {{{
" Executes system() accounting for possibly disruptive vim options.
function! s:System(cmd)
  let saveshell = &shell
  let saveshellcmdflag = &shellcmdflag
  let saveshellpipe = &shellpipe
  let saveshellquote = &shellquote
  let saveshellredir = &shellredir
  let saveshellslash = &shellslash
  let saveshelltemp = &shelltemp
  let saveshellxquote = &shellxquote

  if has('win32') || has('win64')
    set shell=cmd.exe shellcmdflag=/c
    set shellpipe=>%s\ 2>&1 shellredir=>%s\ 2>&1
    set shellquote= shellxquote=
    set shelltemp noshellslash
  else
    if executable('/bin/bash')
      set shell=/bin/bash
    else
      set shell=/bin/sh
    endif
    set shellcmdflag=-c
    set shellpipe=2>&1\|\ tee shellredir=>%s\ 2>&1
    set shellquote= shellxquote=
    set shelltemp noshellslash
  endif

  let result = system(a:cmd)

  let &shell = saveshell
  let &shellcmdflag = saveshellcmdflag
  let &shellquote = saveshellquote
  let &shellslash = saveshellslash
  let &shelltemp = saveshelltemp
  let &shellxquote = saveshellxquote
  let &shellpipe = saveshellpipe
  let &shellredir = saveshellredir

  return result
endfunction " }}}

" s:Cygpath(path, type) {{{
function! s:Cygpath(path, type)
  if executable('cygpath')
    let path = substitute(a:path, '\', '/', 'g')
    if a:type == 'windows'
      let path = s:System('cygpath -m "' . path . '"')
    else
      let path = s:System('cygpath "' . path . '"')
    endif
    let path = substitute(path, '\n$', '', '')
    return path
  endif
  return a:path
endfunction " }}}

" s:BufferHelp(lines, orientation, size) {{{
" Function to display a help window for the current buffer.
function! s:BufferHelp(lines, orientation, size)
  let orig_bufnr = bufnr('%')
  let name = expand('%')
  if name =~ '^\W.*\W$'
    let name = name[:-2] . ' Help' . name[len(name) - 1]
  else
    let name .= ' Help'
  endif

  let orient = a:orientation == 'vertical' ? 'v' : ''
  if bufwinnr(name) != -1
    exec 'bd ' . bufnr(name)
    return
  endif

  silent! noautocmd exec a:size . orient . "new " . escape(name, ' ')
  if a:orientation == 'vertical'
    setlocal winfixwidth
  else
    setlocal winfixheight
  endif
  setlocal nowrap
  setlocal noswapfile nobuflisted nonumber
  setlocal buftype=nofile bufhidden=delete
  nnoremap <buffer> <silent> ? :close<cr>
  nnoremap <buffer> <silent> q :close<cr>

  setlocal modifiable noreadonly
  silent 1,$delete _
  call append(1, a:lines)
  retab
  silent 1,1delete _

  if len(a:000) == 0 || a:000[0]
    setlocal nomodified nomodifiable readonly
  endif

  let help_bufnr = bufnr('%')
  augroup help_buffer
    autocmd! BufWinLeave <buffer>
    autocmd BufWinLeave <buffer> nested autocmd! help_buffer * <buffer>
    exec 'autocmd BufWinLeave <buffer> nested ' .
      \ 'autocmd! help_buffer * <buffer=' . orig_bufnr . '>'
    exec 'autocmd! BufWinLeave <buffer=' . orig_bufnr . '>'
    exec 'autocmd BufWinLeave <buffer=' . orig_bufnr . '> nested bd ' . help_bufnr
  augroup END

  return help_bufnr
endfunction " }}}

" vim:ft=vim:fdm=marker
