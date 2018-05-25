" Vim plugin for accessing cheat sheets from cheat.sh.
" Maintainer: David Beniamine
"
" Copyright (C) 2018 David Beniamine. All rights reserved.
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.

let g:save_cpo = &cpo
set cpo&vim

" Vim command used to open new buffer
if(!exists("g:CheatSheetReaderCmd"))
    let g:CheatSheetReaderCmd='new'
endif

" Cheat sheet file type
if(!exists("g:CheatSheetFt"))
    let g:CheatSheetFt='markdown'
endif

" Program used to retrieve cheat sheet with its arguments
if(!exists("g:CheatSheetUrlGetter"))
    let g:CheatSheetUrlGetter='curl --silent'
endif

" cheat sheet base url
if(!exists("g:CheatSheetBaseUrl"))
    let g:CheatSheetBaseUrl='https://cheat.sh'
endif

" cheat sheet settings
if(!exists("g:CheatSheetUrlSettings"))
    let g:CheatSheetUrlSettings='q'
endif

" cheat sheet pager
if(!exists("g:CheatPager"))
    let g:CheatPager='less -R'
endif

" cheat sheet buffer name
if(!exists("g:CheatSheetBufferName"))
    let g:CheatSheetBufferName="_cheat"
endif

" Default selection (lines or word)
if(!exists("g:CheatSheetDefaultSelection"))
    let g:CheatSheetDefaultSelection="line"
endif

" Show comments in answers by default
if(!exists("g:CheatSheetShowCommentsByDefault"))
    let g:CheatSheetShowCommentsByDefault=1
endif

let s:history=[]
let s:histPos=-1

let s:static_filetype = {
            \'c++': 'cpp'
            \}

" Returns the url to query
function! s:getUrl(query)
    return g:CheatSheetUrlGetter.' "'.g:CheatSheetBaseUrl.'/'.a:query.'"'
endfunction

" Print nice messages
function! cheat#echo(msg,type)
  if a:type=='e'
    let group='ErrorMsg'
  elseif a:type=='w'
    let group='WarningMsg'
  elseif a:type=='q'
    let group='Question'
  elseif a:type=='s'
    let group='Define'
  elseif a:type=='D'
    if !exists("g:CheatDebug")
      return
    else
      let group='WarningMsg'
    endif
  else
    let group='Normal'
  endif
  execute 'echohl '.group
  echo a:msg
  echohl None
endfunction

" Returns the list of available options
function! cheat#completeargs(A, L, P)
    call cheat#echo('Retrieving list of available cheat sheets', 'S')
    if(match(a:A, '.*/.*$')!=-1)
        let cat=substitute(a:A, '\(.*/\).*', '\1', '')
        let url=cat.':list'
    else
        let url=':list'
        let cat=''
    endif
    silent return substitute(system(s:getUrl(url)),
                \'\(\n\|^\)\(\S\)', '\1'.cat.'\2', 'g')
endfunction

function! s:lastRequest()
    return s:history[s:histPos]
endfunction

" Lookup for previous or next answer (+- a:delta)
function! cheat#navigate(delta, type)
    if (! (a:delta =~# '^-\?\d\+$'))
        call cheat#echo('Delta must be a number', 'e')
        return
    endif

    if(empty(s:lastRequest()))
        call cheat#echo('You must first 0,0call :Cheat or :CheatReplace', 'e')
        return
    endif

    " Move in history if required
    if(a:type=='H')
        let nextPos=s:histPos+a:delta
        if(nextPos<0)
            call cheat#echo('Cannot go into the future', 'e')
            return
        elseif(nextPos>=len(s:history))
            call cheat#echo('No more history', 'e')
            return
        endif
        let s:histPos=nextPos
        " Work directly on request from history, no copy
        let s:isInHistory=1
        let request = s:lastRequest()
    else
        " Retrieve request
        let s:isInHistory=0
        let request = copy(s:lastRequest())
    endif


    if(request.isCheatSheet == 1)
        call cheat#echo('Navigation is not implemented for cheat sheets', 'e')
        return
    endif

    " Change parameters
    if(a:type == 'Q')
        let request.q=max([0,request.q+a:delta])
        let request.a=0
        let request.s=0
    elseif(a:type == 'A')
        let request.a=max([0,request.a+a:delta])
        let request.s=0
    elseif(a:type == 'S')
        let request.s=max([0,request.s+a:delta])
    elseif(a:type == 'C')
        let request.comments=(request.comments+1)%2
    elseif(a:type !='H')
        call cheat#echo('Unknown navigation type "'.a:type.'"', 'e')
        return
    endif

    " Remove previously replaced lines
    if(request.mode == 1)
        let pos=request.appendpos+1
        execute ':'.pos
        execute 'd'.request.numLines
    endif

    let request.numLines=0
    call s:handleRequest(request)
endfunction

" Preprends ft and make sure that the query has a '+'
function! s:preparePlusQuery(query)
    let query=&ft.'/'.substitute(a:query, ' ', '+', 'g')
    " There must be a + in the query
    if(match(query, '+') == -1)
        let query=query.'+'
    endif
    return query
endfunction

" Completes request to be a high level request corresponding to the given
" query
function! s:requestFromQuery(query, request)
    let opts=split(a:query, '/')
    if(len(opts) >=3)
        let a:request.q=opts[2]
    else
        let a:request.q=0
    endif
    if(len(opts) >=4)
        " Remove see related if present
        let a:request.a=substitute(opts[3], '\(.*\),\+.*$', '\1', '')
    else
        let a:request.a=0
    endif
    " Remove see related uses , not /
    if(match(a:query, ',\d\+$')!=-1)
        let a:request.s=substitute(a:query, '^.*,\(\d\+\)$', '\1', '')
    else
        let a:request.s=0
    endif
    let a:request.ft=opts[0]
    let a:request.query=opts[0]."/".opts[1]
    if(match(a:query,'+')==-1)
        let a:request.isCheatSheet=1
    endif
    return a:request
endfunction

" Transforms a high level request into a query ready to be processed by cht.sh
function! s:queryFromRequest(request)
    let query=a:request.query
    if(a:request.isCheatSheet ==0)
        let query.='/'.a:request.q.'/'.a:request.a.','.a:request.s
    endif
    let query.='?'
    let query.=g:CheatSheetUrlSettings
    " Color pager requests
    if(a:request.mode!=2)
        let query.='T'
    endif
    if(a:request.comments==0)
        let query.='Q'
    endif
    if(exists("g:CheatSheetPagerStyle"))
        let query.="&style=".g:CheatSheetPagerStyle
    endif
    return query
endfunction

" Prepare an empty request
function! s:initRequest()
    let request={}
    let request.a=0
    let request.q=0
    let request.s=0
    let request.comments=g:CheatSheetShowCommentsByDefault
    let request.ft=&ft
    let request["isCheatSheet"]=0
    let request.appendpos=0
    let request.numLines=0
    return request
endfunction

" Handle a cheat query
" Args :
"       query       : the text query
"       froml       : the first line (if no queries)
"       tol         : the last line (if no queries)
"       range       : the number of selected words in visual mode
"       mode        : the output mode : 0=> buffer, 1=> replace, 2=>pager
"       isplusquery   : should we do a Ft query
function! cheat#cheat(query, froml, tol, range, mode, isplusquery) range
    let request=s:initRequest()
    if(a:query == "")
        let query=substitute(s:get_visual_selection(a:froml,a:tol, a:range),
                    \'^\s*', '', '')
    else
        let query=a:query
    endif

    if(a:isplusquery == '!')
        " No explicit query, prepare query from selection
        let request.query=s:preparePlusQuery(query)
    else
        " simple query
        let ft=substitute(query, '^/\?\([^/]*\)/.*$', '\1', '')
        if(ft == query)
            " simple query
            let request.ft=g:CheatSheetFt
            let request["isCheatSheet"]=1
            let request.query=query
        else
            " arbitrary query
            let request=s:requestFromQuery(query, request)
        endif
    endif
    " Reactivate history if required
    let s:isInHistory=0
    let request.mode=a:mode
    call s:handleRequest(request)
endfunction

" Prints a message about the query to be prossessed
function! s:displayRequestMessage(request)
    if(a:request.isCheatSheet == 1)
        let message='Looking for cheat sheet: "'.a:request.query.'" from '.
                    \g:CheatSheetBaseUrl
    else
        let message='Sending query : "'.a:request.query.'" to '.
                    \g:CheatSheetBaseUrl
        let more=''
        if(a:request.s!=0)
            let more.="\n\trelated number: ".a:request.s
        endif
        if(a:request.a!=0)
            let more.="\n\tanswer number: ".a:request.a
        endif
        if(a:request.q!=0)
            let more.="\n\tquestion number: ".a:request.q
        endif
        if(more != '')
            let message.="\nRequesting".more
        endif
    endif
    call cheat#echo(message. "\nthis may take some time", 'S')
endfunction

function! cheat#createOrSwitchToBuffer()
    let winnr = bufwinnr('^'.g:CheatSheetBufferName.'$')
    " Retrieve buffer or create it
    if ( winnr >= 0 )
        execute winnr . 'wincmd w'
    else
        execute ':'.g:CheatSheetReaderCmd.
                \ ' +set\ bt=nofile\ bufhidden=wipe '.
                \g:CheatSheetBufferName
    endif
endfunction

" Add request to history if not already in
function! s:saveRequest(request)
    if(s:isInHistory == 0 )
        let s:histPos+=1
        if(s:histPos < len(s:history))
            " We are back in history, remove meaning less nexts
            call remove(s:history, s:histPos, -1)
        endif
        call insert(s:history, a:request, s:histPos)
    endif
endfunction

" Launch the request with jobs if available
function! s:handleRequest(request)
    call s:saveRequest(a:request)
    let curl=s:getUrl(s:queryFromRequest(a:request))

    if(a:request.mode == 2)
        execute ":silent !".curl.' | '.g:CheatPager
        redraw!
        return
    elseif(a:request.mode == 1)
        call cheat#echo('removing lines', 'e')
        normal dd
        let a:request.appendpos=getcurpos()[1]-1
    elseif(a:request.mode == 0)
        " Prepare buffer
        call cheat#createOrSwitchToBuffer()
        execute 'normal ggdG'
        " Update ft
        if(has_key(s:static_filetype,a:request.ft))
            let ft=s:static_filetype[a:request.ft]
        else
            let ft=a:request.ft
        endif
        execute ': set ft='.ft
    endif

    call s:displayRequestMessage(a:request)
    if(has('job'))
        if(exists('s:job'))
            call job_stop(s:job)
        endif
        silent let s:job = job_start(curl, {"callback": "cheat#handleRequestOutput"})
    else
        " Simulate asynchronous behavior
        silent for line in systemlist(curl)
            call cheat#handleRequestOutput(0, line)
        endfor
    endif
    redraw!
endfunction

" Output the answer line by line
function! cheat#handleRequestOutput(channel, msg)
    " Put vim in foreground if required
    if(has('jobs'))
        call foreground()
    endif
    let request=s:lastRequest()
    " Retrieve lines
    if(request.mode == 0)
        call cheat#createOrSwitchToBuffer()
    endif
    call append(request.appendpos+request.numLines, a:msg)
    let request.numLines+=1
    execute ':'.request.appendpos
endfunction

" Returns the text that is currently selected
function! s:get_visual_selection(froml, tol, range)
    " Why is this not a built-in Vim script function?!
    if(a:range<=0)
        if(g:CheatSheetDefaultSelection == "line")
            return join(getline(a:froml, a:tol), " ")
        else
            return expand("<cword>")
        endif
    endif
    "visual mode
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, " ")
endfunction

let cpo=save_cpo
" vim:set et sw=4:
