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

" Transforms a high level request into a query ready to be processed by cht.sh
function! cheat#requests#toquery(request)
    if(a:request.useFt == 1)
        let query='vim:'.a:request.ft.'/'
    else
        let query=''
    endif
    if(a:request.isCheatSheet == 0)
        let query.=substitute(a:request.query, ' ', '+', 'g')
        " There must be a + in the query
        if(match(query, '+') == -1)
            let query.='+'
        endif
        let query.='/'.a:request.q.'/'.a:request.a.','.a:request.s
    else
        let query.=a:request.query
    endif
    let query.='?'
    let query.=g:CheatSheetUrlSettings
    " Color pager requests
    if(a:request.mode!=2)
        let query.='T'
    endif
    if(a:request.comments==0)
        let query.='Q'
    endif
    if(exists("g:CheatSheetPagerStyle") && a:request.mode==2)
        let query.="&style=".g:CheatSheetPagerStyle
    endif
    return query
endfunction

" Parse the query to update the given request
function! s:parseQuery(query, request)
    let opts=split(a:query, '/')
    if(len(opts) >= 2)
        let a:request.ft=opts[0]
        let a:request.query=opts[1]
    else
        let a:request.ft=g:CheatSheetFt
        let a:request.query=opts[0]
        let a:request.useFt = 0
    endif
    if(len(opts) >=3)
        let a:request.q=opts[2]
    else
        let a:request.q=0
    endif
    if(len(opts) >=4)
        " Remove see related if present
        let a:request.a=substitute(opts[3], '\(.*\),\+.*$', '\1', '')
    else
        let a:request.a=0
    endif
    " Remove see related uses , not /
    if(match(a:query, ',\d\+$')!=-1)
        let a:request.s=substitute(a:query, '^.*,\(\d\+\)$', '\1', '')
    else
        let a:request.s=0
    endif
    if(match(a:query,'+')!=-1)
        let a:request.isCheatSheet=0
        let a:request.useFt = 1
    else
        let a:request.isCheatSheet=1
    endif
    return a:request
endfunction


" Prepare an empty request
function! cheat#requests#init(query, parseQuery)
    let request={
                \'a' : 0,
    			\'q' : 0,
    			\'s' : 0,
    			\'comments' : g:CheatSheetShowCommentsByDefault,
    			\'ft' : cheat#frameworks#getFt(),
    			\'isCheatSheet' : 0,
    			\'appendpos' : 0,
    			\'numLines' : 0,
    			\'mode' : g:CheatSheetDefaultMode,
    			\'useFt' : 1,
                \'query' : a:query,
                \}
    if(a:parseQuery)
        call s:parseQuery(a:query, request)
    endif
    return request
endfunction

let cpo=save_cpo
" vim:set et sw=4:
