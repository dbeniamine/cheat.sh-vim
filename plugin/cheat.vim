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

let save_cpo = &cpo
set cpo&vim

let g:loaded_cheat_sh = "v0.2"

" Default query mode
if(!exists("g:CheatSheetDefaultMode"))
    let g:CheatSheetDefaultMode=0
endif

" cheat sheet base url
if(!exists("g:CheatSheetBaseUrl"))
    let g:CheatSheetBaseUrl='https://cht.sh'
endif

" command definition
command! -nargs=? -bang -count -complete=custom,cheat#completeargs Cheat
    \ call cheat#cheat(<q-args>, <line1>, <line2>, <count>, 0, "<bang>")

command! -nargs=? -count CheatError
    \ call cheat#cheat('', -1, -1, -1, 4, '!')

command! -nargs=? -bang -count -complete=custom,cheat#completeargs CheatReplace
    \ call cheat#cheat(<q-args>, <line1>, <line2>, <count>, 1, "<bang>")

command! -nargs=? -bang -count -complete=custom,cheat#completeargs CheatPager
    \ call cheat#cheat(<q-args>, <line1>, <line2>, <count>, 2, "<bang>")

command! -nargs=? -bang -count -complete=custom,cheat#completeargs CheatPaste
    \ call cheat#cheat(<q-args>, <line1>, <line2>, <count>, 3, "<bang>")

command! -nargs=1 CheatNavigateQuestions call cheat#navigate(<q-args>, 'Q')
command! -nargs=1 CheatNavigateAnswers call cheat#navigate(<q-args>, 'A')
command! -nargs=1 CheatSeeAlso call cheat#navigate(<q-args>, 'S')
command! -nargs=1 CheatHistory call cheat#navigate(<q-args>, 'H')
command! -nargs=? -bang CheatId call cheat#session#id(<q-args>, "<bang>")

if((!exists("g:CheatDoNotReplaceKeywordPrg") ||
            \ g:CheatDoNotReplaceKeywordPrg ==0))
    if(has("patch-7.4.1833"))
        set keywordprg=:CheatPager!
    else
        exe 'set keywordprg='.expand('<sfile>:p:h').'/../scripts/chtpager.sh'
    endif
endif

if(!exists("g:CheatSheetDoNotMap") || g:CheatSheetDoNotMap ==0)
    nnoremap <script> <silent> <leader>C :call cheat#toggleComments()<CR>

    " Buffer
    nnoremap <script> <silent> <leader>KB
                \ :call cheat#cheat("", getcurpos()[1], getcurpos()[1], 0, 0, '!')<CR>
    vnoremap <script> <silent> <leader>KB
                \ :call cheat#cheat("", -1, -1, 2, 0, '!')<CR>

    " Pager
    nnoremap <script> <silent> <leader>KK
                \ :call cheat#cheat("", getcurpos()[1], getcurpos()[1], 0, 2, '!')<CR>
    vnoremap <script> <silent> <leader>KK
                \ :call cheat#cheat("", -1, -1, 2, 2, '!')<CR>

    vnoremap <script> <silent> <leader>KL  :call cheat#session#last()<CR>
    nnoremap <script> <silent> <leader>KL  :call cheat#session#last()<CR>


    " Replace
    nnoremap <script> <silent> <leader>KR
                \ :call cheat#cheat("", getcurpos()[1], getcurpos()[1], 0, 1, '!')<CR>
    vnoremap <script> <silent> <leader>KR
                \ :call cheat#cheat("", -1, -1, 2, 1, '!')<CR>

    " Paste
    nnoremap <script> <silent> <leader>KP
                \ :call cheat#cheat("", getcurpos()[1], getcurpos()[1], 0, 4, '!')<CR>
    vnoremap <script> <silent> <leader>KP
                \ :call cheat#cheat("", -1, -1, 4, 1, '!')<CR>

    nnoremap <script> <silent> <leader>Kp
                \ :call cheat#cheat("", getcurpos()[1], getcurpos()[1], 0, 3, '!')<CR>
    vnoremap <script> <silent> <leader>Kp
                \ :call cheat#cheat("", -1, -1, 3, 1, '!')<CR>

    " Buffer
    nnoremap <script> <silent> <leader>KE
                \ :call cheat#cheat("", -1, -1 , -1, 5, '!')<CR>
    vnoremap <script> <silent> <leader>KE
                \ :call cheat#cheat("", -1, -1, -1, 5, '!')<CR>
     " Toggle comments
    nnoremap <script> <silent> <leader>KC :call cheat#navigate(0, 'C')<CR>
    vnoremap <script> <silent> <leader>KC :call cheat#navigate(0, 'C')<CR>

    " Next
    nnoremap <script> <silent> <leader>KQN :call cheat#navigate(1,'Q')<CR>
    vnoremap <script> <silent> <leader>KQN :call cheat#navigate(1,'Q')<CR>
    nnoremap <script> <silent> <leader>KAN :call cheat#navigate(1, 'A')<CR>
    vnoremap <script> <silent> <leader>KAN :call cheat#navigate(1, 'A')<CR>
    nnoremap <script> <silent> <leader>KHN :call cheat#navigate(1, 'H')<CR>
    vnoremap <script> <silent> <leader>KHN :call cheat#navigate(1, 'H')<CR>

    " Prev
    nnoremap <script> <silent> <leader>KQP :call cheat#navigate(-1,'Q')<CR>
    vnoremap <script> <silent> <leader>KQP :call cheat#navigate(-1,'Q')<CR>
    nnoremap <script> <silent> <leader>KAP :call cheat#navigate(-1,'A')<CR>
    vnoremap <script> <silent> <leader>KAP :call cheat#navigate(-1,'A')<CR>
    nnoremap <script> <silent> <leader>KHP :call cheat#navigate(-1, 'H')<CR>
    vnoremap <script> <silent> <leader>KHP :call cheat#navigate(-1, 'H')<CR>

    " See Also
    nnoremap <script> <silent> <leader>KSN :call cheat#navigate(1,'S')<CR>
    vnoremap <script> <silent> <leader>KSN :call cheat#navigate(1,'S')<CR>
    nnoremap <script> <silent> <leader>KSP :call cheat#navigate(-1,'S')<CR>
    vnoremap <script> <silent> <leader>KSP :call cheat#navigate(-1,'S')<CR>

    " Frameworks switch
    nnoremap <script> <silent> <leader>Kf
                \ :call cheat#frameworks#cycle(1)<CR>
    vnoremap <script> <silent> <leader>Kf
                \ :call cheat#frameworks#cycle(1)<CR>
    nnoremap <script> <silent> <leader>KF
                \ :call cheat#frameworks#cycle(-1)<CR>
    vnoremap <script> <silent> <leader>KF
                \ :call cheat#frameworks#cycle(-1)<CR>
    nnoremap <script> <silent> <leader>Kt
                \ :call cheat#frameworks#cycle(0)<CR>
    vnoremap <script> <silent> <leader>Kt
                \ :call cheat#frameworks#cycle(0)<CR>

endif

try
    function SyntasticCheckHook(errors)
        call cheat#providers#syntastic#Hook(a:errors)
    endfunction
endtry

let cpo=save_cpo
" vim:set et sw=4:
