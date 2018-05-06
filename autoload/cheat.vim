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
    let g:CheatSheetBaseUrl='cheat.sh'
endif

" cheat sheet settings
if(!exists("g:CheatSheetUrlSettings"))
    let g:CheatSheetUrlSettings='q'
endif

" cheat sheet pager
if(!exists("g:CheatPager"))
    let g:CheatPager='less -R'
endif

let s:prevrequest={}

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
    return substitute(system(s:getUrl(url)),
                \'\(\n\|^\)\(\S\)', '\1'.cat.'\2', 'g')
endfunction

" Lookup for previous or next answer (+- a:delta)
function! cheat#navigate(delta, type)
    if (! (a:delta =~# '^-\?\d\+$'))
        call cheat#echo('Delta must be a number', 'e')
        return
    endif
    let request = s:prevrequest

    if(empty(request))
        return
    endif

    try
        if(request["isCheatSheet"] == 1)
            call cheat#echo('Navigation is not implemented for cheat sheets', 'e')
            return
        endif

        " Remove previously replaced lines
        if(request.mode == 1)
            let pos=request.appendpos+1
            execute ':'.pos
            execute 'd'.request.numLines
        endif

        " query looks like query/0/0 maybe ,something
        if(a:type == 'Q')
            let request.q=max([0,request.q+a:delta])
            let request.a=0
            let request.s=0
        elseif(a:type == 'A')
            let request.a=max([0,request.a+a:delta])
            let request.s=0
        elseif(a:type == 'S')
            let request.s=max([0,request.s+a:delta])
        else
            call cheat#echo('Unknown navigation type "'.a:type.'"', 'e')
            return
        endif

        call s:handleRequest(request)
    catch
        call cheat#echo('You must first call :Cheat or :CheatReplace', 'e')
    endtry
endfunction

" Preprends ft and make sure that the query has a '+'
function! s:PrepareFtQuery(query)
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
    " Color pager requests
    if(a:request.mode!=2)
        let query.='T'
    endif
    let query.=g:CheatSheetUrlSettings
    return query
endfunction

" Prepare an empty request
function! s:initRequest()
    let request={}
    let request.a=0
    let request.q=0
    let request.s=0
    let request.ft=&ft
    let request["isCheatSheet"]=0
    return request
endfunction

" Handle a cheat query
" Args :
"       query   : the text query
"       froml   : the first line (if no queries)
"       tol     : the last line (if no queries)
"       range   : the number of selected words in visual mode
"       mode    : the output mode : 0=> buffer, 1=> replace, 2=>pager
function! cheat#cheat(query, froml, tol, range, mode)
    let request=s:initRequest()
    if(a:query == "")
        " No explicit query, prepare query from selection
        let request.query=s:PrepareFtQuery(
                    \substitute(s:get_visual_selection(a:froml,a:tol, a:range),
                    \'^\s*', '', ''))

        if(a:mode == 1 && a:range ==0)
           call cheat#echo('removing lines', 'e')
           normal dd
           let request.appendpos=getcurpos()[1]-1
        else
           let request.appendpos=getcurpos()[1]
        endif
    else
        " simple query
        let ft=substitute(a:query, '^/\?\([^/]*\)/.*$', '\1', '')
        if(ft == a:query)
            let request.ft=g:CheatSheetFt
            " simple query
            let request["isCheatSheet"]=1
            let request.query=a:query
        else
            let request=s:requestFromQuery(a:query, request)
        endif
    endif
    let request.mode=a:mode
    call s:handleRequest(request)
endfunction

" Use for keywordprg, no selection here directly the query
function! cheat#pager(query)
    let request=s:initRequest()
    let request.query=s:PrepareFtQuery(a:query)
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

" Output the result of the given request
function! s:handleRequest(request)
    let s:prevrequest=a:request
    let url=s:getUrl(s:queryFromRequest(a:request))
    call s:displayRequestMessage(a:request)
    if(a:request.mode ==2)
        execute ":!".url.' | '.g:CheatPager
    else
        " Retrieve lines
        let lines= systemlist(url)
        let s:prevrequest.numLines=len(lines)
        if(a:request.mode == 1)
            " Remove selection (currently only line if whole line selected)
            call append(a:request.appendpos, lines)
        else
            let bufname='_cheat.sh'
            let winnr = bufwinnr('^'.bufname.'$')
            " Retrieve buffer or create it
            if ( winnr >= 0 )
                execute winnr . 'wincmd w'
                execute 'normal ggdG'
            else
                execute ':'.g:CheatSheetReaderCmd.
                        \ ' +set\ bt=nofile\ bufhidden=wipe '.bufname
            endif
            " Update ft
            if(has_key(s:static_filetype,a:request.ft))
                let ft=s:static_filetype[a:request.ft]
            else
                let ft=a:request.ft
            endif
            execute ': set ft='.ft
            " Add lines and go to beginning
            call append(0, lines)
            normal gg
        endif
    endif
endfunction

" Returns the text that is currently selected
function! s:get_visual_selection(froml, tol, range)
    " Why is this not a built-in Vim script function?!
    if(a:range>0)
        "visual mode
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
    else
        let line_start=a:froml
        let line_end=a:tol
    endif
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    if(a:range>0)
        let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
        let lines[0] = lines[0][column_start - 1:]
    endif
    return join(lines, "\n")
endfunction

let cpo=save_cpo
" vim:set et sw=4:
