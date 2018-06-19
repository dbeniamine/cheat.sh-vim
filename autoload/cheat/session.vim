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

let save_cpo = &cpo
set cpo&vim

" Flag to add cookie file to the query
if(!exists("g:CheatSheetUrlGetterIdFlag"))
    let g:CheatSheetUrlGetterIdFlag='-b'
endif

" Path to cheat sheet cookie
if(!exists("g:CheatSheetIdPath"))
    let g:CheatSheetIdPath=expand('~/.cht.sh/id')
endif

" Retrieve id from cookie
function! s:setIdFromCookie()
    try
        let s:id=substitute(join(readfile(g:CheatSheetIdPath), ' '),
            \'^.*\s\s*\(\S\S*\)$', '\1', '')
	catch /^Vim\%((\a\+)\)\=:E484/
        let s:id=""
    endtry
endfunction

" Save cookie file
function! s:writeCookie()
    let dir=fnamemodify(g:CheatSheetIdPath, ':p:h')
    if( !isdirectory(dir))
        if(s:id == "")
            return
        endif
        call mkdir(dir, 'p')
    endif
    if(s:id == "")
        let lines = []
    else
        let url=substitute(g:CheatSheetBaseUrl, '^https*://', '', '')
        let lines = [ '#', '', 
                    \'.'.url.'	TRUE	/	TRUE	0	id	'.s:id ]
    endif
    call writefile(lines, g:CheatSheetIdPath)
endfunction

" Local id
if(!exists("s:id") || s:id == "")
    call s:setIdFromCookie()
endif

" Random 64 bytes id
function! s:generateId()
    return system('hexdump -e \"%x\" /dev/urandom  | head -c 64')
endfunction

" Add / set session id
function! cheat#session#id(id, bang)
    if(s:id != "" && a:bang == "" && a:id != "remove")
        call cheat#echo('Id is already set', 'W')
        call cheat#echo('To erase id use :CheatId! [newid]', 'W')
        call cheat#echo('To remove id use :Cheat remove', 'W')
    endif
    if(a:id == "")
        if(s:id == "" || a:bang == "!")
            let s:id=s:generateId()
        endif
    else
        if(match(a:id, '^[a-fA-F0-9]\{64}$') ==0  &&
                    \ (s:id=="" || a:bang == "!"))
            let s:id=a:id
        elseif(a:id == "remove")
            let s:id=""
        else
            call cheat#echo("Id should be 64 hexadecimal chars", 'E')
            return
        endif
    endif
    call cheat#echo("Id : ".s:id, 's')
    call s:writeCookie()
endfunction

" Replay last query
function! cheat#session#last()
    if(s:id != "")
        call cheat#cheat(':last', -1, -1, -1, g:CheatSheetDefaultMode, '0')
    else
        call cheat#navigate('0', 'H')
    endif
endfunction

" Generate id options for urlgetter
function! cheat#session#urloptions()
    if(s:id != "")
        return g:CheatSheetUrlGetterIdFlag.' '.g:CheatSheetIdPath
    endif
    return ""
endfunction

let cpo=save_cpo
" vim:set et sw=4:
