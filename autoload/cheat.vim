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
" GNU Affero General Public License for more details.
" 
" You should have received a copy of the GNU Affero General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.

let g:save_cpo = &cpo
set cpo&vim

function! cheat#geturl(query, type)
    let url="cheat.sh/".a:query."/?T"
    if(a:type == "list")
        return systemlist("curl -silent '".url."'")
    else
        return system("curl -silent '".url."'")
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
