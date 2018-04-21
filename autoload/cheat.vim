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

" View command padoc etc.
if(!exists("g:CheatSheatReaderCmd"))
    let g:CheatSheatReaderCmd='view -c "set ft=markdown"'
endif

" Program used to retrieve cheat sheet with its arguments
if(!exists("g:CheatSheatUrlGetter"))
    let g:CheatSheatUrlGetter='curl -silent'
endif

" cheat sheet base url
if(!exists("g:CheatSheatBaseUrl"))
    let g:CheatSheatBaseUrl='cheat.sh'
endif

" cheat sheet settings
if(!exists("g:CheatSheatUrlSettings"))
    let g:CheatSheatUrlSettings='Tq'
endif

function! cheat#geturl(query, type)
    let cmd=g:CheatSheatUrlGetter.' "'.g:CheatSheatBaseUrl.'/'.a:query.'?'.
                \g:CheatSheatUrlSettings.'"'
    if(a:type == "list")
        return systemlist(cmd)
    else
        return system(cmd)
    endif
endfunction

function! cheat#completeargs(A, L, P)
    return cheat#geturl(':list', "string")
endfunction

function! cheat#cheat(query)
    let tmpfile=tempname()
    let contents=cheat#geturl(a:query, "list")
    execute 'redir > '.tmpfile
    " Remove everything until first empty line and print the contents
    silent echo join(contents[match(contents,'^$'):],"\n")
    redir END
    " Read the temporary file
    execute ':!'.g:CheatSheatReaderCmd.' '.tmpfile
endfunction

let cpo=save_cpo
" vim:set et sw=4:
