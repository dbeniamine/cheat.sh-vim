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

" Providers
if(!exists("g:CheatSheetProviders"))
    let g:CheatSheetProviders=['quickfix', 'syntastic']
endif

" Returns the first error on the current buffer
function! cheat#providers#GetErrorFromList(errors)
    if(empty(a:errors))
        return ''
    endif
    let line=getpos('.')[1]
    let firstErr=""
    let error=""
    for err in a:errors
        if(error == "" && (err.type ==? "E" || 
                    \ err.type=='' && match(err.text, 'ERROR\c')!=-1))
            " Save first error
            let error = err.text
        endif
        if(err.lnum == line)
            " Found something on currentline
            let error=err.text
            break
        endif
    endfor
    if(error == "")
        " Default to first line of errors
        let error=s:errors[0].text
    endif
    return error
endfunction

function! s:PrepareQuery(text)
    " Remove ending [blabla], replace space by plus, sanitize, trim +
    return substitute(substitute(substitute(substitute(a:text,
                        \'\[.*\]$', '', ''),
                        \' ', '+', 'g'),
                        \ "‘\\|’\\|\\[\\|\\]\\|\"\\|'\\|(\\|)", '', 'g'),
                        \'^+*\(.*\)+*$', '\1', '')
endfunction

function! cheat#providers#GetError()
    for provider in g:CheatSheetProviders
        let query=function('cheat#providers#'.provider.'#GetError')()
        if(query != "")
            return s:PrepareQuery(query)
        endif
    endfor
    return ""
endfunction

function! cheat#providers#TestPrepareQuery()
    let text="'bla' bli b‘lo’ [blu] \"plop\""
    echo text
    echo s:PrepareQuery(text)
endfunction

let cpo=save_cpo
" vim:set et sw=4:
