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
  if !exists("g:TreeDirHighlight")
    let g:TreeDirHighlight = "Statement"
  endif
  if !exists("g:TreeFileHighlight")
    let g:TreeFileHighlight = "Normal"
  endif
  if !exists("g:TreeFileExecutableHighlight")
    let g:TreeFileExecutableHighlight = "Constant"
  endif
  if !exists("g:TreeActionHighlight")
    let g:TreeActionHighlight = "Statement"
  endif
" }}}

" Script Variables {{{
  let s:node_prefix = '  '

  let s:dir_opened_prefix = '- '
  let s:dir_closed_prefix = '+ '
  let s:file_prefix = '  '

  let s:indent_length = 4

  let s:node_regex = s:node_prefix .  '\(' .
    \ s:dir_opened_prefix . '\|' .
    \ s:dir_closed_prefix . '\|' .
    \ s:file_prefix . '\)'
  " \1 - indent, \2, node prefix + element prefix, \3 name
  let s:nodevalue_regex = '\(\s*\)' . s:node_regex . '\(.*\)'
  let s:root_regex = '^[/[:alpha:]]'

  let s:settings_loaded = 0

  let s:tree_count = 0
  let s:refresh_nesting = 0

  let s:has_ls = executable('ls') && !(has('win32') || has('win64'))

  let s:vcol = 0
" }}}

" ToggleCollapsedDir(Expand) {{{
function! archive#tree#ToggleCollapsedDir(Expand)
  if archive#tree#GetPath() =~ '/$'
    if getline('.') =~ '\s*' . s:node_prefix . s:dir_closed_prefix ||
        \ (getline('.') =~ s:root_regex && archive#tree#GetLastChildPosition() == line('.'))
      call a:Expand()
    else
      call s:CollapseDir()
    endif
  endif
endfunction " }}}

" ToggleFoldedDir(Expand) {{{
function! archive#tree#ToggleFoldedDir(Expand)
  if archive#tree#GetPath() =~ '/$'
    if foldclosed(line('.')) != -1
      call s:UnfoldDir()
    elseif getline('.') =~ '\s*' . s:node_prefix . s:dir_opened_prefix ||
        \ (getline('.') =~ s:root_regex && archive#tree#GetLastChildPosition() != line('.'))
      call s:FoldDir()
    else
      call a:Expand()
    endif
  endif
endfunction " }}}

" GetPath() {{{
function! archive#tree#GetPath()
  let line = getline('.')
  let node = substitute(line, s:nodevalue_regex, '\3', '')
  return archive#tree#GetParent() . node
endfunction "}}}

" GetParent() {{{
function! archive#tree#GetParent()
  let parent = ''

  let lnum = archive#tree#GetParentPosition()
  if lnum
    let pos = getpos('.')
    call cursor(lnum, 1)
    let parent = archive#tree#GetPath()
    call setpos('.', pos)
  endif

  return parent
endfunction " }}}

" GetParentPosition() {{{
function! archive#tree#GetParentPosition()
  let lnum = 0
  let line = getline('.')
  if line =~ '\s*' . s:node_prefix
    if line =~ '^' . s:node_regex . '\S'
      let search = s:root_regex
    else
      let search = '^'
      let index = 0
      let indent = s:GetIndent(line('.'))
      while index < indent - s:indent_length
        let search .= ' '
        let index += 1
      endwhile
      let search .= s:node_prefix .  s:dir_opened_prefix
    endif

    let lnum = search(search, 'bnW')
  endif

  return lnum
endfunction " }}}

" GetLastChildPosition() {{{
function! archive#tree#GetLastChildPosition()
  let line = getline('.')

  " a root node
  if line =~ s:root_regex
    let lnum = search(s:root_regex, 'nW')
    return lnum > 0 ? lnum  - 1 : s:GetLastLine()
  endif

  " non root node
  let sibling = '^' .
    \ substitute(line, s:nodevalue_regex, '\1' . escape(s:node_regex. '[.[:alnum:]_]', '\'), '')
  let lnum = line('.') + 1
  let indent = s:GetIndent(line('.'))
  while getline(lnum) !~ sibling &&
      \ s:GetIndent(lnum) >= indent &&
      \ lnum != s:GetLastLine()
    let lnum += 1
  endwhile

  " back up one if on a node of equal or less depth
  if s:GetIndent(lnum) <= indent
    let lnum -= 1
  endif

  " no sibling below, use parent's value
  if lnum == line('.') && getline(lnum + 1) !~ sibling
    let pos = getpos('.')

    call cursor(archive#tree#GetParentPosition(), 1)
    let lnum = archive#tree#GetLastChildPosition()

    call setpos('.', pos)
  endif

  return lnum
endfunction " }}}

" ExecuteAction(file, command) {{{
function! archive#tree#ExecuteAction(file, command)
  let path = fnamemodify(a:file, ':h')
  let path = substitute(path, '\', '/', 'g')

  let file = fnamemodify(a:file, ':t')
  let file = escape(file, ' &()')
  let file = escape(file, ' &()') " need to double escape
  let file = escape(file, '&') " '&' needs to be escaped 3 times.

  let cwd = substitute(getcwd(), '\', '/', 'g')
  " not using lcd, because the executed command may change windows.
  if has('win32unix')
    let path = eclim#cygwin#CygwinPath(path)
  endif
  silent exec 'cd ' . escape(path, ' &#')
  try
    let command = a:command
    let command = substitute(command, '<file>', file, 'g')
    let command = substitute(command, '<cwd>', cwd, 'g')
    if command =~ '^!\w'
      silent call eclim#util#Exec(command)
    else
      call eclim#util#Exec(command)
    endif
    redraw!
  finally
    silent exec 'cd ' . escape(cwd, ' &')
  endtry

  if command =~ '^!\w' && v:shell_error
    call eclim#util#EchoError('Error executing command: ' . command)
  endif
endfunction " }}}

" RegisterFileAction(regex, name, action) {{{
" regex - Pattern to match the file name against.
" name - Name of the action used for display purposes.
" action - The action to execute where <file> is replaced with the filename.
function! archive#tree#RegisterFileAction(regex, name, action)
  if !exists('b:file_actions')
    let b:file_actions = []
  endif

  let entry = {}
  for e in b:file_actions
    if e.regex == a:regex
      let entry = e
      break
    endif
  endfor

  if len(entry) == 0
    let entry = {'regex': a:regex, 'actions': []}
    call add(b:file_actions, entry)
  endif

  call add(entry.actions, {'name': a:name, 'action': a:action})
endfunction " }}}

" GetFileActions(file) {{{
" Returns a list of dictionaries with keys 'name' and 'action'.
function! archive#tree#GetFileActions(file)
  let actions = []
  let thefile = tolower(a:file)
  let bufnr = bufnr('%')
  for entry in b:file_actions
    if thefile =~ entry.regex
      let actions += entry.actions
    endif
  endfor

  return actions
endfunction " }}}

" Cursor(line, prevline) {{{
function! archive#tree#Cursor(line, prevline)
  let lnum = a:line
  let line = getline(lnum)

  if line =~ s:root_regex
    call cursor(lnum, 1)
  else
    " get the starting column of the current line and the previous line
    let start = len(line) - len(substitute(line, '^\s\+\W', '', ''))

    " only use the real previous line if we've only moved one line
    let pline = abs(a:prevline - lnum) == 1 ? getline(a:prevline) : ''
    let pstart = pline != '' ?
      \ len(pline) - len(substitute(pline, '^\s\+\W', '', '')) : -1

    " only change the cursor column if the hasn't user has moved it to the
    " right to view more of the entry
    let cnum = start == pstart ? 0 : start
    call cursor(lnum, cnum)

    " attempt to maximize the amount of text on the current line that is in
    " view, but only if we've changed column position
    let winwidth = winwidth(winnr())
    let vcol = exists('s:vcol') ? s:vcol : 0
    let col = col('.')
    if cnum != 0 && (!vcol || ((len(line) - vcol) > winwidth))
      if len(line) > winwidth
        normal! zs
        " scroll back enough to keep the start of the parent in view
        normal! 6zh
        let s:vcol = col - 6
      endif
    endif

    " when the text view is shifted by vim it appears to always shift back one
    " half of the window width, so recalculate our visible column accordingly
    " if we detect such a shift... may not always be accurate.
    if s:vcol > col
      let s:vcol = max([start - (winwidth / 2), 0])
    endif
  endif
endfunction " }}}

" MoveToLastChild() {{{
function! archive#tree#MoveToLastChild()
  mark '
  if getline('.') !~ '^\s*' . s:node_prefix . s:dir_opened_prefix . '[.[:alnum:]_]'
    call cursor(archive#tree#GetParentPosition(), 1)
  endif
  call archive#tree#Cursor(archive#tree#GetLastChildPosition(), 0)
endfunction " }}}

" MoveToParent() {{{
function! archive#tree#MoveToParent()
  mark '
  call archive#tree#Cursor(archive#tree#GetParentPosition(), 0)
endfunction " }}}

" WriteContents(dir, dirs, files) {{{
function! archive#tree#WriteContents(dir, dirs, files)
  let dirs = a:dirs
  let files = a:files
  let indent = s:GetChildIndent(line('.'))
  call map(dirs,
    \ 'substitute(v:val, a:dir, indent . s:node_prefix . s:dir_closed_prefix, "")')
  call map(files,
    \ 'substitute(v:val, a:dir, indent . s:node_prefix . s:file_prefix, "")')

  " update current line
  call s:UpdateLine(s:node_prefix . s:dir_closed_prefix,
    \ s:node_prefix . s:dir_opened_prefix)

  setlocal noreadonly modifiable
  let content = dirs + files
  call append(line('.'), content)
  setlocal nomodifiable
  return content
endfunction " }}}

" s:CollapseDir() {{{
function! s:CollapseDir()
  " update current line
  call s:UpdateLine(s:node_prefix . s:dir_opened_prefix,
    \ s:node_prefix . s:dir_closed_prefix)

  let lnum = line('.')
  let cnum = col('.')
  let start = lnum + 1
  let end = archive#tree#GetLastChildPosition()

  if start > end
    return
  endif

  setlocal noreadonly modifiable
  silent exec start . ',' . end . 'delete _'
  setlocal nomodifiable

  call cursor(lnum, cnum)
endfunction " }}}

" s:UnfoldDir() {{{
function! s:UnfoldDir()
  foldopen
endfunction " }}}

" s:FoldDir() {{{
function! s:FoldDir()
  let start = line('.')
  let end = archive#tree#GetLastChildPosition()

  exec start . ',' . end . 'fold'
endfunction " }}}

" s:GetIndent() {{{
function! s:GetIndent(line)
  let indent = indent(a:line)
  if getline(a:line) =~ s:file_prefix . '[.[:alnum:]_]' && s:file_prefix =~ '^\s*$'
    let indent -= len(s:file_prefix)
  endif
  if s:node_prefix =~ '^\s*$'
    let indent -= len(s:node_prefix)
  endif

  return indent
endfunction " }}}

" s:GetLastLine() {{{
function! s:GetLastLine()
  let line = line('$')
  while getline(line) =~ '^"\|^\s*$' && line > 1
    let line -= 1
  endwhile
  return line
endfunction " }}}

" s:GetChildIndent() {{{
function! s:GetChildIndent(line)
  let indent = ''
  if getline(a:line) =~ '\s*' . s:node_prefix
    let num = indent(a:line)

    if s:node_prefix =~ '^\s*$'
      let num -= len(s:node_prefix)
    endif

    let index = 0
    while index < num + s:indent_length
      let indent .= ' '
      let index += 1
    endwhile
  endif

  return indent
endfunction " }}}

" s:UpdateLine(pattern, substitution) {{{
function! s:UpdateLine(pattern, substitution)
  let lnum = line('.')
  let line = getline(lnum)
  let line = substitute(line, a:pattern, a:substitution, '')

  setlocal noreadonly modifiable
  call append(lnum, line)
  silent exec lnum . ',' . lnum . 'delete _'
  setlocal nomodifiable
endfunction " }}}

" DisplayActionChooser(file, actions, executeFunc) {{{
function! archive#tree#DisplayActionChooser(file, actions, executeFunc)
  new
  let height = len(a:actions) + 1

  exec 'resize ' . height

  setlocal noreadonly modifiable
  let b:actions = a:actions
  let b:file = a:file
  for action in a:actions
    call append(line('$'), action.name)
  endfor

  exec 'nmap <buffer> <silent> <cr> ' .
    \ ':call archive#tree#ActionExecute("' . a:executeFunc . '")<cr>'
  nmap <buffer> q :q<cr>

  exec "hi link TreeAction " . g:TreeActionHighlight
  syntax match TreeAction /.*/

  1,1delete _
  setlocal nomodifiable
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=delete
endfunction "}}}

" ActionExecute(executeFunc) {{{
function! archive#tree#ActionExecute(executeFunc)
  let command = ''
  let line = getline('.')
  for action in b:actions
    if action.name == line
      let command = action.action
      break
    endif
  endfor

  let file = b:file
  close
  call function(a:executeFunc)(file, command)
endfunction "}}}

" Syntax() {{{
function! archive#tree#Syntax()
  exec "hi link TreeDir " . g:TreeDirHighlight
  exec "hi link TreeFile " . g:TreeFileHighlight
  exec "hi link TreeFileExecutable " . g:TreeFileExecutableHighlight
  hi link TreeMarker Normal
  syntax match TreeMarker /^\s*[-+]/
  syntax match TreeDir /\S.*\// contains=TreeMarker
  syntax match TreeFile /\S.*[^\/]$/
  syntax match TreeFileExecutable /\S.*[^\/]\*$/
  syntax match Comment /^".*/
endfunction " }}}

" vim:ft=vim:fdm=marker
