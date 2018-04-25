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
    let g:CheatSheetUrlSettings='Tq'
endif

let s:prevrequest={}

let s:static_filetype = {
            \'c++': 'cpp'
            \}

" Returns the url to query
function! s:geturl(query)
    return g:CheatSheetUrlGetter.' "'.g:CheatSheetBaseUrl.'/'.a:query.'?'.
                \g:CheatSheetUrlSettings.'"'
endfunction

" Returns the url to query
function! s:getlines(query, commented)
    call cheat#echo('Sending query : "'.a:query.'" to '.g:CheatSheetBaseUrl.
                \ ' this may take some time', 'S')
    let s:prevrequest['query']=a:query
    let lines= systemlist(s:geturl(a:query))
    let s:prevrequest['do_comment']=a:commented
    if(a:commented)
        return s:add_comments(lines)
    endif
    return lines
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
    return system(s:geturl(":list"))
endfunction

" Lookup for previous or next answer (+- a:delta)
function! cheat#naviguate(delta)
    if (! (a:delta =~# '^-\?\d\+$'))
        call cheat#echo('Delta must be a number', 'e')
        return
    endif

    if(empty(s:prevrequest))
        call cheat#echo('You must first call :Cheat or :CheatReplace', 'e')
        return
    endif

    " Retrieve last query number
    let query=s:prevrequest["query"]
    let num=matchstr(query, '\d*$')

    " No number means answer 0
    if(num == "")
        let num=0
        let query.='/'
    endif
    let num=num+a:delta

    if(num <0)
        call cheat#echo('There is no previous answer', 'e')
        return
    elseif(num==0)
        let query=substitute(query, '/\d*$', '', '')
    else
        let query=substitute(query, '\d*$', num, '')
    endif

    let lines=s:getlines(query, s:prevrequest['do_comment'])
    call s:PrintLines(s:prevrequest['ft'], lines, 0)
endfunction

" Handle a cheat query
function! cheat#cheat(query, froml, tol, range, replace)
    if(a:query == "")
        " No explicit query, prepare query from selection
        let text=substitute(s:get_visual_selection(a:froml,a:tol, a:range),
                    \'^\s*', '', '')
        let query=&ft.'/'.substitute(text, ' ', '+', 'g')

        " There must be a + in the query
        if(match(query, '+') == -1)
            let query=query.'+'
        endif

        if(a:replace && a:range ==0)
           call cheat#echo('removing lines', 'e')
           normal dd
           let s:appendpos=getcurpos()[1]-1
        else
           let s:appendpos=getcurpos()[1]
        endif
        " Retrieve lines commented
        let lines=s:getlines(query, 1)
        let ft=&ft

    else
        " simple query
        let ft=substitute(a:query, '^/\?\([^/]*\)/.*$', '\1', '')
        call cheat#echo(ft,'e')
        if(ft == a:query)
            let ft=g:CheatSheetFt
        endif
        let lines=s:getlines(a:query, 0)
    endif
    call s:PrintLines(ft, lines, a:replace)
endfunction


function! s:PrintLines(ft, lines, replace)
    let s:prevrequest['ft']=a:ft
    if(a:replace)
        " Remove selection (currently only line if whole line selected)
        call append(s:appendpos, a:lines)
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
        " TODO convert ft
        if(has_key(s:static_filetype,a:ft))
            let ft=s:static_filetype[a:ft]
        else
            let ft=a:ft
        endif
        execute ': set ft='.ft
        " Add lines and go to beginning
        call append(0, a:lines)
        normal gg
    endif
endfunction

" Returns the line, commented if it is not code
function! s:add_comments(lines)
    let ret=[]
    for line in a:lines
        " Count number of spaces at beginning of line (probably a better way
        " to do it
        let i=0
        while (line[i] == ' ')
            let i=i+1
        endwhile
        " Comment everthing that is not code or blank line
        if(i>2 || match(line, '^    $') !=-1)
            call add(ret,strpart(line, 3))
        else
            call add(ret,substitute(&cms, "%s", line, ''))
        endif
    endfor
    return ret
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
