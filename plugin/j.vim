fun! s:gethour()
  return strftime("%H")
endf

fun! s:getyear()
  return strftime("%Y")
endf

fun! s:getmonth()
  return strftime("%m")
endf

" define below for new date headers
fun! s:getstrdate()
  return strftime("%d.%m.%Y")
endf

" define below for new month names
fun! s:getstrmonth(month)
  if a:month==1
    return "january"
  elseif a:month==2
    return "february"
  elseif a:month==3
    return "march"
  elseif a:month==4
    return "april"
  elseif a:month==5
   return "may"
  elseif a:month==6
    return "june"
  elseif a:month==7
    return "july"
  elseif a:month==8
    return "august"
  elseif a:month==9
    return "september"
  elseif a:month==10
    return "october"
  elseif a:month==11
    return "november"
  else
    return "december"
  endif
endf

fun! s:getstrfilename()
  return s:getstrmonth(strftime("%m")) . ".txt"
endf

fun! s:fcd(dir)
  if !isdirectory(a:dir)
    system('mkdir ' . a:dir)
  endif
  exe "lcd" a:dir
endf

fun! s:settimer(state)
  aug journal
  au!
  if (a:state==?"on")
"   here's a nice workaround for a regenerative CursorHold event, suggested by
"   Antony Scriven
    au CursorHold * exe "norm! :\<ESC>" | call <SID>triggered_journal_event()
  endif
  au BufUnload * call <SID>uninstall(expand("<abuf>")) | if !exists("*s:reset_event") | delf s:uninstall | endif
  aug end
endf

fun! s:reset_event()
" first cd to our private directory
  call s:fcd(s:jdir)
" and the appropriate year directory
  call s:fcd(s:jdir . s:getyear())

  if s:lastmonth!=s:getmonth()
    let s:lastmonth=s:getmonth()
"   and start editing the appropriate month file
    exe 'edit' s:getstrfilename()
    if !filereadable(s:getstrfilename())
      exe 'X'
    endif

    let s:winnum=winnr()
    let s:bufnum=bufnr("")

    nmap <buffer> <Leader>E o<C-R>=<SID>gethour() . ":00 "<CR>
    nmap <buffer> <Leader>D o<ESC>o<C-R>=<SID>getstrdate()<CR>

"   enter appropriate date
    if !search(s:getstrdate(), "w")
"     don't append if new file
      if filereadable(s:getstrfilename())
        call append("$", "")
        call append("$", s:getstrdate())
      else
        call setline(1, s:getstrdate())
      endif
      call append("$", s:gethour() . ":00 ")
      startinsert
      $
      norm! $
    endif
  endif 
endf

fun! s:triggered_journal_event()
  if (s:lasthour!=s:gethour()) 
    let s:lasthour=s:gethour()

    let s:winold=winnr()
    let s:bufold=bufnr("")
    exe "norm! \<C-W>" s:winnum 
    exe "buffer!" s:bufnum

    exe "norm! \<ESC>"
    sleep
    exe "norm! \<ESC>"
    sleep
    exe "norm! \<ESC>"
    sleep
    exe "norm! \<ESC>"
    sleep
    exe "norm! \<ESC>"

    call append("$", s:gethour() . ":00 ")

"   reset event handling
    call s:reset_event()

    if (s:bufold==s:bufnum) && (s:winold==s:winnum)
      startinsert
    endif
    $
    norm! $
    exe "norm! \<C-W>" s:winold
    exe "buffer!" s:bufold
    unlet s:winold
    unlet s:bufold
  endif
endf

fun! s:uninstall(buf)
  if (a:buf==s:bufnum) && (s:winnum==winnr())
    unlet s:jdir
    unlet s:lastmonth
    unlet s:lasthour
    unlet s:bufnum
    unlet s:winnum
    call s:settimer("")
    delf s:settimer
    delf s:reset_event
    delf s:triggered_journal_event
    delf s:fcd
    delf s:gethour
    delf s:getstrdate
    delf s:getstrmonth
    delf s:getyear
    delf s:getmonth
    delf s:getstrfilename
"   delf s:uninstall
    delc Autojournal
  endif
endf

" main section of the script

" define below to select a new directory for your journal
let s:jdir='c:/notes/j/'

let s:lastmonth=-1
let s:lasthour=s:gethour()

call s:reset_event()
call s:settimer("on")

com! -nargs=1 Autojournal call <SID>settimer("<args>")

