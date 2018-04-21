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

function! cheat#geturl(query, run)
    let cmd=g:CheatSheetUrlGetter.' "'.g:CheatSheetBaseUrl.'/'.a:query.'?'.
                \g:CheatSheetUrlSettings.'"'
    if(a:run)
        return system(cmd)
    else
        return cmd
    endif
endfunction

function! cheat#completeargs(A, L, P)
    return cheat#geturl(':list', 1)
endfunction

function! cheat#cheat(query)
    execute ':'.g:CheatSheetReaderCmd.' +set\ bt=nofile\ ft='.g:CheatSheetFt.
                \' | 0read ! '.cheat#geturl(a:query, 0)
    normal gg
endfunction

let cpo=save_cpo
" vim:set et sw=4:
