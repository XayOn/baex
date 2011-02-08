" What:   timelog.vim:  Vim {,ft}plugin for keeping track of one's time.
" Usage:  source the file, or stick it in your ftplugin directory and
"         have ft=timelog on your modeline.
"         Keys:  n new job
"                t go
"                q stop 
"                s[1-9] sort by that column
" $Id: timelog.vim,v 1.0 2003/11/04 11:02:11 woodsar Exp woodsar $

" Changed date format from 2002-12-19 to 02-12-19.  Something odd with 
" something I'm using - strftime("%H:%M:%S",0) returns 01:00:00 on 
" linux and solaris, but not on bsd.  Just take offsets:
let datetest = strftime("%H:%M:%S",0)
let b:hoursOffset   = strpart(datetest,0,2)+0
let b:minutesOffset = strpart(datetest,3,2)+0
let b:secondsOffset = strpart(datetest,6,2)+0

function NewJob()
  let date = strftime("%y-%m-%d")
  " For somethings column starts at 0 others 1
  "         0             1         2
  "         0123456789    01234567890123456789
  let str = date . "  " . date . "  00:00:00  "
  call append(line("$"),str)
endfunction

function Convert()
  " Hard coded column numbers just now, but never mind.
  " get the string that represents the time, strip leading zeros
  " so that 08 and 09 don't convert to zero and convert to number
  let hours   = substitute(
                   \strpart(
                    \getline(
                        \line(".")),20,2),"^0","","")+0-b:hoursOffset
  let minutes = substitute(
                   \strpart(
                    \getline(
                        \line(".")),23,2),"^0","","")+0-b:minutesOffset
  let seconds = substitute(
                   \strpart(
                    \getline(
                        \line(".")),26,2),"^0","","")+0-b:secondsOffset
  let counted = hours*3600 + minutes*60 + seconds
  return counted
endfunction
 
function Counter()
  let b:counter = Convert()
  while 1
    sleep 1
    let b:counter = b:counter + 1
    " This finds the first time string.  Of course this assumes you don't 
    " spend more than 24 hours on a job.
    .s/[0-9]\+:[0-9]\+:[0-9]\+/\=strftime("%H:%M:%S",b:counter)/
    redraw
    if getchar(1)
      if nr2char(getchar()) == "q"
        break
      endif
    endif
  endwhile
  " Update the 'last' column - starts at column 11 at the moment
  .s/\%11c[0-9]\+-[0-9]\+-[0-9]\+/\=strftime("%y-%m-%d")/
endfunction

highlight ActiveJob ctermfg=white ctermbg=cyan guifg=white guibg=cyan


map j      j:exe ':match ActiveJob /\%' . line(".") . 'l/'<CR>
map k      k:exe ':match ActiveJob /\%' . line(".") . 'l/'<CR>
map <UP>   k
map <DOWN> j
map <LeftMouse> <LeftMouse>:exe ':match ActiveJob /\%' . line(".") . 'l/'<CR>
map n :execute NewJob()<CR>}:exe ':match ActiveJob /\%' . line(".") . 'l/'<CR>a
map t :call Counter()<CR>

" Sort only the timelog paragraph - need a blank line between it and any
" other content, or you could redefine your paragraph option
map s1 {/^[0-9]\+-[0-9]\+-[0-9]\+/<CR>!}sort<CR>
map s2 {/^[0-9]\+-[0-9]\+-[0-9]\+/<CR>!}sort +1<CR>
map s3 {/^[0-9]\+-[0-9]\+-[0-9]\+/<CR>!}sort +2<CR>
map s4 {/^[0-9]\+-[0-9]\+-[0-9]\+/<CR>!}sort +3<CR>
map s5 {/^[0-9]\+-[0-9]\+-[0-9]\+/<CR>!}sort +4<CR>
map s6 {/^[0-9]\+-[0-9]\+-[0-9]\+/<CR>!}sort +5<CR>
map s7 {/^[0-9]\+-[0-9]\+-[0-9]\+/<CR>!}sort +6<CR>
map s8 {/^[0-9]\+-[0-9]\+-[0-9]\+/<CR>!}sort +7<CR>
map s9 {/^[0-9]\+-[0-9]\+-[0-9]\+/<CR>!}sort +8<CR>
