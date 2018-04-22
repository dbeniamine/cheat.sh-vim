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

let s:CheatSheetNewBuf=g:CheatSheetReaderCmd.' +set\ bt=nofile\ ft='

function! cheat#geturl(query)
    return g:CheatSheetUrlGetter.' "'.g:CheatSheetBaseUrl.'/'.a:query.'?'.
                \g:CheatSheetUrlSettings.'"'
endfunction

function! cheat#completeargs(A, L, P)
    return system(cheat#geturl(':list'))
endfunction

function! cheat#cheat(query, froml, tol, range, replace)
    if(a:query == "")
        " No explicit query, Retrieve selected text
        let text=s:get_visual_selection(a:froml,a:tol, a:range)
        let query=&ft.'/+'.substitute(text, ' ', '+', 'g')
        " Retrieve lines
        let lines=systemlist(cheat#geturl(query))
        let new_lines=[]
        
        for line in lines
            call add(new_lines, s:add_comments(line))
        endfor
        if(a:replace)
            " Remove selection
            if(a:range ==0)
                normal dd
            endif
            call append(getcurpos()[1], new_lines)
        else
            " Put lines in a new buffer
            execute ':'.s:CheatSheetNewBuf.&ft
            call append(0, new_lines)
            normal gg
        endif
    else
        " arbitrary query
        let query=a:query
        execute ':'.s:CheatSheetNewBuf.g:CheatSheetFt.
                    \ ' | 0read ! '.cheat#geturl(query)
        normal gg
    endif
endfunction

function! s:add_comments(line)
    " Count number of spaces at beginning of line (probably a better way
    " to do it
    let i=0
    while (a:line[i] == ' ')
        let i=i+1
    endwhile
    " Comment everthing that is not code
    if(i>2)
        return strpart(a:line, i)
    else
        return substitute(&cms, "%s", a:line, '')
    endif
endfunction

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
