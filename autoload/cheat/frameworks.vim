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

if(!exists("g:CheatSheetFrameworks"))
    let g:CheatSheetFrameworks = {
                \ 'python' : [ 'python', 'django', ],
                \ 'javascript' : ['javscript', 'node', 'angular', 'jquery'],
                \ 'php' : ['php', 'symphony', 'yii', 'zend'],
                \}
endif

if(!exists("b:CheatSheetCurrentFramework"))
    let b:CheatSheetCurrentFramework = 0
endif

" Try to use a framework if defined or return current filetype
function! cheat#frameworks#getFt()
    try
        let ft=g:CheatSheetFrameworks[&ft][b:CheatSheetCurrentFramework]
    catch
        let ft=&ft
    endtry
    return ft
endfunction

" Switch to next filetype
function! cheat#frameworks#cycle(num)
    if(!has_key(g:CheatSheetFrameworks, &ft))
        call cheat#echo('No frameworks define for "'.&ft.
                    \'", see :help cheat.sh-frameworks', 'E')
        return
    endif

    if(a:num == 0)
        " Reset
        let b:CheatSheetCurrentFramework = 0
    else
        if(abs(b:CheatSheetCurrentFramework) >= len(g:CheatSheetFrameworks[&ft]))
            let b:CheatSheetCurrentFramework = 0
        endif
        let b:CheatSheetCurrentFramework += a:num
    endif

    call cheat#echo('Language for cheat queries changed to : "'.
                \cheat#frameworks#getFt().'"', 's')
endfunction

let cpo=save_cpo
" vim:set et sw=4:
