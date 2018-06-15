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

" Providers
if(!exists("g:CheatSheetProviders"))
    let g:CheatSheetProviders=['quickfix', 'syntastic']
endif

" Returns the first error on the current buffer
function! cheat#providers#GetErrorFromCurrentBuffer(line)
    if( search('|'.a:line.' col ') == 0)
        " Nothing on current line, search for errors
        call search('ERROR\c')
    endif
    return substitute(substitute(
                \getline('.'), '^[^|]*|[^|]*|', '', ''),
                \'\[.*\]', '', 'g')
endfunction

function! cheat#providers#GetError()
    for provider in g:CheatSheetProviders
        let query=function('cheat#providers#'.provider.'#GetError')()
        if(query != "")
            return substitute(substitute(substitute(substitute(
                        \ query, ' ', '+', 'g'),
                        \ '‘\|’', '', 'g'),
                        \'^+*', '', ''),
                        \'+*$', '', '')
        endif
    endfor
    return ""
endfunction

" vim:set et sw=4:
