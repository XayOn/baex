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
if !exists('g:ArchiveViewerEnabled')
  let g:ArchiveViewerEnabled = 1
endif

if g:ArchiveViewerEnabled
  " disable tar.vim autocmds... tar.vim is now included w/ vim7
  let g:loaded_tarPlugin = 1
  silent! autocmd! tar

  " disable zipPlugin.vim autocmds... zipPlugin.vim is now included w/ vim7
  let g:loaded_zipPlugin = 1
  silent! autocmd! zip
endif
" }}}

" Autocmds {{{
augroup archive_read
  autocmd!
  autocmd BufReadCmd
    \ jar:/*,jar:\*,jar:file:/*,jar:file:\*,
    \tar:/*,tar:\*,tar:file:/*,tar:file:\*,
    \tbz2:/*,tgz:\*,tbz2:file:/*,tbz2:file:\*,
    \tgz:/*,tgz:\*,tgz:file:/*,tgz:file:\*,
    \zip:/*,zip:\*,zip:file:/*,zip:file:\*
    \ call archive#viewer#ReadFile()
augroup END

if g:ArchiveViewerEnabled
  augroup archive
    autocmd!
    autocmd BufReadCmd *.egg     call archive#viewer#List()
    autocmd BufReadCmd *.jar     call archive#viewer#List()
    autocmd BufReadCmd *.war     call archive#viewer#List()
    autocmd BufReadCmd *.ear     call archive#viewer#List()
    autocmd BufReadCmd *.zip     call archive#viewer#List()
    autocmd BufReadCmd *.tar     call archive#viewer#List()
    autocmd BufReadCmd *.tgz     call archive#viewer#List()
    autocmd BufReadCmd *.tar.gz  call archive#viewer#List()
    autocmd BufReadCmd *.tar.bz2 call archive#viewer#List()
  augroup END
endif
" }}}

" vim:ft=vim:fdm=marker
