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
function! s:geturl(query, colored, commented)
    let url=g:CheatSheetUrlGetter.' "'.g:CheatSheetBaseUrl.'/'.a:query.'?'.
                \g:CheatSheetUrlSettings

    if(a:colored==0)
        let url.='T'
    endif
    if(a:commented)
        let url.='c'
    endif
    let url.='"'

    return url
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
    return substitute(system(s:geturl(url, 0, 0)),
                \'\(\n\|^\)\(\S\)', '\1'.cat.'\2', 'g')
endfunction

" Lookup for previous or next answer (+- a:delta)
function! cheat#naviguate(delta, type)
    if (! (a:delta =~# '^-\?\d\+$'))
        call cheat#echo('Delta must be a number', 'e')
        return
    endif

    if(empty(s:prevrequest))
        call cheat#echo('You must first call :Cheat or :CheatReplace', 'e')
        return
    endif

    if(s:prevrequest["NoNaviguate"] == 1)
        call cheat#echo('Naviguation is not implemented for cheat sheets', 'e')
        return
    endif

    let query=s:prevrequest["query"]

    let [query,q,a,s] = split(substitute(query,
                \'^\(.*\)/\(\d\+\)/\(\d\+\),\(\d\+\)$', '\1,\2,\3,\4', ''),',')

    " query looks like query/0/0 maybe ,something
    if(a:type == 'Q')
        let q=max([0,q+a:delta])
        let a=0
        let s=0
    elseif(a:type == 'A')
        let a=max([0,a+a:delta])
        let s=0
    elseif(a:type == 'S')
        let s=max([0,s+a:delta])
    else
        call cheat#echo('Unknown naviguation type "'.a:type.'"', 'e')
        return
    endif

    let query.='/'.q.'/'.a.','.s

    call s:handleQuery(query, s:prevrequest['ft'],
                \s:prevrequest['do_comment'], 0)
endfunction

function! s:PrepareFtQuery(query)
    let s:prevrequest["NoNaviguate"]=0
    let query=&ft.'/'.substitute(a:query, ' ', '+', 'g')
    " There must be a + in the query
    if(match(query, '+') == -1)
        let query=query.'+'
    endif
    return query.'/0/0,0'
endfunction

" We know only that query looks like ft/query
function! s:add_optionals(query)
    let s:prevrequest["NoNaviguate"]=0
    let opts=split(a:query, '/')
    if(len(opts) >=3)
        let q=opts[2]
    else
        let q=0
    endif
    if(len(opts) >=4)
        " Remove see related if present
        let a=substitute(opts[3], '\(.*\),\+.*$', '\1', '')
    else
        let a=0
    endif
    " Remove see related uses , not /
    if(match(a:query, ',\d\+$')!=-1)
        let s=substitute(a:query, '^.*,\(\d\+\)$', '\1', '')
    else
        let s=0
    endif
    return opts[0]."/".opts[1]."/".a."/".q.','.s
endfunction

" Handle a cheat query
" Args :
"       query   : the text query
"       froml   : the first line (if no queries)
"       tol     : the last line (if no queries)
"       range   : the number of selected words in visual mode
"       mode    : the output mode : 0=> buffer, 1=> replace, 2=>pager
function! cheat#cheat(query, froml, tol, range, mode)
    if(a:query == "")
        " No explicit query, prepare query from selection
        let query=s:PrepareFtQuery(
                    \substitute(s:get_visual_selection(a:froml,a:tol, a:range),
                    \'^\s*', '', ''))

        if(a:mode == 1 && a:range ==0)
           call cheat#echo('removing lines', 'e')
           normal dd
           let s:appendpos=getcurpos()[1]-1
        else
           let s:appendpos=getcurpos()[1]
        endif
        " Retrieve lines commented
        let ft=&ft
        let commented=1

    else
        " simple query
        let ft=substitute(a:query, '^/\?\([^/]*\)/.*$', '\1', '')
        call cheat#echo(ft,'e')
        if(ft == a:query)
            let ft=g:CheatSheetFt
            " simple query
            let s:prevrequest["NoNaviguate"]=1
            let query=a:query
        else
            let query=s:add_optionals(a:query)
        endif
        let commented=0
    endif
    if(a:mode==2)
        call cheat#pager(query)
    else
        call s:handleQuery(query, ft, commented, a:mode)
    endif
endfunction

function! cheat#pager(query)
    let query=s:PrepareFtQuery(a:query)
    let s:prevrequest['ft']=&ft
    let s:prevrequest['query']=a:query
    let s:prevrequest['do_comment']=1
    execute ":!".s:geturl(query,1, 1).' | '.g:CheatPager
endfunction

" args :
"       query       : a cheat.sh query
"       ft          : the filetype to use
"       commented   : should the lines be commented
"       mode        : the output mode : 0=> buffer, 1=> replace, 2=>pager
function! s:handleQuery(query, ft, commented, mode)
    let s:prevrequest['ft']=a:ft
    let s:prevrequest['query']=a:query
    let s:prevrequest['do_comment']=a:commented
    if(a:mode ==2)
        execute ":!".s:geturl(query,1, 1).' | '.g:CheatPager
    else
        " Retrieve lines
        call cheat#echo('Sending query : "'.a:query.'" to '.g:CheatSheetBaseUrl.
                \ ' this may take some time', 'S')
        let lines= systemlist(s:geturl(a:query, 0, a:commented))
        if(a:mode == 1)
            " Remove selection (currently only line if whole line selected)
            call append(s:appendpos, lines)
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
            if(has_key(s:static_filetype,a:ft))
                let ft=s:static_filetype[a:ft]
            else
                let ft=a:ft
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
