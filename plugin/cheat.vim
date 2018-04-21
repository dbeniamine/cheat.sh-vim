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

if exists("g:loaded_cheat_sh")
  finish
endif

let g:save_cpo = &cpo
set cpo&vim

let g:loaded_cheat_sh = "v0.1"

" command definition
command! -nargs=1 -complete=custom,cheat#completeargs Cheat
    \ call cheat#cheat(<q-args>)

let cpo=save_cpo
" vim:set et sw=4:
