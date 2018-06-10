function! cheat#providers#syntastic#GetError()
    try
        Errors
    catch /^Vim\%((\a\+)\)\=:E492/
        return ""
    endtry
    silent lclose
    lopen
    if( search('ERROR\c') == -1)
        " No error search current line
        call search('|'.getpos('.')[1].' col ')
    endif
    echo getline('.')
    let query=substitute(substitute(substitute(
                \getline('.'), '^[^|]*|[^|]*|', '', ''),
                \'\[.*\]$', '', ''),
                \'‘\|’', '', 'g')
    echo query
    lclose
    return query
endfunction
